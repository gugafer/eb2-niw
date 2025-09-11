# remove_bad_goto_links.py
# Usage:
#   python remove_bad_goto_links.py "input.pdf" "output.pdf"
import sys, fitz

def main(inp, outp):
    doc = fitz.open(inp)
    removed = 0
    for pno in range(doc.page_count):
        page = doc[pno]
        for annot in list(page.annots() or []):
            if annot.type[0] == fitz.PDF_ANNOT_LINK:
                info = annot.info
                try:
                    # Check link destination
                    uri = annot.uri
                except Exception:
                    uri = None
                # For 'goto' links, PyMuPDF exposes a 'dest' in the xref dictionary
                # A safer approach is to inspect the link dict via get_links()
                bad = False
                for l in page.get_links():
                    if l.get("from") is None:
                        continue
                    if l.get("kind") == 1:  # 1 = internal 'goto'
                        if l.get("page", 1) == 0:
                            bad = True
                            break
                if bad:
                    page.delete_annot(annot)
                    removed += 1
        # Also sweep link rectangles from get_links() with kind==1 and page==0
        # by re-inserting all good links (optional). For print, simply removing annots is enough.
    doc.save(outp)
    print(f"[OK] Removed {removed} bad 'goto' links → {outp}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python remove_bad_goto_links.py input.pdf output.pdf")
        sys.exit(2)
    main(sys.argv[1], sys.argv[2])
