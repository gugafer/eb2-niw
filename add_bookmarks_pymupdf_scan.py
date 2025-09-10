# add_bookmarks_pymupdf_scan.py
# Requisitos: pip install "pymupdf>=1.24.9,<1.25"
# - Reconstrói o PDF para evitar erros
# - Faz auto-offset do CSV -> PDF
# - Detecta as páginas reais dos separadores "EXHIBITS — A/B/C/D/E" via texto
# - Grava bookmarks clicáveis em EB2_NIW_Binder_FINAL_bookmarked.pdf

import os, sys, csv, re, collections
import fitz  # PyMuPDF

BASE = os.path.abspath(".")
FINAL_IN   = os.path.join(BASE, "EB2_NIW_Binder_FINAL.pdf")
FINAL_TMP  = os.path.join(BASE, "EB2_NIW_Binder_FINAL_rebuilt.pdf")
FINAL_OUT  = os.path.join(BASE, "EB2_NIW_Binder_FINAL_bookmarked.pdf")
CSV_FINAL  = os.path.join(BASE, "ExhibitMap_final.csv")

for p in [FINAL_IN, CSV_FINAL]:
    if not os.path.exists(p):
        sys.exit(f"[ERRO] Arquivo não encontrado: {p}")

# ---------- 1) REBUILD: copiar páginas para um PDF "limpo" ----------
src = fitz.open(FINAL_IN)
rebuilt = fitz.open()
rebuilt.insert_pdf(src)
rebuilt.save(FINAL_TMP, deflate=True, garbage=4)  # faxina profunda
rebuilt.close()
src.close()

# ---------- 2) Abrir o PDF reconstruído e ler total ----------
doc = fitz.open(FINAL_TMP)
total_pages = doc.page_count
print(f"[INFO] PDF reconstruído: {total_pages} páginas")

# ---------- 3) Ler CSV FINAL e aplicar auto-offset ----------
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
        max_end_csv = max(max_end_csv, end)
        exhibits.append({"exhibit": ex, "file": fn, "start": start, "end": end})

if not exhibits:
    doc.close()
    sys.exit("[ERRO] Nenhum BinderRange válido no CSV.")

delta = max_end_csv - total_pages
print(f"[INFO] Delta (CSV.max_end - total_pages) = {delta} (positivo -> CSV acima do PDF)")

for it in exhibits:
    it["start_adj"] = max(1, min(total_pages, it["start"] - delta))
    it["end_adj"]   = max(1, min(total_pages, it["end"]   - delta))

# ---------- 4) Detectar páginas dos DIVIDERS A..E pelo texto ----------
# Suporta "EXHIBITS — A" (em dash) e "EXHIBITS - A" (hyphen).
divider_regexes = {
    "A": re.compile(r"EXHIBITS\s*[—-]\s*A\b", re.I),
    "B": re.compile(r"EXHIBITS\s*[—-]\s*B\b", re.I),
    "C": re.compile(r"EXHIBITS\s*[—-]\s*C\b", re.I),
    "D": re.compile(r"EXHIBITS\s*[—-]\s*D\b", re.I),
    "E": re.compile(r"EXHIBITS\s*[—-]\s*E\b", re.I),
}
divider_pages = {}
for i in range(total_pages):  # 0-based
    txt = ""
    try:
        txt = doc.load_page(i).get_text("text")
    except Exception:
        continue
    for letter, rx in divider_regexes.items():
        if letter not in divider_pages and rx.search(txt or ""):
            divider_pages[letter] = i + 1  # -> 1-based para TOC

# Se não encontrou algum, ancore no menor start_adj daquele grupo (fallback)
by_letter = collections.defaultdict(list)
for it in exhibits:
    letter = (it["exhibit"].split("-")[0].strip().upper() or it["exhibit"][:1].upper())
    by_letter[letter].append(it)
for letter, items in by_letter.items():
    if letter not in divider_pages:
        divider_pages[letter] = min(x["start_adj"] for x in items)

# ---------- 5) Âncoras principais ----------
front_anchor    = 1
div_last = max(divider_pages.values()) if divider_pages else 1
candidates = [x["start_adj"] for x in exhibits if x["start_adj"] >= div_last + 1]
exhibits_anchor = min(candidates) if candidates else (div_last + 1)

# Dividers anchor: menor página entre A..E detectadas
dividers_anchor = min(divider_pages.values()) if divider_pages else max(1, exhibits_anchor - 1)

print("[INFO] Anchors:")
print("  Front Matter:", front_anchor)
print("  Dividers    :", dividers_anchor)
print("  Exhibits    :", exhibits_anchor)
for l in sorted(divider_pages.keys()):
    print(f"  Divider {l}   :", divider_pages[l])

# ---------- 6) Montar TOC ----------
toc = []
toc.append([1, "Front Matter", front_anchor])
toc.append([1, "Dividers (A/B/C/D/E)", dividers_anchor])
for letter in sorted(divider_pages.keys()):
    toc.append([2, f"Exhibits — {letter}", divider_pages[letter]])
toc.append([1, "Exhibits (FINAL)", exhibits_anchor])

exhibits.sort(key=lambda x: x["start_adj"])
for it in exhibits:
    title = f"{it['exhibit']} — {it['file']} (pp. {it['start_adj']}-{it['end_adj']})"
    toc.append([2, title, it["start_adj"]])

# ---------- 7) Gravar TOC no PDF reconstruído ----------
doc.set_toc(toc)
doc.save(FINAL_OUT, deflate=True, garbage=4)
doc.close()

# Remover temporário opcionalmente
try:
    os.remove(FINAL_TMP)
except Exception:
    pass

print(f"[OK] Bookmarks gravados em: {FINAL_OUT}")
