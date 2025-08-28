#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

MASTER="EB2_NIW_Petition_Package_MASTER.pdf"
OUT="EB2_NIW_FULL-BINDER.pdf"
TMP="TMP_SPLIT"

MODE_SIMPLE=false
MODE_DRYRUN=false
for arg in "${@:-}"; do
  case "$arg" in
    --simple) MODE_SIMPLE=true ;;
    --dry-run) MODE_DRYRUN=true ;;
  esac
done

# ===== LISTAS =====
ANNEX_A=(
  "Biden-Harris-Administrations-National-Security-Strategy-10.2022.pdf"
  "CMR-PREX23-00185928.pdf"
  "Treasury-Cloud-Report.pdf"
)
ANNEX_B=(
  "comptia-it-industry-outlook-2025.pdf"
  "comptia-state-of-the-tech-workforce-2024.pdf"
  "05-2025-CompTIA Tech Jobs Report.pdf"
  "Computer Network Architects _ Occupational Outlook Handbook_ _ U.S. Bureau of Labor Statistics-1.pdf"
  "Computer Network Architects _ Occupational Outlook Handbook_ _ U.S. Bureau of Labor Statistics-2.pdf"
  "Computer Network Architects _ Occupational Outlook Handbook_ _ U.S. Bureau of Labor Statistics-3.pdf"
  "WEF_Future_of_Jobs_Report_2025.pdf"
  "Skillsoft-IT-Skills-and-Salary-Report-2023.pdf"
)
ANNEX_D=(
  "Gustavo Ferreira AEE evaluation.pdf"
  "ENG_Gustavo_Ferreira_2025.docx.pdf"
)
ANNEX_E=(
  "Letter_of_Recommendation_JoséRicardoFerrazza_latest (1).pdf"
  "RECOMMENDATION LETTER COGNIZANT_unlocked.pdf"
)
ANNEX_G=(
  "carrear pathway 2025.drawio.pdf"
  "CTPSDigital_unlocked.pdf"
  "Demonstrativo de Pagamento-latest-month.pdf"
)

# ===== FUNÇÕES =====
is_encrypted() {
  local f="$1"
  pdfinfo "$f" 2>/dev/null | grep -iq '^Encrypted:\s*yes'
}

add_file() {
  local f="$1"
  [[ -z "$f" ]] && return 0
  if [[ ! -f "$f" ]]; then
    echo "[WARN] Arquivo não encontrado: $f" >&2
    return 0
  fi
  if is_encrypted "$f"; then
    echo "[WARN] PULANDO criptografado: $f" >&2
    return 0
  fi
  MERGE+=("$f")
}

# ===== PREP =====
if [[ ! -f "$MASTER" ]]; then
  echo "[ERRO] MASTER não encontrado: $MASTER"; exit 1
fi
rm -rf "$TMP"; mkdir -p "$TMP"
pdfseparate "$MASTER" "$TMP/MASTER_%03d.pdf"

have_anchors=false
if [[ -f "$TMP/MASTER_011.pdf" && -f "$TMP/MASTER_012.pdf" && -f "$TMP/MASTER_013.pdf" ]]; then
  have_anchors=true
fi

MERGE=()
if $MODE_SIMPLE || ! $have_anchors; then
  echo "[INFO] Modo SIMPLES (concatenação)."
  add_file "$MASTER"
  for f in "${ANNEX_A[@]}"; do add_file "$f"; done
  for f in "${ANNEX_B[@]}"; do add_file "$f"; done
  for f in "${ANNEX_D[@]}"; do add_file "$f"; done
  for f in "${ANNEX_E[@]}"; do add_file "$f"; done
  for f in "${ANNEX_G[@]}"; do add_file "$f"; done
else
  echo "[INFO] Modo INTERCALADO (âncoras 011/012/013)."
  for p in $(seq -f "%03g" 1 10); do add_file "$TMP/MASTER_${p}.pdf"; done

  add_file "$TMP/MASTER_011.pdf"
  for f in "${ANNEX_A[@]:0:3}"; do add_file "$f"; done
  for f in "${ANNEX_B[@]:0:2}"; do add_file "$f"; done

  add_file "$TMP/MASTER_012.pdf"
  for f in "${ANNEX_B[@]:2}"; do add_file "$f"; done
  for f in "${ANNEX_D[@]}"; do add_file "$f"; done
  for f in "${ANNEX_E[@]}"; do add_file "$f"; done

  add_file "$TMP/MASTER_013.pdf"
  for f in "${ANNEX_G[@]}"; do add_file "$f"; done

  # restinho do MASTER (14..fim)
  for f in "$TMP"/MASTER_*.pdf; do
    base="${f##*/}"; num="${base#MASTER_}"; num="${num%.pdf}"
    if (( 10#$num > 13 )); then add_file "$f"; fi
  done
fi

# ===== EXECUÇÃO =====
echo -n "[INFO] pdfunite"; for f in "${MERGE[@]}"; do printf ' "%s"' "$f"; done; printf ' "%s"\n' "$OUT"

if $MODE_DRYRUN; then
  echo "[DRY-RUN] Não mesclado. (Use sem --dry-run para gerar o PDF.)"
  exit 0
fi

pdfunite "${MERGE[@]}" "$OUT" || { echo "[ERRO] pdfunite falhou."; exit 1; }
rm -rf "$TMP" 2>/dev/null || true
echo "[OK] Gerado: $OUT"
