#!/usr/bin/env bash
set -euo pipefail
FILE="${1:?usage: patch_citations_extra_index.sh index.md}"

python - "$FILE" << 'PY'
import re, sys, shutil, datetime, io
p = sys.argv[1]
stamp = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
shutil.copyfile(p, p + f".bak_{stamp}")
text = io.open(p, 'r', encoding='utf-8', errors='ignore').read()

def add_code(line, code):
    if re.search(r'\[%s([^\]]*)\]' % re.escape(code), line): return line
    m = re.search(r'\[([A-E]-\d+(?:; ?[A-E]-\d+)*)\]', line)
    if m:
        inside = m.group(1)
        if code in inside.split('; '): return line
        new = inside + "; " + code
        return line[:m.start(1)] + new + line[m.end(1):]
    return line.rstrip("\n") + f" **[{code}]**\n"

def patch_block(block, rules):
    out = []
    for ln in block.splitlines(True):
        for pat,codes in rules:
            if pat.search(ln):
                for code in codes:
                    ln = add_code(ln, code)
        out.append(ln)
    return "".join(out)

heads = [(m.start(), m.group(0)) for m in re.finditer(r'(?m)^##\s+.*$', text)]
heads.append((len(text), 'END'))
sections = []
for i,(pos,h) in enumerate(heads[:-1]):
    end = heads[i+1][0]
    sections.append((pos,end,h))

rules1 = [
 (re.compile(r'(?i)WS-1 .*?(NIST|FedRAMP)'), ['C-03']),
 (re.compile(r'(?i)WS-2 .*?(SBOM|software supply chain|artifact signing|provenance)'), ['C-02']),
 (re.compile(r'(?i)WS-3 .*?(Kubernetes|OpenShift|GitOps|OPA|PodSecurity|image hardening)'), ['C-03']),
 (re.compile(r'(?i)WS-4 .*?(Observability|Reliability|SLO|incident|DR)'), ['C-04']),
 (re.compile(r'(?i)M\d.*?(controls via .*IaC|policy-as-code)'), ['C-01','C-02','C-03']),
 (re.compile(r'(?i)(lead time|MTTR|change failure|SLO|availability)'), ['B-05','B-06']),
]
rules2 = [
 (re.compile(r'(?i)Prong 1 .*?(NSS|National Security Strategy|EO[-\s]?14028|SBOM|FedRAMP|NIST)'), ['C-01','C-02','C-03']),
 (re.compile(r'(?i)Prong 2 .*?(letters|recommendation|well positioned|Multi-cloud credentials)'), ['D-01']),
 (re.compile(r'(?i)Prong 3 .*?(Zero-Trust|national interest|public-interest|critical infrastructure)'), ['C-01','C-02','C-04']),
]
rules4 = [
 (re.compile(r'(?i)Prong 1'), ['C-01','C-02','C-03']),
 (re.compile(r'(?i)Prong 2'), ['D-01']),
 (re.compile(r'(?i)Prong 3'), ['C-01','C-02','C-04']),
 (re.compile(r'(?i)\\bSBOM\\b'), ['C-02']),
 (re.compile(r'(?i)\\b(FedRAMP|NIST)\\b'), ['C-03']),
 (re.compile(r'(?i)critical infrastructure|CISA'), ['C-04']),
 (re.compile(r'(?i)\\b(BLS|WEF)\\b'), ['B-05','B-06']),
]

out = []
for (pos,end,h) in sections:
    block = text[pos:end]
    hb = h.lower()
    if hb.startswith('## 1') or hb.startswith('## 1)') or hb.startswith('## 1.'):
        block = patch_block(block, rules1)
    elif hb.startswith('## 2') or hb.startswith('## 2)') or hb.startswith('## 2.'):
        block = patch_block(block, rules2)
    elif hb.startswith('## 4') or hb.startswith('## 4)') or hb.startswith('## 4.'):
        block = patch_block(block, rules4)
    out.append(block)
io.open(p,'w',encoding='utf-8').write("".join(out))
print("[OK] Extra inline citations patched into", p, "Backup:", p + f".bak_{stamp}")
PY
