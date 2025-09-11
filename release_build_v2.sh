#!/usr/bin/env bash
set -euo pipefail
OFFSET="${1:-0}"

echo "[CHK] deps..."
command -v pandoc >/dev/null || { echo "pandoc missing"; exit 1; }
command -v wkhtmltopdf >/dev/null || { echo "wkhtmltopdf missing"; exit 1; }
command -v qpdf >/dev/null || { echo "qpdf missing"; exit 1; }
python -c "import fitz" >/dev/null 2>&1 || { echo "PyMuPDF (fitz) missing"; exit 1; }

echo "[1/6] Pandoc → HTML"
pandoc "EB2_NIW_Petition_Package_MASTER.md" --from=gfm --to=html5 --standalone --toc --toc-depth=3 \
  --css="print_serif.css" --metadata title="EB-2 NIW Petition Package — Gustavo de Oliveira Ferreira" \
  -o "index_protocol.html"

echo "[2/6] wkhtmltopdf → PDF"
wkhtmltopdf --enable-local-file-access \
  --margin-top 22mm --margin-bottom 20mm --margin-left 18mm --margin-right 18mm \
  "index_protocol.html" "index_protocol.pdf" >/dev/null

echo "[3/6] Linearize binder (if *_bookmarked exists)"
if [ -f "EB2_NIW_Binder_FINAL_bookmarked.pdf" ]; then
  qpdf --linearize "EB2_NIW_Binder_FINAL_bookmarked.pdf" "EB2_NIW_Binder_FINAL_clean.pdf"
fi

echo "[4/6] Grouped Exhibits from CSV"
python add_grouped_exhibit_bookmarks_v2.py "EB2_NIW_Binder_FINAL_clean.pdf" "ExhibitMap.csv" "EB2_NIW_Binder_FINAL_GROUPED.pdf" --offset "$OFFSET"

echo "[5/6] Sync Appendix B order ↔ LETTER_MAP"
if command -v pwsh >/dev/null 2>&1; then
  pwsh -NoProfile -File sync_appendix_b_order.ps1
else
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File sync_appendix_b_order.ps1
fi
echo "[5/6] Add top-level Front/Dividers/Exhibits"
python add_front_divider_bookmarks_v3.py "EB2_NIW_Binder_FINAL_GROUPED.pdf" "EB2_NIW_Binder_FINAL_TOPLEVEL.pdf" || echo "[WARN] top-level bookmarks step skipped"
mv -f "EB2_NIW_Binder_FINAL_TOPLEVEL.pdf" "EB2_NIW_Binder_FINAL_GROUPED.pdf"

echo "[6/6] Done"
echo "[OK] index_protocol.pdf and EB2_NIW_Binder_FINAL_GROUPED.pdf"
