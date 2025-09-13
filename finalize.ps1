param(
  [switch]$Rebuild,
  [string]$SourceBinder = "",
  [string]$ZipName = ""
)
$ErrorActionPreference = 'Stop'

function Test-Cmd($name){ return $null -ne (Get-Command $name -ErrorAction SilentlyContinue) }

function Find-Binder([string]$explicit){
  if($explicit -and (Test-Path $explicit)){ return (Resolve-Path $explicit).Path }
  $candidates = @(
    'EB2_NIW_Binder_FINAL_TOPLEVEL.pdf',
    'EB2_NIW_Binder_FINAL_GROUPED.pdf',
    'EB2_NIW_Binder_FINAL_CLEAN.pdf'
  )
  foreach($c in $candidates){
    if(Test-Path $c){ return (Resolve-Path $c).Path }
  }
  return $null
}

$today = (Get-Date).ToString('yyyy-MM-dd')
if(-not $ZipName){ $ZipName = "EB2_NIW_FINAL_$today.zip" }

# 1) (Opcional) rebuild
if($Rebuild){
  if(Test-Path '.\release_build_v2.ps1'){
    Write-Host "[RUN] release_build_v2.ps1"
    & powershell -ExecutionPolicy Bypass -File '.\release_build_v2.ps1'
  } elseif(Test-Path '.\release_build_v2.sh'){
    Write-Host "[RUN] release_build_v2.sh"
    bash '.\release_build_v2.sh'
  } else {
    Write-Warning "release_build_v2.* não encontrado; seguindo sem rebuild."
  }
}

# 2) Binder de origem
$src = Find-Binder $SourceBinder
if(-not $src){ Write-Error "Nenhum binder encontrado. Informe -SourceBinder ou gere um binder FINAL_*."; exit 1 }
Write-Host "[SRC] $src"

$print = "EB2_NIW_Binder_FINAL_PRINT.pdf"
$flat  = "EB2_NIW_Binder_FINAL_PRINT_FLAT.pdf"

# 3) Gerar PRINT (preferindo remove_link_annots_v2.py → ..._v1 → copy)
if(Test-Path '.\remove_link_annots_v2.py'){
  Write-Host "[RUN] remove_link_annots_v2.py"
  python '.\remove_link_annots_v2.py' $src $print
} elseif(Test-Path '.\remove_link_annots.py'){
  Write-Host "[RUN] remove_link_annots.py"
  python '.\remove_link_annots.py' $src $print
} else {
  Write-Warning "Script de remover links não encontrado; copiando binder para PRINT."
  Copy-Item $src $print -Force
}

# 4) Linearizar com qpdf (fallback: cópia)
if(Test-Cmd 'qpdf'){
  Write-Host "[RUN] qpdf --linearize → $flat"
  qpdf --object-streams=generate --linearize $print $flat
} else {
  Write-Warning "qpdf não encontrado; PRINT_FLAT = PRINT."
  Copy-Item $print $flat -Force
}

# 5) Montar lista para ZIP
$files = New-Object 'System.Collections.Generic.List[string]'
foreach($p in @(
  'index_protocol.pdf',
  'EB2_NIW_Binder_FINAL_TOPLEVEL.pdf',
  'EB2_NIW_Binder_FINAL_GROUPED.pdf',
  'EB2_NIW_Binder_FINAL_CLEAN.pdf',
  'EB2_NIW_Binder_FINAL_PRINT.pdf',
  'EB2_NIW_Binder_FINAL_PRINT_FLAT.pdf'
)){
  if(Test-Path $p){ $files.Add((Resolve-Path $p).Path) }
}

$master = if(Test-Path 'EB2_NIW_Petition_Package_MASTER._SYNCED.md'){ 'EB2_NIW_Petition_Package_MASTER._SYNCED.md' }
          elseif(Test-Path 'EB2_NIW_Petition_Package_MASTER.md'){ 'EB2_NIW_Petition_Package_MASTER.md' }
          else { $null }
$indexm = if(Test-Path 'index._SYNCED.md'){ 'index._SYNCED.md' }
          elseif(Test-Path 'index.md'){ 'index.md' }
          else { $null }

foreach($p in @($master,$indexm)){ if($p){ $files.Add((Resolve-Path $p).Path) } }

# 6) Criar ZIP
if(Test-Path $ZipName){ Remove-Item $ZipName -Force }
if($files.Count -eq 0){
  Write-Warning "Nenhum arquivo encontrado para compactar."
} else {
  Compress-Archive -Path $files -DestinationPath $ZipName -Force
  Write-Host "[OK] ZIP criado → $ZipName"
}

# 7) Hashes e tamanhos
Write-Host ""
Write-Host "== Artefatos =="
$artifacts = @($print,$flat,$ZipName) + $files
$seen = @{}
foreach($a in $artifacts){
  if($a -and (Test-Path $a) -and -not $seen.ContainsKey($a)){
    $seen[$a] = $true
    $md5 = (Get-FileHash $a -Algorithm MD5).Hash
    $sha = (Get-FileHash $a -Algorithm SHA256).Hash
    $len = (Get-Item $a).Length
    "{0}`t{1:N0} bytes`tMD5={2}`tSHA256={3}" -f (Split-Path $a -Leaf), $len, $md5, $sha | Write-Host
  }
}
