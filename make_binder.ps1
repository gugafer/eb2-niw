Param(
  [string]$Master = "EB2_NIW_Petition_Package_MASTER.pdf",
  [string]$Out    = (Join-Path $PWD 'EB2_NIW_FULL-BINDER.pdf'),
  [string]$Tmp    = "TMP_SPLIT",
  [switch]$Simple,
  [switch]$DryRun
)

# Melhorar Unicode no console
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

# ===== LISTAS =====
$AnnexA = @(
  "Biden-Harris-Administrations-National-Security-Strategy-10.2022.pdf",
  "CMR-PREX23-00185928.pdf",
  "Treasury-Cloud-Report.pdf"
)
$AnnexB = @(
  "comptia-it-industry-outlook-2025.pdf",
  "comptia-state-of-the-tech-workforce-2024.pdf",
  "05-2025-CompTIA Tech Jobs Report.pdf",
  "Computer Network Architects _ Occupational Outlook Handbook_ _ U.S. Bureau of Labor Statistics-1.pdf",
  "Computer Network Architects _ Occupational Outlook Handbook_ _ U.S. Bureau of Labor Statistics-2.pdf",
  "Computer Network Architects _ Occupational Outlook Handbook_ _ U.S. Bureau of Labor Statistics-3.pdf",
  "WEF_Future_of_Jobs_Report_2025.pdf",
  "Skillsoft-IT-Skills-and-Salary-Report-2023.pdf"
)
$AnnexD = @(
  "Gustavo Ferreira AEE evaluation.pdf",
  "ENG_Gustavo_Ferreira_2025.docx.pdf"
)
$AnnexE = @(
  "Letter_of_Recommendation_JoséRicardoFerrazza_latest (1).pdf",
  "RECOMMENDATION LETTER COGNIZANT_unlocked.pdf"
)
$AnnexG = @(
  "carrear pathway 2025.drawio.pdf",
  "CTPSDigital_unlocked.pdf",
  "Demonstrativo de Pagamento-latest-month.pdf"
)

function Test-Encrypted([string]$f) {
  try {
    $pi = & pdfinfo $f 2>$null
    return ($pi -match '(?i)^Encrypted:\s*yes')
  } catch { return $false }
}
$merge = @()
function Add-File([string]$f) {
  if ([string]::IsNullOrWhiteSpace($f)) { return }
  if (-not (Test-Path -LiteralPath $f)) { Write-Warning "Arquivo não encontrado: $f"; return }
  if (Test-Encrypted $f) { Write-Warning "PULANDO criptografado: $f"; return }
  $script:merge += $f
}

if (-not (Test-Path -LiteralPath $Master)) { throw "MASTER não encontrado: $Master" }
if (Test-Path -LiteralPath $Tmp) { Remove-Item -LiteralPath $Tmp -Recurse -Force }
New-Item -ItemType Directory -Path $Tmp | Out-Null
& pdfseparate $Master "$Tmp/MASTER_%03d.pdf"

$haveAnchors = (Test-Path "$Tmp/MASTER_011.pdf") -and (Test-Path "$Tmp/MASTER_012.pdf") -and (Test-Path "$Tmp/MASTER_013.pdf")

if ($Simple -or -not $haveAnchors) {
  Write-Host "[INFO] Modo SIMPLES (concatenação)."
  Add-File $Master
  $AnnexA | ForEach-Object { Add-File $_ }
  $AnnexB | ForEach-Object { Add-File $_ }
  $AnnexD | ForEach-Object { Add-File $_ }
  $AnnexE | ForEach-Object { Add-File $_ }
  $AnnexG | ForEach-Object { Add-File $_ }
} else {
  Write-Host "[INFO] Modo INTERCALADO (âncoras 011/012/013)."
  1..10 | ForEach-Object { $p = "{0:d3}" -f $_; Add-File "$Tmp/MASTER_$p.pdf" }

  Add-File "$Tmp/MASTER_011.pdf"
  $AnnexA[0..2] | ForEach-Object { Add-File $_ }
  $AnnexB[0..1] | ForEach-Object { Add-File $_ }

  Add-File "$Tmp/MASTER_012.pdf"
  $AnnexB[2..($AnnexB.Count-1)] | ForEach-Object { Add-File $_ }
  $AnnexD | ForEach-Object { Add-File $_ }
  $AnnexE | ForEach-Object { Add-File $_ }

  Add-File "$Tmp/MASTER_013.pdf"
  $AnnexG | ForEach-Object { Add-File $_ }

  Get-ChildItem "$Tmp\MASTER_*.pdf" | Sort-Object Name | ForEach-Object {
    $n = [int]($_.BaseName.Split('_')[-1])
    if ($n -gt 13) { Add-File $_.FullName }
  }
}

# Preview
$preview = ($merge | ForEach-Object { '"' + $_ + '"' }) -join ' '
Write-Host "[INFO] pdfunite $preview `"$Out`""

if ($DryRun) { Write-Host "[DRY-RUN] Não mesclado."; exit 0 }

& pdfunite @merge $Out
if ($LASTEXITCODE -ne 0) { throw "pdfunite falhou com código $LASTEXITCODE" }

Remove-Item -LiteralPath $Tmp -Recurse -Force
Write-Host "[OK] Gerado: $Out"
