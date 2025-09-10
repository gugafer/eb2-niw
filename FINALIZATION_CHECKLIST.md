awesome — let’s lock this in. Below is a **compact, English-only Finalization Checklist** you can paste at the top of your repo (e.g., `FINALIZATION_CHECKLIST.md`). It assumes your working folder is the `eb2-niw` directory we’ve been using and keeps your backups **in place** (no cleanup or dedupe).

---

# EB-2 NIW Petition — Finalization Checklist (Print-Ready)

> **Goal:** produce a binder-ready, USCIS-compliant, **print** package with clear pagination, exhibits A/B/C/D/E, and testable KPIs—keeping your existing backups intact.

## A) Source of Truth & Language

* [ ] **English only** for all petition prose (MASTER + index).
* [ ] **Single source of truth**:

  * `EB2_NIW_Petition_Package_MASTER.md` (content)
  * `index.md` (protocol skeleton)
  * Keep all copies in place for **RFE**; do not delete.

## B) Merge & Inline Citations

* [ ] Merge **Proposed Endeavor (verbatim)** from MASTER → `index.md`.

  * **Command (PowerShell):**

    ```powershell
    .\merge_index_from_master.ps1 -IndexPath "index.md" -MasterPath "EB2_NIW_Petition_Package_MASTER.md"
    ```
* [ ] Apply **inline citations** in §§1, 2, 4 (A-01…C-04, etc.).

  * **Command (PowerShell):**

    ```powershell
    .\patch_citations_1_2_4.ps1 -File "EB2_NIW_Petition_Package_MASTER.md"
    ```
* [ ] Crosswalk sanity: your Annex IDs match references in text:

  * **A-01** NSS 2022 • **A-02** EO 14028/SBOM • **A-03** Treasury Cloud
  * **B-01** WEF 2025 • **B-02** CompTIA 2024 • **B-03** BLS 2024
  * **C-01** NIST 800-53 Rev.5 • **C-02** FedRAMP • **C-03** SBOM/Signing/Provenance • **C-04** SRE/Zero-Trust

## C) KPIs / “National Why”

* [ ] Keep your **baselines** as “maintained” and ensure each tech paragraph includes a **one-line national interest** (already provided in §3 and §4).
* [ ] Confirm **testable KPIs** appear (Lead Time, MTTR, CFR, SLOs, % controls automated, % services with SBOM/signing).

## D) Letters (Appendix B)

* [ ] Attach **signed PDFs** (do **not** OCR signed documents with digital signatures).
* [ ] Complete Appendix B table (name, title, org, independence, summary of claims, exhibit code E-0x).
* [ ] If any letter lacks text layer and **no digital signature**, you may OCR to improve searchability.

## E) OCR, PDF/A & Known Edge Cases (only where needed)

* [ ] For non-signed PDFs that need text layer:

  * **OCRmyPDF (safe defaults):**

    ```powershell
    ocrmypdf --optimize 0 --output-type pdfa-2b --jobs 4 "in.pdf" "in_ocr.pdf"
    ```
* [ ] If you see **DigitalSignatureError** → **skip OCR** on that file.
* [ ] If you see **ColorConversionNeededError** (e.g., Treasury Cloud) → rerun with:

  ```powershell
  ocrmypdf --output-type pdf --color-conversion-strategy RGB "in.pdf" "in_rgb.pdf"
  ```

  (keeps original colors; skips strict PDF/A)

## F) HTML (serif) & Protocol PDF (no visible links)

* [ ] Ensure `print_serif.css` is present (we provided it).
* [ ] Build HTML + PDF with TOC (bookmarks), but **hidden links** for print:

  ```powershell
  pandoc "EB2_NIW_Petition_Package_MASTER.md" `
    --from=gfm --to=html5 --standalone `
    --toc --toc-depth=3 `
    --css="print_serif.css" `
    --metadata title="EB-2 NIW Petition Package — Gustavo de Oliveira Ferreira" `
    -o "index_protocol.html"

  wkhtmltopdf --enable-local-file-access `
    --margin-top 22mm --margin-bottom 20mm --margin-left 18mm --margin-right 18mm `
    "index_protocol.html" "index_protocol.pdf"
  ```

  > If you use LaTeX/PDF engines: keep `\hypersetup{hidelinks}` or equivalent to avoid colored/underlined links.

## G) Binder Assembly & Bookmarks (Exhibits A/B/C/D/E)

* [ ] Confirm **dividers** pages text (e.g., “Divider A”, “EXHIBITS — A”) exist.
* [ ] Run your binder pipeline to produce the final combined PDF.
* [ ] If PyPDF2 shows **MemoryError**, switch to **PyMuPDF** (we already did in your scripts).
* [ ] If MuPDF shows “**invalid key in dict**” or xref errors:

  ```powershell
  mutool clean -gg "Binder.pdf" "Binder_clean.pdf"
  ```
* [ ] Add grouped **Exhibits A/B/C/D/E** bookmarks under “Exhibits”:

  ```powershell
  python add_grouped_exhibit_bookmarks.py "EB2_NIW_Binder_FINAL_bookmarked.pdf" "EB2_NIW_Binder_FINAL_GROUPED.pdf"
  ```

  * If a divider isn’t detected automatically, set its page number in the script (`page_A = 6`, etc.).

## H) Pagination & ExhibitMap

* [ ] Regenerate **ExhibitMap.csv** (your latest is present).
* [ ] Validate start–end page ranges after the final binder is built.
* [ ] If offsets are off, rerun your **auto-offset** or **scan** script; if errors persist, first `mutool clean -gg`, then rerun.

## I) Dhanasar Consistency Checks

* [ ] **Prong 1**: national importance explicitly tied to **NSS 2022 / EO 14028 / FedRAMP/NIST** and public-interest workloads.
* [ ] **Prong 2**: “well positioned” backed by **credentials + letters + deliverables** in §3.
* [ ] **Prong 3**: on-balance argument ties **time-to-compliance**, **exposure windows**, **supply-chain** risk, and **service continuity**.

## J) Print-Run Readiness

* [ ] Generate **exhibit dividers PDF** (you already have it) and confirm headings are large and clear.
* [ ] Do a **test print** of 5–10 pages (one from each section) to confirm margins, serif readability, and grayscale fidelity.
* [ ] Assemble binder: **Front Matter → Dividers → Exhibits (A→E)**.
* [ ] Optional: spine label & tab stickers (A/B/C/D/E).

## K) RFE-Readiness (no deletion)

* [ ] Keep **all** earlier copies as backup **in place**.
* [ ] Maintain an **RFE bundle** folder containing: the signed letters, raw PDFs from sources, and the final **ExhibitMap.csv**.

---

## Quick Commands (copy/paste)

```powershell
# 1) Merge §3 (verbatim) into index.md
.\merge_index_from_master.ps1 -IndexPath "index.md" -MasterPath "EB2_NIW_Petition_Package_MASTER.md"

# 2) Patch inline citations (§§1,2,4)
.\patch_citations_1_2_4.ps1 -File "EB2_NIW_Petition_Package_MASTER.md"

# 3) Build HTML (serif) + PDF (hidden links for print)
pandoc "EB2_NIW_Petition_Package_MASTER.md" --from=gfm --to=html5 --standalone --toc --toc-depth=3 --css="print_serif.css" --metadata title="EB-2 NIW Petition Package — Gustavo de Oliveira Ferreira" -o "index_protocol.html"
wkhtmltopdf --enable-local-file-access --margin-top 22mm --margin-bottom 20mm --margin-left 18mm --margin-right 18mm "index_protocol.html" "index_protocol.pdf"

# 4) Clean a problematic binder (only if errors), then add grouped exhibit bookmarks
mutool clean -gg "EB2_NIW_Binder_FINAL_bookmarked.pdf" "EB2_NIW_Binder_FINAL_clean.pdf"
python add_grouped_exhibit_bookmarks.py "EB2_NIW_Binder_FINAL_clean.pdf" "EB2_NIW_Binder_FINAL_GROUPED.pdf"
```

---

### Optional sanity notes (based on your past logs)

* **DigitalSignatureError** → do **not** OCR that letter; keep as is.
* **ColorConversionNeededError** (Treasury Cloud PDF) → use `--output-type pdf` and `--color-conversion-strategy RGB`.
* **“Invalid key in dict” / xref errors** → `mutool clean -gg` before running the bookmark scripts.

---

If you want, I can also give you a **one-liner “release checklist”** you can paste as the top comment in your `add_bookmarks_pymupdf_scan.py` so every run is consistent.
