# add_bookmarks.py
# Gera EB2_NIW_Binder_FINAL_bookmarked.pdf com sumário clicável
# Requisitos: pip install PyPDF2

import csv, re, os
from PyPDF2 import PdfReader, PdfWriter

BASE = os.path.abspath(".")
FINAL_IN   = os.path.join(BASE, "EB2_NIW_Binder_FINAL.pdf")
FINAL_OUT  = os.path.join(BASE, "EB2_NIW_Binder_FINAL_bookmarked.pdf")
CSV_FINAL  = os.path.join(BASE, "ExhibitMap_final.csv")
PROTO_PDF  = os.path.join(BASE, "index_protocol.pdf")
DIV_PDF    = os.path.join(BASE, "exhibit_dividers.pdf")

for p in [FINAL_IN, CSV_FINAL, PROTO_PDF, DIV_PDF]:
    if not os.path.exists(p):
        raise SystemExit(f"Arquivo não encontrado: {p}")

# Contar páginas do front matter e das divisórias (para ancorar os bookmarks de seção)
proto_pages = len(PdfReader(PROTO_PDF).pages)
div_pages   = len(PdfReader(DIV_PDF).pages)

# Ler os exhibits com ranges finais (já offsetados)
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
        exhibits.append({"exhibit": ex, "file": fn, "start": start, "end": end})

# Ordenar por página inicial
exhibits.sort(key=lambda x: x["start"])

# Copiar o PDF inteiro de forma eficiente
writer = PdfWriter()
writer.append(FINAL_IN, import_outline=False)  # não importa outlines antigos

# Helper compatível com diferentes versões do PyPDF2
def add_bm(title, page_index, parent=None):
    try:
        return writer.add_outline_item(title, page_index, parent=parent)
    except Exception:
        return writer.addBookmark(title, page_index, parent)

# Top-level
bm_front = add_bm("Front Matter", 0)
bm_div   = add_bm("Dividers (A/B/C/D/E)", proto_pages)            # 0-based
bm_exhs  = add_bm("Exhibits (FINAL)", proto_pages + div_pages)

# Subtópicos dos separadores (uma página cada, na ordem A/B/C/D/E)
letters = ["A","B","C","D","E"]
for i, letter in enumerate(letters):
    add_bm(f"Exhibits — {letter}", proto_pages + i, parent=bm_div)

# Itens para cada Exhibit (usa página inicial do range FINAL)
for item in exhibits:
    page_idx = max(0, item["start"] - 1)  # 1-based -> 0-based
    title = f"{item['exhibit']} — {item['file']} (pp. {item['start']}-{item['end']})"
    add_bm(title, page_idx, parent=bm_exhs)

with open(FINAL_OUT, "wb") as f:
    writer.write(f)

print(f"OK: {FINAL_OUT}")
