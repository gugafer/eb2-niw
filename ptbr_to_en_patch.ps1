param([Parameter(Mandatory=$true)][string]$File)
$map = @{
  'Porquê nacional' = 'Why it matters nationally'
  'O que é:'        = 'What it is:'
  'O que prova:'    = 'What it shows:'
  'Inserir aqui:'   = 'Insert here:'
  'Prongs suportados:' = 'Supported prongs:'
  'Arquivo'         = 'File'
  'Páginas'         = 'Pages'
  'Intervalo'       = 'Range'
}
$txt = Get-Content -Raw -Encoding UTF8 $File
$bak = "$File.bak_$(Get-Date -Format yyyyMMddHHmmss)"
Copy-Item $File $bak
foreach ($k in $map.Keys) { $txt = $txt -replace [regex]::Escape($k), $map[$k] }
$txt | Set-Content -Encoding UTF8 $File
Write-Host "[OK] Patched. Backup: $bak"
