#!/usr/bin/env python3
"""
add_front_divider_bookmarks.py
Cria bookmarks raiz "Front Matter", "Dividers", "Exhibits".

Uso:
  python add_front_divider_bookmarks.py IN.pdf OUT.pdf \
    --front 1 --dividers 6 --exhibits 2

Requer: pip install pymupdf
"""
import argparse, sys
try:
    import fitz  # PyMuPDF
except Exception as e:
    print("[ERR] PyMuPDF não encontrado. Instale com: pip install pymupdf", file=sys.stderr)
    sys.exit(1)

def clamp_page(p, total):
    return max(1, min(p, total))

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("inp")
    ap.add_argument("out")
    ap.add_argument("--front", type=int, default=1, help="página (1-based) de Front Matter")
    ap.add_argument("--dividers", type=int, default=6, help="página (1-based) de Dividers")
    ap.add_argument("--exhibits", type=int, default=2, help="página (1-based) de Exhibits (bloco)")
    args = ap.parse_args()

    doc = fitz.open(args.inp)
    total = doc.page_count

    p_front = clamp_page(args.front, total) - 1
    p_div   = clamp_page(args.dividers, total) - 1
    p_exh   = clamp_page(args.exhibits, total) - 1

    # Apaga TOC atual e recria apenas os três topos
    doc.set_toc([])

    # Nível 1 (root) — bookmark level = 1
    doc.add_outline("Front Matter", p_front, 1)
    doc.add_outline("Dividers",     p_div,   1)
    doc.add_outline("Exhibits",     p_exh,   1)

    doc.save(args.out)
    print(f"[OK] Root bookmarks gravados em: {args.out} (total páginas: {total})")

if __name__ == "__main__":
    main()
