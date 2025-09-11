# save as: extract_letter_meta.py
# run: python extract_letter_meta.py letters_dir "EB2_NIW_Binder_FINAL_GROUPED.pdf"
import sys, re, os, datetime, fitz

RX_DATE = re.compile(r'(?:(January|February|March|April|May|June|July|August|September|October|November|December)\s+\d{1,2},\s+\d{4})|(\d{1,2}/\d{1,2}/\d{2,4})')
RX_ORG  = re.compile(r'\b(?:Company|Organization|Organização|Org|Employer|Employed at|at)\b[:\s]+(.{2,80})', re.I)
RX_ROLE = re.compile(r'\b(?:Title|Cargo|Position|Role)\b[:\s]+(.{2,80})', re.I)

order = [
  ("D-01","recommendation-letter-Gaurav-update-latest-signed.pdf"),
  ("D-02","recommendation-letter-Babita-update-latest-signed.pdf"),
  ("D-03","recommendation-letter-cognizant-carlos.pdf"),
  ("D-04","recommendation-letter-phillip-bmg.pdf"),
  ("D-05","recommendation-letter-Bruno_english_serasa.pdf"),
  ("D-06","recommendation-letter-JoséRicardoFerrazza_latest.pdf"),
]

def first_text(path):
    doc = fitz.open(path)
    try:
        return doc[0].get_text("text")
    finally:
        doc.close()

def guess(meta_text, fallback_mtime):
    org = role = date = "—"
    m = RX_ORG.search(meta_text)
    if m: org = m.group(1).strip().rstrip(",.;")
    m = RX_ROLE.search(meta_text)
    if m: role = m.group(1).strip().rstrip(",.;")
    m = RX_DATE.search(meta_text)
    if m:
        date = next(g for g in m.groups() if g) or "—"
    else:
        date = datetime.datetime.fromtimestamp(fallback_mtime).strftime("%Y-%m-%d")
    return org, role, date

def lookup_pages(binder_pdf, filename):
    doc = fitz.open(binder_pdf)
    # heurística: procurar o nome do arquivo no texto do índice dos Exhibits D
    # (o seu binder lista a mini-tabela “Exhibits D — Recommendation Letters”)
    pages = "—"
    try:
        for p in range(len(doc)):
            t = doc[p].get_text("text")
            if filename in t:
                # linha do índice contém “| filename | Páginas | 928-929 |”
                m = re.search(rf'\|\s*\*\*D-\d+\*\*\s*\|\s*{re.escape(filename)}\s*\|\s*\d+\s*\|\s*([\d-]+)\s*\|', t)
                if m:
                    pages = m.group(1)
                    break
    finally:
        doc.close()
    return pages

if __name__ == "__main__":
    letters_dir = sys.argv[1]
    binder_pdf  = sys.argv[2]
    rows = []
    for code, fname in order:
        path = os.path.join(letters_dir, fname)
        try:
            txt  = first_text(path)
        except Exception:
            txt  = ""
        st   = os.stat(path)
        org, role, date = guess(txt, st.st_mtime)
        pages = lookup_pages(binder_pdf, fname)
        rows.append((code, fname, org, role, date, pages))
    print("| Code | File | Organization | Role | Signed date | Pages |")
    print("|:---:|------|--------------|------|------------:|:----:|")
    for code,f,org,role,date,pages in rows:
        print(f"| {code} | {f} | {org} | {role} | {date} | {pages} |")
