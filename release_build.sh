#!/usr/bin/env bash
set -euo pipefail

OFFSET="${1:-0}"
IN_MD="EB2_NIW_Petition_Package_MASTER.md"
CSS="print_serif.css"

echo "[CHK] deps..."
for cmd in pandoc wkhtmltopdf python qpdf; do
  command -v "$cmd" >/dev/null 2>&1 || echo "[WARN] $cmd not found (continuing if not needed now)"
done

echo "[1/6] Pandoc → HTML"
pandoc "$IN_MD" --from=gfm --to=html5 --standalone --toc --toc-depth=3 \
  --css="$CSS" --metadata title="EB-2 NIW Petition Package — Gustavo de Oliveira Ferreira" \
  -o "index_protocol.html"

echo "[2/6] wkhtmltopdf → PDF"
wkhtmltopdf --enable-local-file-access \
  --margin-top 22mm --margin-bottom 20mm --margin-left 18mm --margin-right 18mm \
  "index_protocol.html" "index_protocol.pdf"

echo "[3/6] Linearize binder (se existir *_bookmarked)"
if [[ -f "EB2_NIW_Binder_FINAL_bookmarked.pdf" ]]; then
  qpdf --linearize "EB2_NIW_Binder_FINAL_bookmarked.pdf" "EB2_NIW_Binder_FINAL_clean.pdf"
fi

echo "[4/6] Grouped Exhibits from CSV"
python add_grouped_exhibit_bookmarks_v2.py "EB2_NIW_Binder_FINAL_clean.pdf" \
  "ExhibitMap.csv" "EB2_NIW_Binder_FINAL_GROUPED.pdf" --offset "$OFFSET"

echo "[5/6] Add top-level Front/Dividers/Exhibits"
python add_front_divider_bookmarks_v2.py "EB2_NIW_Binder_FINAL_GROUPED.pdf" \
  "EB2_NIW_Binder_FINAL_GROUPED.pdf" --front 1 --dividers 6 --exhibits 2 || \
  echo "[WARN] Could not add top-level bookmarks (check PyMuPDF)."

echo "[6/6] Done"
echo "[OK] index_protocol.pdf and EB2_NIW_Binder_FINAL_GROUPED.pdf"
