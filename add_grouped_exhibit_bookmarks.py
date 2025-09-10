# add_grouped_exhibit_bookmarks.py
# Uso:
#   python add_grouped_exhibit_bookmarks.py "EB2_NIW_Binder_FINAL_bookmarked.pdf" "EB2_NIW_Binder_FINAL_GROUPED.pdf"
#
# Pré-requisito: seu PDF já deve ter um TOC / bookmark "Exhibits".
# Se o seu PDF tiver índices “caprichosos”, rode antes um "clean" (ex.: mutool clean -gg in.pdf out.pdf).

import sys, fitz, re

if len(sys.argv) < 3:
    print("Uso: python add_grouped_exhibit_bookmarks.py IN.pdf OUT.pdf")
    sys.exit(1)

src, dst = sys.argv[1], sys.argv[2]
doc = fitz.open(src)

def find_page(doc, keywords, max_pages=100):
    """Procura a primeira página que contém QUALQUER keyword (case-insensitive)."""
    pats = [re.compile(k, re.I) for k in keywords]
    n = min(max_pages, len(doc))
    for i in range(n):
        try:
            txt = doc[i].get_text("text") or ""
        except Exception:
            continue
        for p in pats:
            if p.search(txt):
                return i + 1  # TOC usa 1-based
    return None

# 1) Ler TOC existente
toc = doc.get_toc(simple=False)  # lista de itens: [level, title, page, ...]
if not toc:
    print("[ERRO] Este PDF não tem TOC/bookmarks ainda. Gere-os antes.")
    sys.exit(2)

# 2) Encontrar "Exhibits" (case-insensitive)
ex_idx = None
for i, row in enumerate(toc):
    title = (row[1] or "").strip()
    if re.search(r"^exhibits$", title, re.I):
        ex_idx = i
        break

if ex_idx is None:
    print("[ERRO] Não encontrei um item 'Exhibits' no TOC.")
    sys.exit(3)

ex_level, ex_page = toc[ex_idx][0], toc[ex_idx][2]

# 3) Encontrar páginas-alvo dos divisores A..E (por texto no PDF)
#    Se o seu binder tem "Divider A", “Divider B” etc., estas chaves bastam.
#    Ajuste as palavras conforme seus divisores.
page_A = find_page(doc, [r"Divider A", r"EXHIBITS\s*—\s*A"])
page_B = find_page(doc, [r"Divider B", r"EXHIBITS\s*—\s*B"])
page_C = find_page(doc, [r"Divider C", r"EXHIBITS\s*—\s*C"])
page_D = find_page(doc, [r"Divider D", r"EXHIBITS\s*—\s*D"])
page_E = find_page(doc, [r"Divider E", r"EXHIBITS\s*—\s*E"])

# fallback: se algum não for achado, aponta para a própria âncora de Exhibits
def safe(p): 
    return p if (p and 1 <= p <= len(doc)) else ex_page

page_A, page_B, page_C, page_D, page_E = map(safe, [page_A, page_B, page_C, page_D, page_E])

# 4) Construir os novos itens filhos
group_level = ex_level + 1
groups = [
    [group_level, "A — Credentials & Threshold EB-2",                     page_A],
    [group_level, "B — Industry & Workforce Evidence",                    page_B],
    [group_level, "C — Standards & Compliance (NIST/FedRAMP/SBOM)",       page_C],
    [group_level, "D — National Security / Critical Infrastructure",      page_D],
    [group_level, "E — Letters of Support & Affidavits",                  page_E],
]

# 5) Inserir os grupos LOGO APÓS o item “Exhibits”
toc_new = []
for i, row in enumerate(toc):
    toc_new.append([row[0], row[1], row[2]])
    if i == ex_idx:
        # injeta os filhos aqui
        toc_new.extend(groups)

# 6) Gravar TOC e salvar
doc.set_toc(toc_new)
doc.save(dst)
doc.close()
print("[OK] Grupos A/B/C/D/E adicionados sob 'Exhibits'.")
