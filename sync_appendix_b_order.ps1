param(
  [string[]]$Files = @("EB2_NIW_Petition_Package_MASTER.md","index.md")
)

$ErrorActionPreference = "Stop"

function Get-Order {
  param([string]$text)
  $m = [regex]::Match($text, '<!--\s*LETTER_MAP_START\s*-->(.*)<!--\s*LETTER_MAP_END\s*-->', 'Singleline, IgnoreCase')
  if (-not $m.Success) { return @() }
  $block = $m.Groups[1].Value
  ([regex]::Matches($block, '\[(D-\d{2})\]\s*:') | ForEach-Object { $_.Groups[1].Value })
}

function Reorder-AppB {
  param([string]$text, [string[]]$order)
  $m = [regex]::Match($text, '(?is)(<!--\s*BEGIN:APPENDIX_B\s*-->)(.*?)(<!--\s*END:APPENDIX_B\s*-->)')
  if (-not $m.Success) { return @($text, $false) }
  $body = $m.Groups[2].Value

  $m2 = [regex]::Match($body, "(?s)(\|\s*Code\b.*?\r?\n\|[^\r\n]*\r?\n)(?<rows>(?:\|.*\r?\n)+)")
  if (-not $m2.Success) { return @($text, $false) }

  $thead = $m2.Groups[1].Value
  $rowsBlock = $m2.Groups['rows'].Value
  $rows = @()
  foreach ($ln in ($rowsBlock -split "\r?\n")) { if ($ln.Trim().StartsWith("|")) { $rows += $ln } }

  $rowMap = @{}
  foreach ($r in $rows) {
    $mcode = [regex]::Match($r, 'D-\d{2}')
    if ($mcode.Success) { $rowMap[$mcode.Value] = $r }
  }

  $sorted = @()
  foreach ($c in $order) { if ($rowMap.ContainsKey($c)) { $sorted += $rowMap[$c] } }
  foreach ($r in $rows) {
    $c = ([regex]::Match($r, 'D-\d{2}')).Value
    if (-not ($order -contains $c)) { $sorted += $r }
  }

  $newBody = $body.Substring(0, $m2.Groups[1].Index) + $thead + ($sorted -join "`r`n") + "`r`n" + $body.Substring($m2.Index + $m2.Length)
  $newText = $text.Substring(0, $m.Index) + $m.Groups[1].Value + $newBody + $m.Groups[3].Value + $text.Substring($m.Index + $m.Length)
  @($newText, $true)
}

foreach ($file in $Files) {
  if (-not (Test-Path $file)) { Write-Warning "Not found: $file"; continue }
  $text = Get-Content -Raw -Encoding UTF8 $file
  $order = Get-Order $text
  if (-not $order -and (Test-Path "index.md")) { $order = Get-Order (Get-Content -Raw -Encoding UTF8 "index.md") }

  $res = Reorder-AppB $text $order
  $newText, $changed = $res[0], $res[1]

  $out = [IO.Path]::ChangeExtension($file, $null) + "_SYNCED.md"
  $newText | Set-Content -Encoding UTF8 $out
  if ($changed) { Write-Host "[OK] Appendix B reordered → $out" }
  else { Write-Host "[WARN] Could not find APPENDIX_B table in $file → $out" }
}
