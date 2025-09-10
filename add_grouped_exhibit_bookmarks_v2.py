#!/usr/bin/env python3
import csv, sys, argparse, re, os
try:
    import fitz  # PyMuPDF
except ImportError:
    print("Missing dependency: PyMuPDF. Install with: pip install 'pymupdf>=1.24,<1.25'", file=sys.stderr)
    sys.exit(1)

def first_int(s: str) -> int:
    if not s: return 0
    m = re.findall(r"\d+", str(s))
    return int(m[0]) if m else 0

def clean_title(s: str) -> str:
    if not s: return ""
    base = os.path.basename(s)
    base = re.sub(r"\.[A-Za-z0-9]{1,5}$", "", base)  # drop extension
    base = base.replace("_", " ").replace("-", " ").strip()
    return re.sub(r"\s+", " ", base)

def read_rows(path):
    rows = []
    with open(path, newline="", encoding="utf-8-sig") as f:
        # try sniffing delimiter
        sample = f.read(4096)
        f.seek(0)
        delim = ","
        for d in [",",";","|","\t"]:
            if sample.count(d) > 0:
                delim = d
                break
        r = csv.DictReader(f, delimiter=delim)
        for row in r:
            # columns in your file:
            # Exhibit, File, Pages, BinderRange
            exhibit  = (row.get("Exhibit") or row.get("Code") or "").strip()
            filecol  = (row.get("File") or row.get("Title") or "").strip()
            pages    = (row.get("Pages") or "").strip()
            brange   = (row.get("BinderRange") or "").strip()

            # group from Exhibit like "A-01" -> "A"
            grp = ""
            if exhibit:
                m = re.match(r"\s*([A-Za-z])", exhibit)
                if m: grp = m.group(1).upper()

            code  = exhibit or (row.get("Code") or "").strip()
            title = clean_title(filecol) or code or "Exhibit"
            start = first_int(pages) or first_int(brange)

            rows.append({"group": grp or "A", "code": code, "title": title, "start": start})
    # keep only those with a start page
    rows = [x for x in rows if isinstance(x["start"], int) and x["start"] > 0]
    return rows

def main():
    ap = argparse.ArgumentParser(description="Add grouped Exhibit bookmarks (A/B/C/D/E) from flexible CSV")
    ap.add_argument("pdf_in")
    ap.add_argument("csv_map")
    ap.add_argument("pdf_out")
    ap.add_argument("--offset", type=int, default=0, help="add to all CSV page numbers")
    ap.add_argument("--parent-title", default="Exhibits")
    args = ap.parse_args()

    items = read_rows(args.csv_map)
    if not items:
        print("No valid rows in CSV (check that 'Pages' or 'BinderRange' have numbers).", file=sys.stderr)
        sys.exit(1)

    doc = fitz.open(args.pdf_in)
    total = doc.page_count
    base_toc = doc.get_toc() or []

    # group rows like {"A":[(start,title)...], "B":[...]}
    groups = {}
    for it in items:
        groups.setdefault(it["group"], []).append((it["start"], f'{it["code"]} — {it["title"]}'.strip(" —")))

    # sort groups and entries by start page
    def clamp(p):
        p = p + args.offset
        return 1 if p < 1 else (total if p > total else p)

    all_starts = [p for grp in groups.values() for (p, _) in grp]
    parent_page = clamp(min(all_starts)) if all_starts else 1

    toc = list(base_toc)
    toc.append([1, args.parent_title, parent_page])

    for grp in sorted(groups.keys(), key=lambda g: min(p for p,_ in groups[g])):
        entries = sorted(groups[grp], key=lambda t: t[0])
        grp_page = clamp(entries[0][0])
        toc.append([2, f"Exhibits — {grp}", grp_page])
        for s, txt in entries:
            toc.append([3, txt, clamp(s)])

    doc.set_toc(toc)
    doc.save(args.pdf_out)
    print(f"[OK] Bookmarks written to: {args.pdf_out}")
    print(f"  Parent: {args.parent_title} @ p.{parent_page} | Total pages: {total}")

if __name__ == "__main__":
    main()
