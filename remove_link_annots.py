import sys, fitz

if len(sys.argv) < 3:
    print("usage: python remove_link_annots.py input.pdf output.pdf")
    sys.exit(1)

inp, outp = sys.argv[1], sys.argv[2]
doc = fitz.open(inp)
for page in doc:
    annots = list(page.annots() or [])
    for a in annots:
        if a.type[0] == fitz.PDF_ANNOT_LINK:
            page.delete_annot(a)
doc.save(outp)
print(f"[OK] Links removidos → {outp}")
