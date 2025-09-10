param(
  [Parameter(Mandatory=$true)][string]$File
)
$stamp = (Get-Date).ToString("yyyyMMddHHmmss")
$bak = "$File.bak_$stamp"
Copy-Item $File $bak -Force
$text = Get-Content $File -Raw

function Add-CodeIfMissing([string]$line, [string]$code){
  if($line -match "\[$([regex]::Escape($code))([^\]]*)\]"){ return $line }
  if($line -match "\[([A-E]-\d+(?:; ?[A-E]-\d+)*)\]"){
    $inside = $Matches[1]
    if($inside -split '; ' -contains $code){ return $line }
    $newInside = $inside + "; " + $code
    return $line -replace [regex]::Escape($inside), [System.Text.RegularExpressions.Regex]::Escape($newInside) -replace "\\","\ "
  }
  if($line.EndsWith("`n")){ return $line.TrimEnd("`r","`n") + " **[$code]**`n" }
  else { return $line + " **[$code]**" }
}

function Patch-Block([string]$block,[hashtable]$rules){
  $out = New-Object System.Text.StringBuilder
  foreach($line in ($block -split "(`r`n|`n)")){
    $l = $line
    foreach($pat in $rules.Keys){
      if($l -match $pat){
        foreach($code in $rules[$pat]){ $l = Add-CodeIfMissing $l $code }
      }
    }
    [void]$out.AppendLine($l)
  }
  return $out.ToString()
}

$heads = [regex]::Matches($text,'(?m)^##\s+.*$')
$sections = @()
for($i=0;$i -lt $heads.Count;$i++){
  $h = $heads[$i].Value
  $start = $heads[$i].Index
  $end = ($i -lt $heads.Count-1) ? $heads[$i+1].Index : $text.Length
  # tolerante: aceita "## 1)" / "## 1." / variações
  if($h -match '^##\s+1[)\.]'){ $sections += @{name='sec1';start=$start;end=$end} }
  if($h -match '^##\s+2[)\.]'){ $sections += @{name='sec2';start=$start;end=$end} }
  if($h -match '^##\s+4[)\.]'){ $sections += @{name='sec4';start=$start;end=$end} }
}

$rules1 = @{
  '(?i)WS-1 .*?(NIST|FedRAMP)' = @('C-03');
  '(?i)WS-2 .*?(SBOM|software supply chain|artifact signing|provenance)' = @('C-02');
  '(?i)WS-3 .*?(Kubernetes|OpenShift|GitOps|OPA|PodSecurity|image hardening)' = @('C-03');
  '(?i)WS-4 .*?(Observability|Reliability|SLO|incident|DR)' = @('C-04');
  '(?i)M\d.*?(controls via .*IaC|policy-as-code)' = @('C-01','C-02','C-03');
  '(?i)(lead time|MTTR|change failure|SLO|availability)' = @('B-05','B-06');
}
$rules2 = @{
  '(?i)Prong 1 .*?(NSS|National Security Strategy|EO[-\s]?14028|SBOM|FedRAMP|NIST)' = @('C-01','C-02','C-03');
  '(?i)Prong 2 .*?(letters|recommendation|well positioned|Multi-cloud credentials)' = @('D-01');
  '(?i)Prong 3 .*?(Zero-Trust|national interest|public-interest|critical infrastructure)' = @('C-01','C-02','C-04');
}
$rules4 = @{
  '(?i)Prong 1' = @('C-01','C-02','C-03');
  '(?i)Prong 2' = @('D-01');
  '(?i)Prong 3' = @('C-01','C-02','C-04');
  '(?i)\bSBOM\b' = @('C-02');
  '(?i)\b(FedRAMP|NIST)\b' = @('C-03');
  '(?i)critical infrastructure|CISA' = @('C-04');
  '(?i)\b(BLS|WEF)\b' = @('B-05','B-06');
}

$sb = New-Object System.Text.StringBuilder
$cursor = 0
foreach($s in $sections | Sort-Object start){
  $sb.Append($text.Substring($cursor, $s.start - $cursor)) | Out-Null
  $block = $text.Substring($s.start, $s.end - $s.start)
  switch($s.name){
    "sec1" { $patched = Patch-Block $block $rules1 }
    "sec2" { $patched = Patch-Block $block $rules2 }
    "sec4" { $patched = Patch-Block $block $rules4 }
  }
  $sb.Append($patched) | Out-Null
  $cursor = $s.end
}
$sb.Append($text.Substring($cursor)) | Out-Null
Set-Content -Path $File -Value $sb.ToString() -Encoding UTF8
Write-Host "[OK] Extra inline citations patched into" $File "Backup:" $bak
