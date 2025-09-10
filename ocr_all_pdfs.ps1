Param(
  [string]$Root = ".",
  [switch]$Recursive = $true,
  [switch]$SkipText = $true,     # só aplica OCR se não houver texto
  [ValidateSet("pdfa","pdf")]
  [string]$OutType = "pdfa",
  [ValidateSet("0","1","2","3")]
  [string]$Optimize = "2"
)

# Verificação do ocrmypdf
$ocr = Get-Command ocrmypdf -ErrorAction SilentlyContinue
if (-not $ocr) {
  Write-Host "Erro: ocrmypdf não encontrado. Instale com: pip install ocrmypdf" -ForegroundColor Red
  exit 1
}

# Coleta de PDFs
$pattern = "*.pdf"
$search = if ($Recursive) { Get-ChildItem -Path $Root -Recurse -File -Include $pattern } `
          else { Get-ChildItem -Path $Root -File -Include $pattern }

foreach ($f in $search) {
  try {
    $out = Join-Path $f.DirectoryName ($f.BaseName + "_ocr.pdf")
    $args = @()
    if ($SkipText) { $args += "--skip-text" }
    $args += @("--optimize", $Optimize, "--output-type", $OutType, "--deskew")
    $args += @($f.FullName, $out)

    Write-Host ("[OCR] {0}" -f $f.FullName) -ForegroundColor Cyan
    & ocrmypdf @args

    if (Test-Path $out) {
      Write-Host ("[OK ] Gerado: {0}" -f $out) -ForegroundColor Green
    } else {
      Write-Host ("[!! ] Falhou: {0}" -f $f.FullName) -ForegroundColor Yellow
    }
  } catch {
    Write-Host ("[ERR] {0} -> {1}" -f $f.FullName, $_.Exception.Message) -ForegroundColor Red
  }
}

Write-Host "Concluído." -ForegroundColor Green
