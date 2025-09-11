
import sys
import fitz  # PyMuPDF

def is_bad_link(annot):
    try:
        info = annot.info
        if info.get("type") != 1:  # type 1 is 'link'
            return False
        uri = annot.uri
        if uri:  # external link; keep
            return False
        # For internal links, check link destinations
        for l in annot.links():
            kind = l.get("kind")
            if kind == fitz.LINK_GOTO:
                # dest 'page' is 0-based; dest[0] is page number
                dest = l.get("page", None)
                if dest is None:
                    return True
                if int(dest) <= 0:  # page 0 or negative considered bad here
                    return True
        return False
    except Exception:
        return False

def main():
    if len(sys.argv) < 3:
        print("Usage: python remove_bad_goto_links_v2.py INPUT.pdf OUTPUT.pdf")
        sys.exit(1)
    src, dst = sys.argv[1], sys.argv[2]
    doc = fitz.open(src)
    removed = 0
    for page in doc:
        ann = page.first_annot
        to_delete = []
        while ann:
            if is_bad_link(ann):
                to_delete.append(ann)
            ann = ann.next
        for a in to_delete:
            a.delete()
            removed += 1
    doc.save(dst)
    print(f"[OK] Removed {removed} bad 'goto' links → {dst}")

if __name__ == "__main__":
    main()
