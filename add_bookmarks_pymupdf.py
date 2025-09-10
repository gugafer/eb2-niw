# add_bookmarks_pymupdf.py
# Requisitos: pip install "pymupdf>=1.24.9,<1.25"
# Gera EB2_NIW_Binder_FINAL_bookmarked.pdf com TOC / bookmarks clicáveis.

import csv, re, os, sys
import fitz  # PyMuPDF

BASE = os.path.abspath(".")
FINAL_IN   = os.path.join(BASE, "EB2_NIW_Binder_FINAL.pdf")
FINAL_OUT  = os.path.join(BASE, "EB2_NIW_Binder_FINAL_bookmarked.pdf")
CSV_FINAL  = os.path.join(BASE, "ExhibitMap_final.csv")
PROTO_PDF  = os.path.join(BASE, "index_protocol.pdf")
DIV_PDF    = os.path.join(BASE, "exhibit_dividers.pdf")

for p in [FINAL_IN, CSV_FINAL, PROTO_PDF, DIV_PDF]:
    if not os.path.exists(p):
        sys.exit(f"Arquivo não encontrado: {p}")

# 1) Páginas do Front Matter e Dividers
with fitz.open(PROTO_PDF) as d: proto_pages = d.page_count
with fitz.open(DIV_PDF)   as d: div_pages   = d.page_count

# 2) Ler Exhibits (ranges FINAIS, já com offset aplicado)
exhibits = []
with open(CSV_FINAL, "r", encoding="utf-8") as f:
    rdr = csv.DictReader(f)
    for row in rdr:
        ex  = (row.get("Exhibit") or row.get("exhibit") or "").strip()
        fn  = (row.get("File")    or row.get("file")    or "").strip()
        rng = (row.get("BinderRange") or row.get("binderrange") or "").strip()
        m = re.match(r"^\s*(\d+)\s*-\s*(\d+)\s*$", rng)
        if not m: 
            continue
        start, end = int(m.group(1)), int(m.group(2))
        # PyMuPDF usa páginas 1-based na TOC
        exhibits.append((ex, fn, start, end))

# 3) Montar TOC: lista de [level, title, page]
toc = []
# Nível 1: Front / Dividers / Exhibits
toc.append([1, "Front Matter", 1])                    # começos em 1
toc.append([1, "Dividers (A/B/C/D/E)", proto_pages+1])
# Subitens A..E (assumindo 1 página por divider na ordem A..E)
letters = ["A","B","C","D","E"]
for i, letter in enumerate(letters):
    toc.append([2, f"Exhibits — {letter}", proto_pages + i + 1])

toc.append([1, "Exhibits (FINAL)", proto_pages + div_pages + 1])

# Nível 2: cada Exhibit
for ex, fn, start, end in exhibits:
    title = f"{ex} — {fn} (pp. {start}-{end})"
    toc.append([2, title, start])

# 4) Gravar TOC no PDF final
doc = fitz.open(FINAL_IN)
doc.set_toc(toc)          # substitui / cria os bookmarks
doc.save(FINAL_OUT)
doc.close()

print(f"OK: {FINAL_OUT}")
print(f"- Front Matter: {proto_pages} páginas")
print(f"- Dividers:     {div_pages} páginas")
print(f"- Exhibits:     {len(exhibits)} itens")
