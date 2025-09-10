# add_bookmarks_pymupdf_autooffset.py
# Requisitos: pip install "pymupdf>=1.24.9,<1.25"
# Ajusta automaticamente o offset entre ExhibitMap_final.csv e o PDF final
# e grava EB2_NIW_Binder_FINAL_bookmarked.pdf com bookmarks clicáveis.

import os, csv, re, sys, collections
import fitz  # PyMuPDF

BASE = os.path.abspath(".")
FINAL_IN   = os.path.join(BASE, "EB2_NIW_Binder_FINAL.pdf")
FINAL_OUT  = os.path.join(BASE, "EB2_NIW_Binder_FINAL_bookmarked.pdf")
CSV_FINAL  = os.path.join(BASE, "ExhibitMap_final.csv")

for p in [FINAL_IN, CSV_FINAL]:
    if not os.path.exists(p):
        sys.exit(f"Arquivo não encontrado: {p}")

# 1) Leitura do PDF final
doc = fitz.open(FINAL_IN)
total_pages = doc.page_count  # 1-based nas TOC, 0-based internamente
print(f"[INFO] PDF final: {total_pages} páginas")

# 2) Ler CSV de exhibits (FINAL)
exhibits = []
max_end_csv = -1
with open(CSV_FINAL, "r", encoding="utf-8") as f:
    rdr = csv.DictReader(f)
    for row in rdr:
        ex  = (row.get("Exhibit") or row.get("exhibit") or "").strip()
        fn  = (row.get("File")    or row.get("file")    or "").strip()
        rng = (row.get("BinderRange") or row.get("binderrange") or "").strip()
        m = re.match(r"^\s*(\d+)\s*-\s*(\d+)\s*$", rng or "")
        if not m:
            # pula linhas sem range válido
            continue
        start, end = int(m.group(1)), int(m.group(2))
        max_end_csv = max(max_end_csv, end)
        exhibits.append({"exhibit": ex, "file": fn, "start": start, "end": end})

if not exhibits:
    doc.close()
    sys.exit("[ERRO] Nenhum exhibit com BinderRange válido no CSV.")

# 3) Calcular delta (ajuste automático)
# Se o CSV aponta para páginas além do total do PDF, subtraímos a diferença de todos.
delta = max_end_csv - total_pages
if delta != 0:
    print(f"[WARN] Ajustando offset automaticamente (delta={delta}).")
else:
    print("[INFO] Nenhum ajuste de offset necessário.")

for it in exhibits:
    it["start_adj"] = it["start"] - delta
    it["end_adj"]   = it["end"]   - delta
    # clamp de segurança
    if it["start_adj"] < 1: it["start_adj"] = 1
    if it["end_adj"]   < 1: it["end_adj"]   = 1
    if it["start_adj"] > total_pages: it["start_adj"] = total_pages
    if it["end_adj"]   > total_pages: it["end_adj"]   = total_pages

# 4) Anchors de seção
min_start = min(it["start_adj"] for it in exhibits)  # 1-based
front_anchor    = 1
dividers_anchor = max(1, min_start - 1)              # uma página antes dos exhibits
exhibits_anchor = max(1, min_start)

# 5) Anchors por letra (A/B/C/D/E) -> pegar a página inicial mais cedo daquela letra
by_letter = collections.defaultdict(list)
for it in exhibits:
    letter = (it["exhibit"].split("-")[0].strip().upper() or it["exhibit"][:1].upper())
    by_letter[letter].append(it)
letter_anchors = {}
for letter, items in by_letter.items():
    letter_anchors[letter] = min(x["start_adj"] for x in items)

# 6) Montar TOC: lista de [level, title, page]
toc = []
toc.append([1, "Front Matter", front_anchor])
toc.append([1, "Dividers (A/B/C/D/E)", dividers_anchor])

for letter in sorted(letter_anchors.keys()):
    toc.append([2, f"Exhibits — {letter}", letter_anchors[letter]])

toc.append([1, "Exhibits (FINAL)", exhibits_anchor])

# Um item por Exhibit
# Ordenado pela página ajustada
exhibits.sort(key=lambda x: x["start_adj"])
for it in exhibits:
    title = f"{it['exhibit']} — {it['file']} (pp. {it['start_adj']}-{it['end_adj']})"
    toc.append([2, title, it["start_adj"]])

# 7) Gravar TOC no PDF
doc.set_toc(toc)   # substitui / cria bookmarks
doc.save(FINAL_OUT)
doc.close()

print(f"[OK] Bookmarks gravados em: {FINAL_OUT}")
print(f"      Front Matter: p.{front_anchor}")
print(f"      Dividers:     p.{dividers_anchor}")
print(f"      Exhibits:     p.{exhibits_anchor}")
print(f"      Exhibits mapeados: {len(exhibits)}")
