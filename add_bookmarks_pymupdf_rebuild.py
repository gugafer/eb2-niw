# add_bookmarks_pymupdf_rebuild.py
# Requisitos: pip install "pymupdf>=1.24.9,<1.25"
# Reconstrói o PDF (insert_pdf) e aplica TOC com ajuste automático de offset.

import os, csv, re, sys, collections
import fitz  # PyMuPDF

BASE = os.path.abspath(".")
FINAL_IN   = os.path.join(BASE, "EB2_NIW_Binder_FINAL.pdf")
FINAL_OUT  = os.path.join(BASE, "EB2_NIW_Binder_FINAL_bookmarked.pdf")
CSV_FINAL  = os.path.join(BASE, "ExhibitMap_final.csv")

for p in [FINAL_IN, CSV_FINAL]:
    if not os.path.exists(p):
        sys.exit(f"[ERRO] Arquivo não encontrado: {p}")

# 1) Abrir PDF final e ler total de páginas
src = fitz.open(FINAL_IN)
total_pages = src.page_count
print(f"[INFO] PDF final: {total_pages} páginas")

# 2) Ler CSV FINAL (start-end já no binder “final” que você usa)
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
            continue
        start, end = int(m.group(1)), int(m.group(2))
        exhibits.append({"exhibit": ex, "file": fn, "start": start, "end": end})
        if end > max_end_csv:
            max_end_csv = end

if not exhibits:
    src.close()
    sys.exit("[ERRO] Nenhum BinderRange válido no CSV.")

# 3) Auto-offset se o CSV extrapola o total (seu caso reportado: delta=227)
delta = max_end_csv - total_pages
print(f"[INFO] Delta calculado (CSV.max_end - total_pages) = {delta}")
for it in exhibits:
    it["start_adj"] = max(1, min(total_pages, it["start"] - delta))
    it["end_adj"]   = max(1, min(total_pages, it["end"]   - delta))

# 4) Âncoras principais
min_start = min(it["start_adj"] for it in exhibits)  # 1-based para TOC
front_anchor    = 1
dividers_anchor = max(1, min_start - 1)
exhibits_anchor = max(1, min_start)

# 5) Âncoras por letra (A/B/C/D/E) → primeira página daquele grupo
by_letter = collections.defaultdict(list)
for it in exhibits:
    letter = (it["exhibit"].split("-")[0].strip().upper() or it["exhibit"][:1].upper())
    by_letter[letter].append(it)
letter_anchors = {L: min(x["start_adj"] for x in items) for L, items in by_letter.items()}

# 6) Montar TOC (lista [level, title, page])
toc = []
toc.append([1, "Front Matter", front_anchor])
toc.append([1, "Dividers (A/B/C/D/E)", dividers_anchor])
for letter in sorted(letter_anchors.keys()):
    toc.append([2, f"Exhibits - {letter}", letter_anchors[letter]])
toc.append([1, "Exhibits (FINAL)", exhibits_anchor])
exhibits.sort(key=lambda x: x["start_adj"])
for it in exhibits:
    # Evitar caracteres exóticos se seu viewer tiver problemas: use "-" simples
    title = f"{it['exhibit']} - {it['file']} (pp. {it['start_adj']}-{it['end_adj']})"
    toc.append([2, title, it["start_adj"]])

# 7) RECONSTRUIR o PDF e aplicar TOC (evita erros de estrutura / incremental)
dst = fitz.open()          # novo doc
dst.insert_pdf(src)        # copia páginas, “limpando” estruturas problemáticas
dst.set_toc(toc)           # aplica bookmarks
# Salvar com limpeza / recompressão
dst.save(FINAL_OUT, deflate=True, garbage=4)  # garbage=4 faz limpeza profunda
dst.close()
src.close()

print(f"[OK] Bookmarks gravados em: {FINAL_OUT}")
print(f"     Front Matter: p.{front_anchor}")
print(f"     Dividers:     p.{dividers_anchor}")
print(f"     Exhibits:     p.{exhibits_anchor}")
print(f"     Exhibits mapeados: {len(exhibits)}")
