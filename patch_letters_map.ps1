param(
  [Parameter(Mandatory=$true)][string]$File
)

# backup + carga
$stamp = (Get-Date).ToString("yyyyMMddHHmmss")
$bak   = "$File.bak_$stamp"
Copy-Item $File $bak -Force
$text = Get-Content $File -Raw -Encoding UTF8

# ----- 1) Mapeamento fixo (ajuste se renomear PDFs) -----
$letters = @(
  @{ code="D-01"; name="Babita";                 file="recommendation-letter-Babita-update-latest-signed.pdf" },
  @{ code="D-02"; name="Bruno";                  file="recommendation-letter-Bruno_english_serasa.pdf" },
  @{ code="D-03"; name="Carlos";                 file="recommendation-letter-cognizant-carlos.pdf" },
  @{ code="D-04"; name="Gaurav";                 file="recommendation-letter-Gaurav-update-latest-signed.pdf" },
  @{ code="D-05"; name="José Ricardo Ferrazza";  file="recommendation-letter-JoséRicardoFerrazza_latest.pdf" },
  @{ code="D-06"; name="Phillip";                file="recommendation-letter-phillip-bmg.pdf" }
)

# ----- 2) Bloco LETTER_MAP (idempotente) -----
$mapStart = "<!-- LETTER_MAP_START -->"
$mapEnd   = "<!-- LETTER_MAP_END -->"
$mapBody  = ($letters | ForEach-Object { "[{0}]: {1} (PDF: {2})" -f $_.code,$_.name,$_.file }) -join "`n"
$mapBlock = "$mapStart`n$mapBody`n$mapEnd"

$mapPattern = [regex]::Escape($mapStart) + '.*?' + [regex]::Escape($mapEnd)
if ($text -match $mapPattern) {
  $text = [regex]::Replace(
    $text, $mapPattern,
    ([System.Text.RegularExpressions.MatchEvaluator]{ param($m) $mapBlock }),
    [System.Text.RegularExpressions.RegexOptions]::Singleline
  )
} else {
  $text += "`r`n`r`n$mapBlock`r`n"
}

# ----- 3) Anotar códigos após menções (sem duplicar) -----
function Add-CodeIfMissing([string]$line, [string]$code){
  if ($line -match "\[$([regex]::Escape($code))(?:[^\]]*)\]") { return $line }
  return $line + " **[$code]**"
}

$lines = $text -split "\r?\n"
for ($i=0; $i -lt $lines.Count; $i++) {
  $l = $lines[$i]
  foreach ($L in $letters) {
    $rx = '(?i)\b' + [regex]::Escape($L.name) + '\b'
    if ($l -match $rx) { $l = Add-CodeIfMissing $l $L.code }
  }
  $lines[$i] = $l
}
$text = ($lines -join "`r`n")

# ----- 4) Appendix B (idempotente com marcadores) -----
$appStart = "<!-- BEGIN:APPENDIX_B -->"
$appEnd   = "<!-- END:APPENDIX_B -->"
$table = @"
$appStart
### Appendix B — Letters of Recommendation (updated)

| Code  | Recommender                | File (Drive)                                             |
|:-----:|----------------------------|----------------------------------------------------------|
| D-01  | Babita                     | recommendation-letter-Babita-update-latest-signed.pdf    |
| D-02  | Bruno                      | recommendation-letter-Bruno_english_serasa.pdf           |
| D-03  | Carlos                     | recommendation-letter-cognizant-carlos.pdf               |
| D-04  | Gaurav                     | recommendation-letter-Gaurav-update-latest-signed.pdf    |
| D-05  | José Ricardo Ferrazza      | recommendation-letter-JoséRicardoFerrazza_latest.pdf     |
| D-06  | Phillip                    | recommendation-letter-phillip-bmg.pdf                    |
$appEnd
"@

$appPattern = [regex]::Escape($appStart) + '.*?' + [regex]::Escape($appEnd)
if ($text -match $appPattern) {
  $text = [regex]::Replace(
    $text, $appPattern,
    ([System.Text.RegularExpressions.MatchEvaluator]{ param($m) $table }),
    [System.Text.RegularExpressions.RegexOptions]::Singleline
  )
} else {
  $text += "`r`n`r`n$table"
}

# ----- 5) salvar -----
Set-Content -Path $File -Value $text -Encoding UTF8
Write-Host "[OK] Letter map + Appendix B updated in $File  |  Backup: $bak"
