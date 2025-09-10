#!/usr/bin/env python3
# add_front_divider_bookmarks_v3.py
import argparse, fitz, os, shutil, sys, tempfile

def main():
    ap = argparse.ArgumentParser(description="Add top-level Front/Dividers/Exhibits bookmarks using PyMuPDF set_toc().")
    ap.add_argument("input_pdf", help="Existing GROUPED binder")
    ap.add_argument("output_pdf", help="Output PDF path (should differ from input)")
    ap.add_argument("--front", type=int, default=1, help="Front Matter page (1-based)")
    ap.add_argument("--dividers", type=int, default=6, help="Dividers page (1-based)")
    ap.add_argument("--exhibits", type=int, default=2, help="Exhibits page (1-based)")
    args = ap.parse_args()

    same = os.path.abspath(args.input_pdf) == os.path.abspath(args.output_pdf)

    # open and fetch existing toc
    doc = fitz.open(args.input_pdf)
    toc = doc.get_toc() or []

    # prepend top-level nodes
    prepend = [
        [1, "Front Matter", args.front, 0],
        [1, "Dividers",     args.dividers, 0],
        [1, "Exhibits",     args.exhibits, 0],
    ]
    new_toc = prepend + toc

    # write to a new file (or temp if same path requested)
    out_path = args.output_pdf
    if same:
        fd, tmp = tempfile.mkstemp(suffix=".pdf")
        os.close(fd)
        out_path = tmp

    doc.set_toc(new_toc)
    # save with full rewrite (not incremental)
    doc.save(out_path, deflate=True, incremental=False)
    doc.close()

    if same:
        shutil.move(out_path, args.output_pdf)
    print("[OK] Top-level bookmarks added →", args.output_pdf)

if __name__ == "__main__":
    main()
