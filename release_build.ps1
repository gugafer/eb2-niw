param(
  [string]$Master            = "EB2_NIW_Petition_Package_MASTER.md",
  [string]$Css               = "print_serif.css",
  [string]$HtmlOut           = "index_protocol.html",
  [string]$PdfOut            = "index_protocol.pdf",
  [string]$BinderIn          = "EB2_NIW_Binder_FINAL_bookmarked.pdf",   # or your current binder
  [string]$BinderClean       = "EB2_NIW_Binder_FINAL_clean.pdf",
  [string]$ExhibitMap        = "ExhibitMap.csv",
  [string]$BinderGroupedOut  = "EB2_NIW_Binder_FINAL_GROUPED.pdf",
  [int]$Offset               = 0,
  [switch]$SkipClean
)

$ErrorActionPreference = "Stop"

# 1) Patch inline citations (§§1,2,4)
if(Test-Path ".\patch_citations_1_2_4.ps1"){
  .\patch_citations_1_2_4.ps1 -File $Master
} else {
  Write-Warning "patch_citations_1_2_4.ps1 not found — skipping."
}

# 2) Build HTML (serif) + PDF (wkhtmltopdf)
pandoc $Master --from=gfm --to=html5 --standalone `
  --toc --toc-depth=3 `
  --css="$Css" `
  --metadata title="EB-2 NIW Petition Package — Gustavo de Oliveira Ferreira" `
  -o $HtmlOut

$wk = (Get-Command wkhtmltopdf -ErrorAction SilentlyContinue)?.Source
if(-not $wk){ throw "wkhtmltopdf not found. Please install it." }

& $wk --enable-local-file-access `
  --margin-top 22mm --margin-bottom 20mm --margin-left 18mm --margin-right 18mm `
  "$HtmlOut" "$PdfOut"

Write-Host "[OK] Built $PdfOut"

# 3) Clean binder (optional but recommended if previous errors/xref)
if(-not $SkipClean){
  $qpdf = (Get-Command qpdf -ErrorAction SilentlyContinue)?.Source
  $mut  = (Get-Command mutool -ErrorAction SilentlyContinue)?.Source
  if($qpdf){
    & $qpdf --linearize "$BinderIn" "$BinderClean"
  } elseif($mut){
    & $mut clean -gg "$BinderIn" "$BinderClean"
  } else {
    Write-Warning "Neither qpdf nor mutool found — using input binder as-is."
    Copy-Item -LiteralPath $BinderIn -Destination $BinderClean -Force
  }
} else {
  Copy-Item -LiteralPath $BinderIn -Destination $BinderClean -Force
}

# 4) Grouped exhibit bookmarks from CSV
$py = (Get-Command python -ErrorAction SilentlyContinue)?.Source
if(-not $py){ throw "Python not found." }

& $py "add_grouped_exhibit_bookmarks_v2.py" `
  "$BinderClean" "$ExhibitMap" "$BinderGroupedOut" --offset $Offset

Write-Host "[OK] Final binder with grouped bookmarks: $BinderGroupedOut"
