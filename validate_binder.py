# save as: validate_binder.py
# run: python validate_binder.py "index_protocol.pdf" "EB2_NIW_Binder_FINAL_GROUPED.pdf"
import sys, fitz, re

ipdf = sys.argv[1]
bpdf = sys.argv[2]

def check_toc(doc, label):
    ok = True
    toc = doc.get_toc(simple=True)
    n   = doc.page_count
    for lvl, title, pno in toc:
        if pno < 1 or pno > n:
            print(f"[TOC] {label}: OUT-OF-RANGE p.{pno} — {title}")
            ok = False
    if ok:
        print(f"[TOC] {label}: OK ({len(toc)} entries)")
    return ok

def check_links(doc, label):
    ok = True
    for i in range(doc.page_count):
        for l in doc[i].get_links():
            if l.get("kind") == 2:    # internal
                p = l.get("page", -1)
                if p < 0 or p >= doc.page_count:
                    print(f"[LINK] {label}: bad link on p.{i+1} → page {p+1}")
                    ok = False
    if ok:
        print(f"[LINK] {label}: internal links OK")
    return ok

def check_exhibits_d(doc):
    # procura a mini-tabela Dos D-01..D-06
    text = ""
    for i in range(doc.page_count):
        text += doc[i].get_text("text") + "\n"
    rows = re.findall(r'\*\*D-(\d+)\*\*.*?\|\s*([0-9\-]+)\s*\|', text)
    if not rows:
        print("[EXH D] tabela não encontrada")
        return False
    print("[EXH D] encontrados:", ", ".join([f"D-{a}:{b}" for a,b in rows]))
    return True

ip = fitz.open(ipdf)
bp = fitz.open(bpdf)
try:
    t1 = check_toc(ip, "index_protocol")
    t2 = check_toc(bp, "binder")
    l1 = check_links(ip, "index_protocol")
    l2 = check_links(bp, "binder")
    dx = check_exhibits_d(bp)
    if all([t1,t2,l1,l2,dx]):
        print("[OK] Validação concluída (TOC/links/Exhibits D)")
finally:
    ip.close(); bp.close()
