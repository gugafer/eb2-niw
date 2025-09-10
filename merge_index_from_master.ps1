param(
  [Parameter(Mandatory=$true)][string]$IndexPath = "index.md",
  [Parameter(Mandatory=$true)][string]$MasterPath = "EB2_NIW_Petition_Package_MASTER.md"
)

$ErrorActionPreference = "Stop"

# 1) Read files
$idx = Get-Content -Raw -LiteralPath $IndexPath
$mst = Get-Content -Raw -LiteralPath $MasterPath

# 2) Extract Section 3 from MASTER (## 3 or ## 3) styles)
$sec3 = [regex]::Match($mst, "(?s)^\s*##\s*3[\)\.]?\s*.*?(?=^\#\#\s*\d+|\Z)", "Multiline").Value
if(-not $sec3){ throw "Could not extract Section 3 from $MasterPath" }

# 3) Replace the placeholder section in index.md
$pattern = "(?s)^\s*##\s*Proposed Endeavor\s*\(verbatim\)\s*.*?(?=^\#\#\s|\Z)"
if([regex]::IsMatch($idx, $pattern, "Multiline")){
  $new = [regex]::Replace($idx, $pattern, "## Proposed Endeavor (verbatim)`r`n`r`n$sec3`r`n", "Multiline")
} else {
  # If placeholder not found, append at the end
  $new = $idx.TrimEnd() + "`r`n`r`n## Proposed Endeavor (verbatim)`r`n`r`n" + $sec3 + "`r`n"
}

# 4) Backup and write
Copy-Item -LiteralPath $IndexPath -Destination "$IndexPath.bak" -Force
Set-Content -LiteralPath $IndexPath -Encoding UTF8 -Value $new
Write-Host "[OK] index.md updated with Section 3 from MASTER."
