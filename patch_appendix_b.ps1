Param(
  [Parameter(Mandatory=$false)][string]$Master = "EB2_NIW_Petition_Package_MASTER.md",
  [Parameter(Mandatory=$false)][string]$Index  = "index.md"
)

$ErrorActionPreference = "Stop"

$appendix = @'

<!-- BEGIN:APPENDIX_B -->
## Appendix B — Recommendation Letters (Detailed)

| Code | Organization | Role | Signed | Pages |
|:---:|---|---|:---:|:---:|
| D-01 | Humana Inc. | Associate Director, DevOps Engineering | 2025-09-07 | 941–943 |
| D-02 | Humana Inc. | Associate Director, DevOps Engineering | 2025-09-07 | 944–945 |
| D-03 | Cognizant Brazil | Senior Manager, Project Delivery | 2025-08-26 | 946–947 |
| D-04 | Banco Itaú (ex-Banco BMG) | Cloud Architect | 2025-09-07 | 948–951 |
| D-05 | Serasa Experian | SRE / DevSecOps / Cloud (Manager) | 2025-09-07 | 952–955 |
| D-06 | DXC Technology | Delivery Manager | 2025-05-25 | 956–959 |
<!-- END:APPENDIX_B -->

'@

function Apply-AppendixB($file) {{
  if (!(Test-Path $file)) {{ Write-Warning "Not found: $file"; return }}
  $text = Get-Content -Raw -Encoding UTF8 $file
  if ($text -match '<!-- BEGIN:APPENDIX_B -->' -and $text -match '<!-- END:APPENDIX_B -->') {{
    $rx = '<!-- BEGIN:APPENDIX_B -->.*?<!-- END:APPENDIX_B -->'
    $new = [regex]::Replace($text, $rx, $appendix, 'Singleline')
    $new | Set-Content -Encoding UTF8 $file
    Write-Host "[OK] Appendix B replaced in $file"
  }} else {{
    # Try to insert after the Exhibit D rows (if present), else append at the end
    $rxBlock = '^\|\s+\*\*D-01\*\*.*?(?=^\#\s|\Z)'
    $m = [regex]::Match($text, $rxBlock, 'Singleline, Multiline')
    if ($m.Success) {{
      $head = $text.Substring(0, $m.Index + $m.Length)
      $tail = $text.Substring($m.Index + $m.Length)
      ($head + "`r`n`r`n" + $appendix + $tail) | Set-Content -Encoding UTF8 $file
      Write-Host "[OK] Appendix B inserted after Exhibit D in $file"
    }} else {{
      ($text.TrimEnd() + "`r`n`r`n" + $appendix) | Set-Content -Encoding UTF8 $file
      Write-Host "[OK] Appendix B appended to end of $file"
    }}
  }}
}}

Apply-AppendixB $Master
Apply-AppendixB $Index
