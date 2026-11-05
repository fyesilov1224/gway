"""Lists the Turkish user-facing sentences in the C# backend (docs/ARCHITECTURE.md §11, Sunucu).

Usage: python tool/l10n/server_extract.py [--json out.json]

Every string literal ("..." or $"...") with Turkish letters or a sentence end is a candidate, except log lines,
the admin module and *Administration.cs (the admin panel stays Turkish) and the push sentences (PushTexts.cs has
its own table). Interpolations become {0}, {1}, ...; adjacent literals joined with + are merged.
"""
import json, pathlib, re, sys

root = pathlib.Path(__file__).resolve().parents[3] / 'backend' / 'src'
skip_parts = {'obj', 'bin', 'Gway.Modules.Admin'}
lit = re.compile(r'(\$?)"((?:[^"\\\n]|\\.)*)"')
turkish = re.compile(r'[çğıöşüÇĞİÖŞÜ]')


def template(is_interp, body):
    if not is_interp:
        return body.replace('\\"', '"')
    out, i, n = [], 0, 0
    while i < len(body):
        c = body[i]
        if c == '{' and body[i + 1:i + 2] == '{':
            out.append('{'); i += 2; continue
        if c == '}' and body[i + 1:i + 2] == '}':
            out.append('}'); i += 2; continue
        if c == '{':
            depth, j = 1, i + 1
            while depth and j < len(body):
                depth += {'{': 1, '}': -1}.get(body[j], 0); j += 1
            out.append('{%d}' % n); n += 1; i = j; continue
        out.append(c); i += 1
    return ''.join(out).replace('\\"', '"')


found = {}
for f in sorted(root.rglob('*.cs')):
    if skip_parts & set(f.parts) or f.name.endswith('Administration.cs') or f.name == 'PushTexts.cs':
        continue
    text = f.read_text(encoding='utf-8')
    # Merge "a" + "b" and $"a" + $"b" across lines.
    text = re.sub(r'"\s*\+\s*\$?"', '', text)
    for line_no, line in enumerate(text.splitlines(), 1):
        if re.search(r'\bLog(Information|Warning|Error|Debug|Critical)\b|logger\.|_log\.', line):
            continue
        for m in lit.finditer(line):
            t = template(m.group(1) == '$', m.group(2))
            if turkish.search(t) and len(t) > 3:
                found.setdefault(t, f'{f.relative_to(root)}:{line_no}')

if '--json' in sys.argv:
    out = pathlib.Path(sys.argv[sys.argv.index('--json') + 1])
    out.write_text(json.dumps(found, ensure_ascii=False, indent=1), encoding='utf-8')
for t, where in found.items():
    print(f'{where}\t{t}')
print(f'-- {len(found)} sentences', file=sys.stderr)
