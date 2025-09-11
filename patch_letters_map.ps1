param(
  [Parameter(Mandatory=$true)][string]$File
)
$stamp = (Get-Date).ToString("yyyyMMddHHmmss")
$bak = "$File.bak_$stamp"
Copy-Item $File $bak -Force
$text = Get-Content $File -Raw

# Fixed mapping (adjust if you rename PDFs)
$letters = @(
  @{ code="D-01"; name="Babita"; file="recommendation-letter-Babita-update-latest-signed.pdf" },
  @{ code="D-02"; name="Bruno"; file="recommendation-letter-Bruno_english_serasa.pdf" },
  @{ code="D-03"; name="Carlos"; file="recommendation-letter-cognizant-carlos.pdf" },
  @{ code="D-04"; name="Gaurav"; file="recommendation-letter-Gaurav-update-latest-signed.pdf" },
  @{ code="D-05"; name="José Ricardo Ferrazza"; file="recommendation-letter-JoséRicardoFerrazza_latest.pdf" },
  @{ code="D-06"; name="Phillip"; file="recommendation-letter-phillip-bmg.pdf" }
)

# 3.1 Insert / update a LETTER MAP block
$mapStart = "<!-- LETTER_MAP_START -->"
$mapEnd   = "<!-- LETTER_MAP_END -->"

$mapBody = ($letters | ForEach-Object {
  "[{0}]: {1} (PDF: {2})" -f $_.code,$_.name,$_.file
}) -join "`n"

$mapBlock = "$mapStart`n$mapBody`n$mapEnd"

if($text -match [regex]::Escape($mapStart) -and $text -match [regex]::Escape($mapEnd)){
  $text = $text -replace "$([regex]::Escape($mapStart)).*?$([regex]::Escape($mapEnd))", [System.Text.RegularExpressions.Regex]::Escape($mapBlock) -replace "\\","\ "
}else{
  $text = $text + "`n`n" + $mapBlock + "`n"
}

# 3.2 Add codes after name mentions in the body if missing
function Add-CodeIfMissing([string]$line, [string]$code){
  if($line -match "\[$([regex]::Escape($code))([^\]]*)\]"){ return $line }
  if($line.EndsWith("`n")){ return $line.TrimEnd("`r","`n") + " **[$code]**`n" }
  else { return $line + " **[$code]**" }
}

$lines = $text -split "(`r`n|`n)"
for($i=0; $i -lt $lines.Count; $i++){
  $l = $lines[$i]
  foreach($L in $letters){
    $rx = '(?i)\b' + [regex]::Escape($L.name) + '\b'     # ✅ string literal com \b
  # ou, se preferir interpolação:
  # $rx = "(?i)\b$([regex]::Escape($L.name))\b"
    if($l -match $rx){
      $l = Add-CodeIfMissing $l $L.code
    }
  }
  $lines[$i] = $l
}
$text = ($lines -join "`n")

# 3.3 Append a normalized Appendix B table (safe to duplicate; you keep the latest)
$table = @"
### Appendix B — Letters of Recommendation (updated)

| Code  | Recommender                | File (Drive)                                             |
|:-----:|----------------------------|----------------------------------------------------------|
| D-01  | Babita                     | recommendation-letter-Babita-update-latest-signed.pdf    |
| D-02  | Bruno                      | recommendation-letter-Bruno_english_serasa.pdf           |
| D-03  | Carlos                     | recommendation-letter-cognizant-carlos.pdf               |
| D-04  | Gaurav                     | recommendation-letter-Gaurav-update-latest-signed.pdf    |
| D-05  | José Ricardo Ferrazza      | recommendation-letter-JoséRicardoFerrazza_latest.pdf     |
| D-06  | Phillip                    | recommendation-letter-phillip-bmg.pdf                    |

"@

$text = $text + "`n" + $table

Set-Content -Path $File -Value $text -Encoding UTF8
Write-Host "[OK] Letter map + Appendix B updated in" $File "Backup:" $bak
