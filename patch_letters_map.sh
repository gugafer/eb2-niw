#!/usr/bin/env bash
set -euo pipefail
FILE="${1:?usage: patch_letters_map.sh <file.md>}"

python - "$FILE" << 'PY'
import re, sys, shutil, datetime, io

p = sys.argv[1]
stamp = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
shutil.copyfile(p, p + f".bak_{stamp}")
text = io.open(p, 'r', encoding='utf-8', errors='ignore').read()

letters = [
 ("D-01","Babita","recommendation-letter-Babita-update-latest-signed.pdf"),
 ("D-02","Bruno","recommendation-letter-Bruno_english_serasa.pdf"),
 ("D-03","Carlos","recommendation-letter-cognizant-carlos.pdf"),
 ("D-04","Gaurav","recommendation-letter-Gaurav-update-latest-signed.pdf"),
 ("D-05","José Ricardo Ferrazza","recommendation-letter-JoséRicardoFerrazza_latest.pdf"),
 ("D-06","Phillip","recommendation-letter-phillip-bmg.pdf"),
]

# 1) LETTER MAP block
start = "<!-- LETTER_MAP_START -->"
end = "<!-- LETTER_MAP_END -->"
body = "\n".join(f"[{c}]: {n} (PDF: {f})" for c,n,f in letters)
block = f"{start}\n{body}\n{end}"
if start in text and end in text:
    text = re.sub(re.escape(start)+r".*?"+re.escape(end), block, text, flags=re.S)
else:
    text += "\n\n" + block + "\n"

# 2) Add codes when names appear
def add_code(line, code):
    if re.search(r'\[%s([^\]]*)\]' % re.escape(code), line): return line
    return line.rstrip("\n") + f" **[{code}]**\n"

lines = text.splitlines(True)
for i,ln in enumerate(lines):
    L = ln
    for code,name,_ in letters:
        if re.search(rf'\b{re.escape(name)}\b', L, flags=re.I):
            L = add_code(L, code)
    lines[i] = L
text = "".join(lines)

# 3) Appendix B updated table
table = """
### Appendix B — Letters of Recommendation (updated)

| Code  | Recommender                | File (Drive)                                             |
|:-----:|----------------------------|----------------------------------------------------------|
| D-01  | Babita                     | recommendation-letter-Babita-update-latest-signed.pdf    |
| D-02  | Bruno                      | recommendation-letter-Bruno_english_serasa.pdf           |
| D-03  | Carlos                     | recommendation-letter-cognizant-carlos.pdf               |
| D-04  | Gaurav                     | recommendation-letter-Gaurav-update-latest-signed.pdf    |
| D-05  | José Ricardo Ferrazza      | recommendation-letter-JoséRicardoFerrazza_latest.pdf     |
| D-06  | Phillip                    | recommendation-letter-phillip-bmg.pdf                    |

"""
text += "\n" + table

io.open(p,'w',encoding='utf-8').write(text)
print("[OK] Letter map + Appendix B updated in", p, "Backup:", p + f".bak_{stamp}")
PY
