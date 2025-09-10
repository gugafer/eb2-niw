#!/usr/bin/env python3
import csv, sys, argparse, fitz

def read_map(path):
    rows = []
    with open(path, newline='', encoding='utf-8-sig') as f:
        r = csv.DictReader(f)
        for row in r:
            try:
                start = int((row.get("Start") or row.get("StartPage") or "0").strip())
            except:
                start = 0
            rows.append({
                "group": (row.get("Group") or row.get("ExhibitGroup") or "").strip() or "A",
                "code":  (row.get("Code")  or row.get("ExhibitCode")  or "").strip(),
                "title": (row.get("Title") or row.get("ExhibitTitle") or "").strip(),
                "start": start
            })
    # keep only valid starts
    return [x for x in rows if x["start"] > 0]

def main():
    ap = argparse.ArgumentParser(description="Add grouped Exhibit bookmarks from CSV")
    ap.add_argument("pdf_in")
    ap.add_argument("csv_map")
    ap.add_argument("pdf_out")
    ap.add_argument("--offset", type=int, default=0, help="add to all CSV page numbers")
    ap.add_argument("--parent-title", default="Exhibits")
    args = ap.parse_args()

    doc = fitz.open(args.pdf_in)
    total = doc.page_count
    base_toc = doc.get_toc()  # keep existing
    items = read_map(args.csv_map)
    if not items:
        print("No valid rows in CSV.", file=sys.stderr)
        sys.exit(1)

    # group → list[(start, text)]
    groups = {}
    first_start = None
    for it in items:
        if first_start is None or it["start"] < first_start:
            first_start = it["start"]
        text = f'{it["code"]} — {it["title"]}' if it["code"] else it["title"]
        groups.setdefault(it["group"], []).append((it["start"], text))

    # sort groups by first exhibit start
    sorted_groups = sorted(groups.items(), key=lambda kv: min(s for s,_ in kv[1]))

    def clamp(p):  # MuPDF TOC pages are 1-based
        p = p + args.offset
        if p < 1: p = 1
        if p > total: p = total
        return p

    toc = list(base_toc) if base_toc else []
    parent_page = clamp(first_start)
    toc.append([1, args.parent_title, parent_page])

    for grp, rows in sorted_groups:
        rows.sort(key=lambda t: t[0])
        grp_page = clamp(rows[0][0])
        toc.append([2, f"Exhibits — {grp}", grp_page])
        for s, txt in rows:
            page = clamp(s)
            toc.append([3, txt, page])

    doc.set_toc(toc)
    doc.save(args.pdf_out)
    print(f"[OK] Bookmarks written to: {args.pdf_out}")

if __name__ == "__main__":
    main()
