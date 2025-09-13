#!/usr/bin/env bash
set -euo pipefail

REBUILD=0
SRC=""
ZIP=""

for arg in "$@"; do
  case "$arg" in
    --rebuild) REBUILD=1 ;;
    --src=*) SRC="${arg#*=}" ;;
    --zip=*) ZIP="${arg#*=}" ;;
    *) ;;
  esac
done

today=$(date +%F)
[[ -z "$ZIP" ]] && ZIP="EB2_NIW_FINAL_${today}.zip"

find_binder() {
  local explicit="${1:-}"
  if [[ -n "$explicit" && -f "$explicit" ]]; then
    if command -v realpath >/dev/null 2>&1; then realpath "$explicit"; else echo "$explicit"; fi
    return
  fi
  for c in EB2_NIW_Binder_FINAL_TOPLEVEL.pdf EB2_NIW_Binder_FINAL_GROUPED.pdf EB2_NIW_Binder_FINAL_CLEAN.pdf; do
    [[ -f "$c" ]] && { if command -v realpath >/dev/null 2>&1; then realpath "$c"; else echo "$c"; fi; return; }
  done
  echo ""
}

# 1) (Opcional) rebuild
if [[ $REBUILD -eq 1 ]]; then
  if [[ -f ./release_build_v2.sh ]]; then
    echo "[RUN] release_build_v2.sh"
    bash ./release_build_v2.sh || true
  elif [[ -f ./release_build_v2.ps1 ]]; then
    echo "[RUN] release_build_v2.ps1"
    if command -v pwsh >/dev/null 2>&1; then
      pwsh -NoLogo -ExecutionPolicy Bypass -File ./release_build_v2.ps1 || true
    else
      powershell -ExecutionPolicy Bypass -File ./release_build_v2.ps1 || true
    fi
  else
    echo "[WARN] release_build_v2.* não encontrado; seguindo sem rebuild."
  fi
fi

# 2) Binder de origem
src=$(find_binder "$SRC")
[[ -z "$src" ]] && { echo "Nenhum binder encontrado. Use --src=..."; exit 1; }
echo "[SRC] $src"

print="EB2_NIW_Binder_FINAL_PRINT.pdf"
flat="EB2_NIW_Binder_FINAL_PRINT_FLAT.pdf"

# 3) Gerar PRINT
if [[ -f remove_link_annots_v2.py ]]; then
  echo "[RUN] remove_link_annots_v2.py"
  python3 remove_link_annots_v2.py "$src" "$print"
elif [[ -f remove_link_annots.py ]]; then
  echo "[RUN] remove_link_annots.py"
  python3 remove_link_annots.py "$src" "$print"
else
  echo "[WARN] script de remover links não encontrado; copiando binder para PRINT."
  cp -f "$src" "$print"
fi

# 4) Linearizar com qpdf
if command -v qpdf >/dev/null 2>&1; then
  echo "[RUN] qpdf --linearize → $flat"
  qpdf --object-streams=generate --linearize "$print" "$flat"
else
  echo "[WARN] qpdf não encontrado; PRINT_FLAT = PRINT."
  cp -f "$print" "$flat"
fi

# 5) Montar lista para ZIP
files=()
for p in index_protocol.pdf EB2_NIW_Binder_FINAL_TOPLEVEL.pdf EB2_NIW_Binder_FINAL_GROUPED.pdf EB2_NIW_Binder_FINAL_CLEAN.pdf EB2_NIW_Binder_FINAL_PRINT.pdf EB2_NIW_Binder_FINAL_PRINT_FLAT.pdf; do
  [[ -f "$p" ]] && files+=("$p")
done
if [[ -f EB2_NIW_Petition_Package_MASTER._SYNCED.md ]]; then
  files+=("EB2_NIW_Petition_Package_MASTER._SYNCED.md")
elif [[ -f EB2_NIW_Petition_Package_MASTER.md ]]; then
  files+=("EB2_NIW_Petition_Package_MASTER.md")
fi
if [[ -f index._SYNCED.md ]]; then
  files+=("index._SYNCED.md")
elif [[ -f index.md ]]; then
  files+=("index.md")
fi

# 6) Compactar
rm -f "$ZIP"
if command -v zip >/dev/null 2>&1; then
  zip -9 -r "$ZIP" "${files[@]}"
elif command -v 7z >/dev/null 2>&1; then
  7z a -tzip "$ZIP" "${files[@]}"
else
  echo "[WARN] nem 'zip' nem '7z' encontrados; gerando tar.gz"
  tar -czf "${ZIP%.zip}.tar.gz" "${files[@]}"
  ZIP="${ZIP%.zip}.tar.gz"
fi

echo
echo "== Artefatos =="
declare -A seen
for a in "$print" "$flat" "$ZIP" "${files[@]}"; do
  [[ -f "$a" ]] || continue
  [[ -n "${seen[$a]:-}" ]] && continue
  seen[$a]=1
  size=$(stat -c%s "$a" 2>/dev/null || wc -c <"$a")
  md5=$( (command -v md5sum >/dev/null && md5sum "$a" | cut -d' ' -f1) || (command -v md5 >/dev/null && md5 -q "$a") )
  sha=$( (command -v sha256sum >/dev/null && sha256sum "$a" | cut -d' ' -f1) || shasum -a 256 "$a" | cut -d' ' -f1 )
  printf "%s\t%s bytes\tMD5=%s\tSHA256=%s\n" "$(basename "$a")" "$size" "$md5" "$sha"
done
