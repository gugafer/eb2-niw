# patch_master_inline.ps1
# Uso: .\patch_master_inline.ps1 -Path "EB2_NIW_Petition_Package_MASTER.md"

param([Parameter(Mandatory=$true)][string]$Path)
$ErrorActionPreference = "Stop"

# 1) Backup
Copy-Item $Path "$Path.bak" -Force

# 2) Conteúdo novo da Seção 3 (COLE O BLOCO ABAIXO ENTRE @' ... '@)
$section3 = @'
## 3) Proposed Endeavor (Cloud & DevOps)

### 3.0 Goal
Design and scale **secure multi-cloud platforms** and **enterprise software delivery** to improve **reliability, security, and speed of delivery** for U.S. organizations in **critical infrastructure**.

> **Porquê nacional:** Entrega mais rápida **e segura** de atualizações em setores críticos reduz **superfícies de ataque** e **tempo de indisponibilidade** — alinhado com a **NSS 2022** (cibersegurança / infraestrutura crítica) e com a agenda de **resiliência** e **continuidade de serviços**. **[A-01]**

### 3.1 Objectives (12–24 months)
1) **Cloud Foundations (AWS/Azure):** Establish **landing zones** via **IaC** mapped to **NIST SP 800-53/FedRAMP** controls **[C-01] [C-02]** (also Treasury Cloud governance **[A-03]**).  
   > **Porquê nacional:** Mapeamento de **controles NIST/FedRAMP** diretamente no código acelera a **conformidade federal**, reduz **erros humanos** e cria bases reutilizáveis para **órgãos e fornecedores**. **[C-01] [C-02] [A-03]**

2) **CI/CD & Software Supply Chain:** Implement **policy-as-code**, **SBOM** generation/verification, and **artifact signing/provenance**.  
   > **Porquê nacional:** **SBOM + assinatura/proveniência** endereçam a **EO 14028** e fortalecem a **cadeia de suprimentos de software**, reduzindo risco sistêmico. **[C-03] [A-01]**

3) **Kubernetes/OpenShift (ARO):** Roll out **multi-cluster** with **GitOps** and guardrails (OPA/PodSecurity); harden images/runtime.  
   > **Porquê nacional:** **GitOps** e **políticas declarativas** padronizam operações, melhoram **auditabilidade** e reduzem **MTTR** em ambientes críticos. **[C-01]**

4) **Observability & Reliability:** Define **SLIs/SLOs**, incident management, and **DR** playbooks with game-days.  
   > **Porquê nacional:** **SLOs + DR** aumentam **confiabilidade de serviços essenciais**, mitigando impactos econômicos e de **continuidade governamental**. **[C-04] [A-01]**

### 3.2 Workstreams → Deliverables
- **WS-1: Cloud Foundations (AWS/Azure)** → *Reference architectures; Landing Zones (prod/non-prod); IaC module library; control-to-implementation matrix*.  
  > **Porquê nacional:** Arquiteturas de referência e **biblioteca IaC** replicáveis reduzem **Lead Time de conformidade** e custos para o setor público. **[C-01] [C-02]**

- **WS-2: CI/CD & Supply Chain** → *Enterprise CI/CD; policy-as-code repos; compliance dashboard; signed artifacts*.  
  > **Porquê nacional:** **Dashboards de conformidade** dão **transparência** e **accountability** exigidas por padrões federais. **[C-01] [C-03]**

- **WS-3: Kubernetes/ARO** → *GitOps blueprints; cluster baselines; policy packs; DR runbooks*.  
  > **Porquê nacional:** **Baselines de cluster** endurecem plataformas críticas e apoiam **Zero Trust** na prática. **[C-01]**

- **WS-4: Observability & Reliability** → *Reliability engineering handbook; SLOs; incident/DR playbooks; quarterly resilience report*.  
  > **Porquê nacional:** **Relatórios de resiliência** orientam gestores públicos sobre **riscos operacionais** e evolução de **níveis de serviço**. **[C-04]**

### 3.3 Milestones & KPIs
| Milestone | Target | Success Criteria |
|---|---:|---|
| **M1 — Foundations Ready** | **90d** | Landing zones live; **≥70%** controls via IaC; central logging/KMS **[C-01] [C-02]** |
| **M2 — Enterprise CI/CD** | **120–150d** | **≥80%** services with **SBOM + signing** **[C-03]** |
| **M3 — ARO/K8s in Prod** | **180d** | **2–3** prod clusters with GitOps; **MTTR ↓ 30%** |
| **M4 — DR Validated** | **9–12m** | SLOs formalized; **P1 incidents ↓ 25%**; **DR ≥ 2 regions** tested **[C-04]** |
| **M5 — Compliance Automation** | **12–24m** | Automated audit evidence; **lead time ↓ 50%**; **change failure ↓ 30%** |

> **Porquê nacional:** KPIs **testáveis** (Lead time, MTTR, CFR, SLO, % controles IaC, % serviços com SBOM) permitem **verificação objetiva** de ganhos de **segurança, confiabilidade** e **eficiência** em escala nacional. **[B-01] [B-05] [B-06]**

### 3.4 Governance & Control Mapping
**Frameworks:** **NIST SP 800-53** (AC, AU, CM, CP, IA, SC, SI); **FedRAMP** baselines; supply-chain safeguards (**SBOM, signing, provenance**) **[C-01] [C-02] [C-03]**; ver também **NSS 2022 / Treasury Cloud** para contexto de política **[A-01] [A-03]**.  
**Artifacts:** Control mappings embedded in **IaC**; **policy-as-code** repos; automated evidence exports.

> **Porquê nacional:** **Automação de controles** reduz **custo regulatório**, melhora **adesão** e libera capacidade para **inovação segura** no ecossistema público/privado. **[C-01] [C-02]**

### 3.5 Risks & Mitigations (excerpt)
Vendor lock-in → IaC modular/multi-cloud; Skills gap → enablement tracks/runbooks; Permission sprawl → least-privilege + policy automation; Supply-chain exposure → **SBOM + signing/provenance**; Cost overruns → FinOps guardrails.

> **Porquê nacional:** **Mitigações estruturadas** diminuem risco de **interrupções** e **incidentes de supply chain**, protegendo **infraestrutura crítica** e **dados sensíveis**. **[C-03] [A-01]**

### 3.6 Dependencies & Exit Criteria
Identity/AAD integration; KMS ownership; change mgmt; security buy-in for **SBOM/signing**; SLO ownership.  
Exit: autonomous teams on pipelines/GitOps; SLOs embedded; IaC ownership; automated audits; runbooks complete.

> **Porquê nacional:** **Capacitação interna** e **processos replicáveis** deixam **capacidade duradoura** na força de trabalho dos EUA, reduzindo **dependência externa** e aumentando **competitividade**. **[B-05] [NSF-25-307]**
'@

# 3) Ler .md e substituir a seção 3 inteira
$content = Get-Content -Raw -Path $Path
$pattern = "(?s)##\s*3\)\s*Proposed Endeavor.*?(?=^\#\#\s|\Z)"
if ($content -match $pattern) {
  $content = [regex]::Replace($content, $pattern, $section3 + "`n`n", "Singleline")
} else {
  Write-Host "[WARN] Seção 3 não encontrada; adicionando ao final."
  $content = $content.TrimEnd() + "`n`n" + $section3 + "`n"
}

Set-Content -Path $Path -Encoding UTF8 -NoNewline -Value $content
Write-Host "[OK] Seção 3 atualizada com citações inline."
