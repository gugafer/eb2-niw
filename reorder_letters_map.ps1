param(
  [string]$Master = "EB2_NIW_Petition_Package_MASTER.md",
  [string]$Index  = "index.md"
)

# Ordem desejada (altere aqui pelos CÓDIGOS destino)
# Ex.: D-04, D-03, D-05, D-01, D-02, D-06
$NewOrder = @("D-04","D-03","D-05","D-01","D-02","D-06")

function Get-LetterMap($text) {
  $m = [regex]::Matches($text, '^\[(D-\d{2})\]:\s*(.+?)\s*\(PDF:\s*(.+?)\)\s*$', 'Multiline')
  $h = @{}
  foreach($x in $m){ $h[$x.Groups[1].Value] = @{ name=$x.Groups[2].Value; file=$x.Groups[3].Value } }
  return $h
}

function Set-LetterMap($text, $map) {
  $start = "<!-- LETTER_MAP_START -->"
  $end   = "<!-- LETTER_MAP_END -->"
  $head  = ($text -split [regex]::Escape($start))[0] + $start + "`r`n"
  $tail  = ($text -split [regex]::Escape($end))[-1]
  $lines = foreach($k in $map.Keys){ "[{0}]: {1} (PDF: {2})" -f $k, $map[$k].name, $map[$k].file }
  return $head + ($lines -join "`r`n") + "`r`n" + $end + $tail
}

$masterText = Get-Content -Raw $Master -Encoding UTF8
$indexText  = Get-Content -Raw $Index  -Encoding UTF8

$M = Get-LetterMap $masterText
$I = Get-LetterMap $indexText

# constrói mapa novo reindexando os CÓDIGOS na ordem desejada
$keys = ($M.Keys + $I.Keys) | Sort-Object -Unique
$src  = if($M.Count -gt 0){ $M } else { $I }
$new  = [ordered]@{}
for($i=0; $i -lt $NewOrder.Count; $i++){
  $code = $NewOrder[$i]
  $orig = $src[$code]
  $new[('D-{0:00}' -f ($i+1))] = @{ name=$orig.name; file=$orig.file }
}

$masterOut = Set-LetterMap $masterText $new
$indexOut  = Set-LetterMap $indexText  $new

Set-Content -Path $Master -Value $masterOut -Encoding UTF8
Set-Content -Path $Index  -Value $indexOut  -Encoding UTF8
Write-Host "[OK] LETTER_MAP reordenado no MASTER e index.md."
