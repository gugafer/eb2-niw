#!/usr/bin/env python3
# add_front_divider_bookmarks_v2.py
# Requires: pip install pymupdf
import argparse, sys
import fitz  # PyMuPDF

def main():
    ap = argparse.ArgumentParser(description="Add top-level bookmarks: Front Matter / Dividers / Exhibits")
    ap.add_argument("input_pdf")
    ap.add_argument("output_pdf")
    ap.add_argument("--front", type=int, help="page number for Front Matter (1-based)")
    ap.add_argument("--dividers", type=int, help="page number for Dividers (first divider page A)")
    ap.add_argument("--exhibits", type=int, help="page number for Exhibits parent")
    args = ap.parse_args()

    doc = fitz.open(args.input_pdf)
    toc = doc.get_toc() or []  # [level, title, page, ...]
    additions = []

    # helper: quick scan if user não passou páginas
    def find_page(markers):
        for pno in range(len(doc)):
            try:
                txt = doc.load_page(pno).get_text("text")
            except Exception:
                continue
            for m in markers:
                if m.lower() in txt.lower():
                    return pno + 1
        return None

    p_front    = args.front    or find_page(["Front Bundle", "OFFICER-ULTRA-MIN", "Cover Letter"])
    p_dividers = args.dividers or find_page(["EXHIBITS — A", "EXHIBITS - A", "Exhibits — A"])
    p_exhibits = args.exhibits or find_page(["### Exhibits", "EXHIBITS — A"])

    if p_front:    additions.append([1, "Front Matter", p_front])
    if p_dividers: additions.append([1, "Dividers",     p_dividers])
    if p_exhibits: additions.append([1, "Exhibits",     p_exhibits])

    # remove duplicatas pelos mesmos títulos de topo já existentes
    top_names = {t for _, t, *_ in additions}
    toc = [row for row in toc if not (row[0] == 1 and row[1] in top_names)]

    # garantir ordem Front, Dividers, Exhibits
    ordered = []
    for name in ("Front Matter", "Dividers", "Exhibits"):
        ordered += [r for r in additions if r[1] == name]

    new_toc = ordered + toc
    doc.set_toc(new_toc)
    doc.save(args.output_pdf)
    print(f"[OK] Top-level bookmarks added to: {args.output_pdf}")
    if ordered:
        print("     " + ", ".join(f"{r[1]} @ p.{r[2]}" for r in ordered))

if __name__ == "__main__":
    main()
