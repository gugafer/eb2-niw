param(
  [Parameter(Mandatory=$true)][string]$File
)

$ErrorActionPreference = "Stop"
$orig = Get-Content -Raw -LiteralPath $File
$bak  = "$File.bak_$(Get-Date -Format yyyyMMddHHmmss)"
$orig | Set-Content -LiteralPath $bak -Encoding UTF8

function EnsureHook {
  param([string]$content,[string]$section,[string]$needle,[string]$hook)
  $pattern = "(?s)(##\s*$([regex]::Escape($section))\b.*?)(\r?\n\r?\n)"
  $m = [regex]::Match($content,$pattern)
  if(-not $m.Success){ return $content }
  $sectionBodyPattern = "(?s)(##\s*$([regex]::Escape($section))\b.*?)(?=^\#\#\s|\Z)"
  $sb = [regex]::Match($content,$sectionBodyPattern)
  if(-not $sb.Success){ return $content }
  $body = $sb.Value
  $idx  = [regex]::Match($body,[regex]::Escape($needle))
  if(-not $idx.Success){ return $content }
  $lines = $body -split "`r?`n"
  for($i=0;$i -lt $lines.Count;$i++){
    if($lines[$i] -match [regex]::Escape($needle)){
      if($lines[$i] -notmatch [regex]::Escape($hook)){
        $lines[$i] = $lines[$i].TrimEnd() + " $hook"
      }
      break
    }
  }
  $newBody = ($lines -join "`r`n")
  return $content.Substring(0,$sb.Index) + $newBody + $content.Substring($sb.Index + $sb.Length)
}

$out = $orig
# §1 Executive Summary
$out = EnsureHook $out "1. Executive Summary" "**Endeavor.**" "[A-01; A-02; A-03; C-01–C-04]."
$out = EnsureHook $out "1. Executive Summary" "**Prong 1.**" "[B-01–B-03]."
# §2 Background & Qualifications
$out = EnsureHook $out "2. Background & Qualifications" "NIST/FedRAMP" "[C-01; C-02]."
$out = EnsureHook $out "2. Background & Qualifications" "Dhanasar" "[A-01; A-03]."

# §4 replace entirely (keeps your English block we prepared)
$sec4Pattern = "(?s)^##\s*4\.\s*National Interest.*?(?=^\#\#\s*\d+\.\s|\Z)"
$sec4New = @'
## 4. National Interest (Matter of Dhanasar) {#sec:national-interest}

### 4.1 Prong 1 — Substantial Merit & National Importance
The proposed endeavor—**secure multi-cloud foundations (NIST/FedRAMP-mapped IaC), enterprise CI/CD with SBOM & signing, Kubernetes/OpenShift (ARO) with GitOps guardrails, and SRE/DR for reliability**—directly advances U.S. **cybersecurity** and **critical infrastructure resilience** priorities and the digital competitiveness agenda. [A-01; A-03; C-01–C-03]

*Policy hook (national interest):* NSS 2022 underscores defending critical infrastructure and securing the digital ecosystem; the U.S. Treasury’s Cloud report calls for modernized, well-governed cloud to reduce systemic risk; EO 14028 drives **software supply-chain** integrity via **SBOM/signing**—all of which are operationalized by the mapped controls and pipelines here. [A-01; A-02; A-03; C-01–C-03]

*Economic & workforce hook:* WEF 2025 and BLS 2024 point to sustained demand for cloud, DevOps and cybersecurity roles supporting essential services; aligning **automation + compliance-as-code** scales scarce talent impact and reduces time-to-assurance for public-interest workloads. [B-01–B-03]

### 4.2 Prong 2 — Well Positioned to Advance the Endeavor
The record evidences capability to execute at scale: **AWS DevOps Pro/Developer/Architect, CompTIA Cloud+, Azure AZ-104**, plus delivery across **Terraform/Ansible**, **Kubernetes/ARO**, **CI/CD with SBOM/signing**, and **SRE/DR**. These map directly to the endeavor’s workstreams (Foundations, CI/CD & Supply-Chain, Kubernetes/ARO, SRE/DR). [D-01–D-06]

*Corroboration (letters):* independent letters describe prior outcomes (production clusters, IaC baselines, pipelines with policy gates, SLOs/DR) and forecast impact in U.S. contexts that depend on reliability and compliance speed. [E-01–E-05]

### 4.3 Prong 3 — On Balance, Waiving Labor Certification Benefits the U.S.
Requiring labor certification would **delay** controls demanded by **NIST SP 800-53 Rev.5** and **FedRAMP** baselines, as well as **SBOM/provenance** adoption under EO 14028—diminishing national cyber posture in critical sectors. Dispensing with it enables **immediate** deployment of IaC-mapped controls, CI/CD with signed artifacts, and SRE/DR runbooks that cut **lead time**, **MTTR**, and **change-failure**, while raising **SLOs** and the percentage of automated controls. [A-01; C-01; C-02; C-03]

*Balance test (public benefit):* Accelerated conformity to federal baselines and secure software mandates in agencies and regulated suppliers reduces time-to-compliance and exposure windows, which outweighs the procedural interest in labor certification for this case. [A-01; A-02; C-01–C-03]
'@

if([regex]::IsMatch($out,$sec4Pattern,[System.Text.RegularExpressions.RegexOptions]::Multiline)){
  $out = [regex]::Replace($out,$sec4Pattern,$sec4New,[System.Text.RegularExpressions.RegexOptions]::Multiline)
} else {
  $out = $out.TrimEnd() + "`r`n`r`n" + $sec4New
}

$out | Set-Content -LiteralPath $File -Encoding UTF8
Write-Host "[OK] Inline citations and §4 updated. Backup: $bak"
