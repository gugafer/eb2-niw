# remove_link_annots_v2.py
# Remove TODAS as anotações de link (URI/GoTo/etc.) de um PDF.
# Uso:
#   python remove_link_annots_v2.py input.pdf output.pdf

import sys, fitz

def main():
    if len(sys.argv) < 3:
        print("Usage: python remove_link_annots_v2.py input.pdf output.pdf")
        sys.exit(1)
    src, dst = sys.argv[1], sys.argv[2]
    doc = fitz.open(src)
    rm = 0
    for page in doc:
        annot = page.first_annot
        while annot:
            nxt = annot.next
            if annot.type[0] == fitz.PDF_ANNOT_LINK:
                page.delete_annot(annot)
                rm += 1
            annot = nxt
    doc.save(dst)
    doc.close()
    print(f"[OK] Removidos {rm} links → {dst}")

if __name__ == "__main__":
    main()
