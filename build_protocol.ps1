param(
  [string]$Master = "EB2_NIW_Petition_Package_MASTER.md",
  [string]$Html   = "index_protocol.html",
  [string]$Pdf    = "index_protocol.pdf",
  [string]$Css    = "print_serif.css"
)

$ErrorActionPreference = "Stop"

# 1) HTML (serif)
pandoc $Master --from=gfm --to=html5 --standalone `
  --toc --toc-depth=3 `
  --css="$Css" `
  --metadata title="EB-2 NIW Petition Package — Gustavo de Oliveira Ferreira" `
  -o $Html

# 2) PDF via wkhtmltopdf
$wk = (Get-Command wkhtmltopdf -ErrorAction SilentlyContinue)?.Source
if(-not $wk){ throw "wkhtmltopdf not found. Install it or use Option 2 below." }

& $wk --enable-local-file-access `
  --margin-top 22mm --margin-bottom 20mm --margin-left 18mm --margin-right 18mm `
  "$Html" "$Pdf"

Write-Host "[OK] Built $Pdf"
