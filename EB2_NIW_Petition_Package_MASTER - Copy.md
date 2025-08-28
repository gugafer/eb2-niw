---
title: "EB-2 NIW — Petition Package"
subtitle: "Main Petition Memorandum, Cover Letter, Evidence Index & Annex Cover Sheets"
author: "Gustavo de Oliveira Ferreira — Cloud & DevOps Engineer"
date: "August 23, 2025"
lang: "en-US"
documentclass: article
fontsize: 12pt
geometry: margin=1in
mainfont: "Times New Roman"
numbersections: true
toc: true
toc-depth: 3
colorlinks: true

# citeproc / CSL
csl: estilo.csl
bibliography: references.bib

# pandoc-crossref
linkReferences: true
nameInLink: true
codeBlockCaptions: true
figPrefix: ["Figure", "Figures"]
tblPrefix: ["Table", "Tables"]
secPrefix: ["Section", "Sections"]

header-includes:
  - |
    \usepackage{setspace}
    \onehalfspacing
    \usepackage{hyperref}
    \hypersetup{hidelinks}
    \usepackage{longtable,booktabs}
    \usepackage{caption}
    \captionsetup{labelfont=bf}
    \usepackage{enumitem}
    \setlist{nosep}
---

<!-- USCIS-friendly, sem anexos pesados; tudo por Annex-ID. -->

# Cover Page {.unnumbered}

**Petitioner/Beneficiary:** **Gustavo de Oliveira Ferreira**  
**Classification Sought:** EB-2 **National Interest Waiver** (INA §203(b)(2)(B)(i))  
**Forms Enclosed:** **Form I-140**; **Form I-907 (Premium Processing)**; **G-1145** (optional); Filing Fees  
**Date:** August 23, 2025  
**Representation:** ☐ Attorney/Accredited Rep  ☐ **Pro Se (Self-Petitioner)**

> **CONFIDENTIAL** — Contains personally identifiable information. For USCIS use only.

**Filing address (per current USCIS instructions):**  
________________________________________  
________________________________________

\newpage

# Cover Letter — EB-2 NIW (Form I-140 Self-Petition; Premium Processing) {#sec:cover-letter}

**Date:** August 23, 2025  
**To:** U.S. Citizenship and Immigration Services (USCIS)  
**RE:** *Form I-140, Immigrant Petition for Alien Worker — EB-2 National Interest Waiver (NIW);* **Form I-907 — Premium Processing**  
**Petitioner/Beneficiary:** **Gustavo de Oliveira Ferreira** (self-petition)  
**Classification Sought:** EB-2 **National Interest Waiver** (INA §203(b)(2)(B)(i))

**Eligibility (Matter of Dhanasar).**  
**Prong 1 — National importance.** Endeavor: **secure cloud & DevOps automation** for critical U.S. sectors; aligns with federal strategy (cyber, resilient infrastructure) and workforce demand [**A-01**; **A-02**; **A-03**; **B-01–B-03**; **C-01–C-04**].  
**Prong 2 — Well positioned.** Multi-cloud certifications (AWS DevOps Pro, AWS Developer/Architect, **CompTIA Cloud+**, **Azure AZ-104**) + delivery in **Kubernetes/ARO**, **Terraform/Ansible**, **CI/CD** com **SBOM/signing**, **SRE** [**D-01–D-06**].  
**Prong 3 — Balance of factors.** Sem NIW, a *labor certification* atrasaria controles de segurança e confiabilidade de interesse público. A dispensa permite contribuição imediata [**A-01**; **A-03**; **C-01**; **C-02**].

**Proposed endeavor (12–24 months).** Landing zones **AWS/Azure** via **IaC** mapeadas a **NIST/FedRAMP**; **CI/CD** com **policy-as-code**, **SBOM** e **assinatura**; **Kubernetes/OpenShift (ARO)** com **GitOps** e guardrails; **SRE/DR**. **KPIs:** lead time↓, change-failure↓, MTTR↓, SLO↑, %controles via IaC↑, %serviços com SBOM/assinatura↑.

**Enclosures.** Forms **I-140**, **I-907**, taxas, G-1145 (opt.), **Main Petition Memorandum**, **Annexes A–D** (cover sheets + cross-refs).  
**Request:** Approve the EB-2 NIW with Premium Processing.

\newpage

# Main Petition Memorandum (EN-US)

## 1. Executive Summary {#sec:exec-summary}

**Endeavor.** Projetar e escalar **multi-cloud seguro** e **entrega de software**: **AWS/Azure**, **IaC**, **CI/CD** com **SBOM/assinatura**, **Kubernetes/OpenShift (ARO)** com **GitOps**, **SRE/DR** — para organizações ligadas à **critical infrastructure**.

**Prong 1.** Estratégia federal prioriza **cyber** e **infraestrutura crítica** [**A-01**, **A-03**]; **CET** destaca enablers de cloud/CI-CD [**A-02**]; mercado/trabalho confirmam demanda [**B-01–B-03**]; compliance (NIST/FedRAMP, supply-chain) exige automação padronizada [**C-01–C-04**].

**Prong 2.** Certificações multi-cloud (**AWS DevOps Pro/Developer/Architect**, **Cloud+**, **AZ-104**) + entregas em **Kubernetes/ARO**, **Terraform/Ansible**, **CI/CD+SBOM**, **SRE** [**D-01–D-06**].

**Prong 3.** NIW remove atrasos que impediriam controles de segurança/confiabilidade; benefícios imediatos com métricas públicas [**A-01**; **A-03**; **C-01**; **C-02**].

**Planned outcomes (12–24 m).**  
• **Foundations:** Landing zones com **IaC** mapeadas a **NIST/FedRAMP** [**C-01**, **C-02**].  
• **Delivery:** **CI/CD** com **policy-as-code**, **SBOM**, **assinatura/proveniência**.  
• **Platforms:** **Kubernetes/ARO** multi-cluster com **GitOps** + guardrails.  
• **Reliability:** **SRE/DR** (SLI/SLO, runbooks, DR tests).  
**KPIs:** lead time ↓50%; change failure ↓30%; MTTR ↓40%; SLO ≥95%; ≥85% controles via IaC; ≥85% serviços com SBOM/assinatura.

> **Officer Box (plain-English):** IaC são **blueprints**; CI/CD é a **linha de montagem**; SRE/DR é o **plano de confiabilidade**. Resultado: serviços essenciais ficam **online e seguros**.

\newpage

## 2. Background & Qualifications {#sec:background}

### 2.0 Professional Summary
Cloud & DevOps Engineer (AWS/Azure/ARO, Terraform/Ansible, GitOps, SBOM/signing, SRE/DR). Forte em mapear **NIST/FedRAMP** a **IaC/policy-as-code**. Evidências: **[D-01–D-06]**.

### 2.1 Career Progression (Timeline) {#sec:career}
- **2016–2018 — Systems/Network → Automation** *(BR; [empresa])*  
- **2018–2020 — Cloud Engineer (AWS)** *(…)*  
- **2020–2022 — DevOps Engineer (Multi-cloud)** *(…)*  
- **2022–2023 — Senior DevOps (OpenShift/K8s)** *(…)*  
- **2023–2025 — Senior Cloud & DevOps (incl. ARO)** *(…)*

*Dhanasar link:* trajetória + resultados → **Prong 2**; alinhamento direto → **Prong 1/3**.

### 2.2 Certifications & Training (Annex-Mapped) {#sec:certs}
- **AWS DevOps Engineer – Professional** — **[D-01]** *(valid to 03/2026)*  
- **AWS Developer – Associate** — **[D-02]** *(valid to 03/2026)*  
- **AWS Solutions Architect – Associate** — **[D-03]** *(exp. 12/2024)*  
- **CompTIA Cloud+ ce** — **[D-04]** *(2019–2028)*  
- **Microsoft Azure Administrator (AZ-104)** — **[D-05]** *(12/2024–01/2026)*  
- **Resume / Outcomes** — **[D-06]**

### 2.3 Competency Matrix — Condensed {#sec:competency}

Table: Competency Matrix — skills × certifications × evidence × outcomes {#tbl:competency}

| Area | Core skills/tools | Primary cert evidence | Supporting evidence | Outcomes/KPIs |
|---|---|---|---|---|
| **Cloud Architecture (AWS/Azure)** | Landing zones, VPC/VNet, IAM/AAD, secrets, DR/HA | **[D-01] [D-03] [D-05]** | **[C-01] [C-02] [D-06]** | IaC baselines; ≥**85%** controls automated; DR ≥2 regions |
| **Containers & Orchestration** | Kubernetes/OpenShift (**ARO**), GitOps, OPA/PodSecurity | **[D-01] [D-04]** | **[D-06]** | Prod multi-cluster; **MTTR ↓ 30%** |
| **DevOps & CI/CD** | Pipelines, artifacts, testing gates, releases | **[D-01] [D-02]** | **[C-01] [C-02] [D-06]** | ≥**80%** services with **SBOM/signing** |
| **Security & Zero-Trust** | Identity-centric, key rotation, hardening | **[D-01] [D-05]** | **[C-01] [C-03]** | Change-failure ↓; vuln remediation time ↓ |
| **SRE/Observability** | SLI/SLO, incident mgmt | — | **[C-04] [D-06]** | **SLO ≥95%**; P1 incidents ↓ **25%** |
| **Compliance as Code** | Control mappings in IaC | **[D-01] [D-04]** | **[C-01] [C-02]** | Automated audit evidence; policy violations ↓ |

\newpage

## 3. Proposed Endeavor {#sec:endeavor}

### 3.1 Objectives (12–24 months)
1) **Cloud Foundations (AWS/Azure):** **IaC** mapeada a **NIST/FedRAMP** **[C-01] [C-02]**  
2) **CI/CD & Supply-Chain:** **policy-as-code**, **SBOM**, **assinatura/proveniência** **[C-01] [C-03]**  
3) **Kubernetes/OpenShift (ARO):** **GitOps** + guardrails (OPA/PodSecurity)  
4) **SRE & Resilience:** **SLI/SLO**, incident mgmt, **DR** **[C-04]**

### 3.2 Workstreams → Deliverables
- **WS-1: Cloud Foundations** — ref. arch, **Landing Zones**, **IaC module library**, **control matrix** **[C-01] [C-02]**  
- **WS-2: CI/CD & Supply-Chain** — enterprise **CI/CD**, **policy-as-code**, **compliance dashboard**, **signed artifacts** **[C-01] [C-03]**  
- **WS-3: Kubernetes/ARO** — **GitOps blueprints**, baselines, policy packs, **DR runbooks**  
- **WS-4: SRE/DR** — **SRE handbook**, SLOs, incident/DR playbooks, rel. trimestral **[C-04]**

### 3.3 Milestones & KPIs {#sec:milestones}

Table: Program milestones & measurable outcomes (12–24 months) {#tbl:milestones}

| Milestone | Target | Success Criteria |
|---|---:|---|
| **M1 — Foundations Ready** | **90d** | Landing zones; **≥70%** controls via IaC; logging/KMS **[C-01] [C-02]** |
| **M2 — Enterprise CI/CD** | **120–150d** | **≥80%** serviços com **SBOM + signing**; policy-as-code ativo **[C-01] [C-03]** |
| **M3 — K8s/ARO in Prod** | **180d** | **2–3** clusters prod; **MTTR ↓ 30%** |
| **M4 — SRE/DR Operational** | **9–12m** | **P1 ↓ 25%**; **DR ≥ 2 regiões** testado **[C-04]** |
| **M5 — Compliance Automation** | **12–24m** | Evidência automatizada; **lead time ↓ 50%**; **change failure ↓ 30%** |

### 3.4 Governance & Control Mapping
Frameworks: **NIST SP 800-53**, **FedRAMP**; **SBOM/signing/provenance** **[C-01] [C-02]**.  
Artifacts: control-to-implementation em **IaC**; **policy-as-code**; export de evidências.

### 3.5 Risks & Mitigations
Lock-in → IaC modular; Skills gap → enablement; Permission sprawl → least
