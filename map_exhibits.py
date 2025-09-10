# map_exhibits.py — gera ExhibitMap.csv com ranges de páginas
import csv, os
from PyPDF2 import PdfReader

# 1) Ajuste esta ordem: (ID, arquivo)
exhibits = [
    ("A-01", "Biden-Harris-Administrations-National-Security-Strategy-10.2022.pdf"),
    ("A-02", "CRITICAL AND EMERGING TECHNOLOGIES-CMR-PREX23-00185928.pdf"),
    ("B-01", "WEF_Future_of_Jobs_Report_2025.pdf"),
    ("B-02", "WEF_Top_10_Emerging_Technologies_of_2025.pdf"),
    ("B-03", "comptia-state-of-the-tech-workforce-2024.pdf"),
    ("B-04", "comptia-it-industry-outlook-2025.pdf"),
    ("B-05", "nsf25307.pdf"),
    ("B-06", "Treasury-Cloud-Report.pdf"),
    ("C-01", "2022-23230.pdf"),      # EO/SBOM/NTIA — ajuste conforme seu arquivo
    ("C-02", "2024-30983.pdf"),      # NIST 800-53 Rev.5 / FedRAMP Rev.5 — ajuste
    ("C-03", "2024-31372.pdf"),      # Zero Trust / CISA — ajuste
    ("C-04", "0e111127-16a7-4ddc-969b-78c0502a58bc.pdf"),  # SRE/observability — ajuste
    ("D-01", "recommendation-letter-Gaurav-update-latest-signed.pdf"),
    ("D-02", "recommendation-letter-Babita-update-latest-signed.pdf"),
    ("D-03", "recommendation-letter-cognizant-carlos.pdf"),
    ("D-04", "recommendation-letter-phillip-bmg.pdf"),
    ("D-05", "recommendation-letter-Bruno_english_serasa.pdf"),
    ("D-06", "recommendation-letter-JoséRicardoFerrazza_latest.pdf"),
    ("E-01", "CTPSDigital_unlocked.pdf"),
    ("E-02", "Demonstrativo de Pagamento-latest-month.pdf"),
]

start = 1
rows = []
for ex_id, fname in exhibits:
    if not os.path.exists(fname):
        rows.append([ex_id, fname, "MISSING", ""])
        continue
    pages = len(PdfReader(open(fname, "rb")).pages)
    end = start + pages - 1
    rows.append([ex_id, fname, pages, f"{start}-{end}"])
    start = end + 1

with open("ExhibitMap.csv", "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["Exhibit","File","Pages","BinderRange"])
    w.writerows(rows)

print("OK -> ExhibitMap.csv gerado.")
