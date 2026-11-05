"""Puts back quoted Turkish names that a double-quote match replaced inside // comments."""
import json, pathlib, re, sys
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))
from dartedit import load, save  # noqa: E402

app = pathlib.Path(__file__).resolve().parents[3]
texts = {}
for arb in app.glob('**/lib/l10n/*_tr.arb'):
    if 'build' in arb.parts:
        continue
    pkg = arb.stem[:-3]
    getter = re.sub(r'_(\w)', lambda m: m.group(1).upper(), pkg) + 'L10n'
    texts[getter] = json.loads(arb.read_text(encoding='utf-8'))
ref = re.compile(r'\b([a-z][A-Za-z]*L10n)\.([a-zA-Z0-9]+)\b')
fixed = 0
for p in app.glob('**/lib/**/*.dart'):
    if 'build' in p.parts or '.dart_tool' in p.parts or p.parent.name == 'l10n':
        continue
    s, nl = load(p)
    out = []
    changed = False
    for line in s.split('\n'):
        if line.lstrip().startswith('//') and ref.search(line):
            def sub(m):
                t = texts.get(m.group(1), {}).get(m.group(2))
                return '"' + t + '"' if isinstance(t, str) else m.group(0)
            new = ref.sub(sub, line)
            changed |= new != line
            line = new
        out.append(line)
    if changed:
        save(p, '\n'.join(out), nl)
        fixed += 1
print('files fixed:', fixed)
