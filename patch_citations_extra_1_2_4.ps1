param(
  [Parameter(Mandatory=$true)][string]$File
)

# Backup
$stamp = (Get-Date).ToString("yyyyMMddHHmmss")
$bak = "$File.bak_$stamp"
Copy-Item $File $bak -Force

# Carrega
$text = Get-Content $File -Raw

function Add-CodeIfMissing([string]$line, [string]$code){
  if($line -match "\[$([regex]::Escape($code))([^\]]*)\]"){ return $line }
  # Se já existe um bloco [C-xx; ...], insere dentro
  if($line -match "\[([A-E]-\d+(?:; ?[A-E]-\d+)*)\]"){
    $inside = $Matches[1]
    if($inside -split '; ' -contains $code){ return $line }
    $newInside = $inside + "; " + $code
    return $line -replace [regex]::Escape($inside), [System.Text.RegularExpressions.Regex]::Escape($newInside) -replace "\\","\"
  }
  # Senão, anexa no fim da linha
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

# Alvos: "## 1) Proposed Endeavor", "## 2) Matter of Dhanasar", "## 4."
$sections = @()
$rxHead = [regex]'(?m)^##\s+.*$'
$matches = $rxHead.Matches($text)
for($i=0; $i -lt $matches.Count; $i++){
  $h = $matches[$i].Value
  $start = $matches[$i].Index
  $end = ($i -lt $matches.Count-1) ? $matches[$i+1].Index : $text.Length
  if($h -like "## 1) Proposed Endeavor*"){ $sections += @{name="sec1";start=$start;end=$end} }
  if($h -like "## 2) Matter of Dhanasar*"){ $sections += @{name="sec2";start=$start;end=$end} }
  if($h -like "## 4.*"){ $sections += @{name="sec4";start=$start;end=$end} }
}

# Regras
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

# Aplica
$builder = New-Object System.Text.StringBuilder
$cursor = 0
foreach($s in $sections | Sort-Object start){
  $builder.Append($text.Substring($cursor, $s.start - $cursor)) | Out-Null
  $block = $text.Substring($s.start, $s.end - $s.start)
  switch($s.name){
    "sec1" { $patched = Patch-Block $block $rules1 }
    "sec2" { $patched = Patch-Block $block $rules2 }
    "sec4" { $patched = Patch-Block $block $rules4 }
  }
  $builder.Append($patched) | Out-Null
  $cursor = $s.end
}
$builder.Append($text.Substring($cursor)) | Out-Null

# Salva
Set-Content -Path $File -Value $builder.ToString() -Encoding UTF8
Write-Host "[OK] Extra inline citations patched. Backup:" $bak
