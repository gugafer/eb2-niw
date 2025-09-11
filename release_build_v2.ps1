param([int]$Offset=0)
$ErrorActionPreference = "Stop"

Write-Host "[1/6] Pandoc → HTML"
pandoc "EB2_NIW_Petition_Package_MASTER.md" --from=gfm --to=html5 --standalone --toc --toc-depth=3 `
  --css="print_serif.css" --metadata title="EB-2 NIW Petition Package — Gustavo de Oliveira Ferreira" `
  -o "index_protocol.html"

Write-Host "[2/6] wkhtmltopdf → PDF"
& wkhtmltopdf --enable-local-file-access `
  --margin-top 22mm --margin-bottom 20mm --margin-left 18mm --margin-right 18mm `
  "index_protocol.html" "index_protocol.pdf" | Out-Null

Write-Host "[3/6] Linearize binder (if *_bookmarked exists)"
if(Test-Path "EB2_NIW_Binder_FINAL_bookmarked.pdf"){
  & qpdf --linearize "EB2_NIW_Binder_FINAL_bookmarked.pdf" "EB2_NIW_Binder_FINAL_clean.pdf"
}

Write-Host "[4/6] Grouped Exhibits from CSV"
python add_grouped_exhibit_bookmarks_v2.py "EB2_NIW_Binder_FINAL_clean.pdf" "ExhibitMap.csv" "EB2_NIW_Binder_FINAL_GROUPED.pdf" --offset $Offset

Write-Host "[5/6] Add top-level Front/Dividers/Exhibits"
Write-Host "[5/6] Sync Appendix B order ↔ LETTER_MAP"
$master = "EB2_NIW_Petition_Package_MASTER.md"
$index  = "index.md"
.\sync_appendix_b_order.ps1

# opcional: promover os _SYNCED para os arquivos “oficiais”
if (Test-Path "EB2_NIW_Petition_Package_MASTER._SYNCED.md") {
  Copy-Item "EB2_NIW_Petition_Package_MASTER._SYNCED.md" $master -Force
}
if (Test-Path "index._SYNCED.md") {
  Copy-Item "index._SYNCED.md" $index -Force
}

# Save to temp then move (avoid incremental-save error)
$Tmp = "EB2_NIW_Binder_FINAL_TOPLEVEL.pdf"
python add_front_divider_bookmarks_v3.py "EB2_NIW_Binder_FINAL_GROUPED.pdf" $Tmp
Move-Item -Force $Tmp "EB2_NIW_Binder_FINAL_GROUPED.pdf"

Write-Host "[6/6] Done"
Write-Host "[OK] index_protocol.pdf and EB2_NIW_Binder_FINAL_GROUPED.pdf"
