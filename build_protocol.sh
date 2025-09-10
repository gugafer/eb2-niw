#!/usr/bin/env bash
set -euo pipefail
MASTER="EB2_NIW_Petition_Package_MASTER.md"
HTML="index_protocol.html"
PDF="index_protocol.pdf"
CSS="print_serif.css"

pandoc "$MASTER" --from=gfm --to=html5 --standalone \
  --toc --toc-depth=3 \
  --css="$CSS" \
  --metadata title="EB-2 NIW Petition Package — Gustavo de Oliveira Ferreira" \
  -o "$HTML"

wkhtmltopdf --enable-local-file-access \
  --margin-top 22mm --margin-bottom 20mm --margin-left 18mm --margin-right 18mm \
  "$HTML" "$PDF"

echo "[OK] Built $PDF"
