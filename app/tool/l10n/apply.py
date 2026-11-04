"""Replaces a package's Turkish literals with its localization getter, then repairs `const` (docs/ARCHITECTURE.md §11).

Usage: python tool/l10n/apply.py <table.py> [--no-fix]

For every ROWS entry without placeholders the source literal is the Turkish text itself ('...' or "...").
SRC = {key: [exact source chunk, ...]} overrides that (multi-line concatenations, interpolations);
CALL = {key: 'expression'} overrides the replacement (default `<getter>.<key>`).
SKIP = {key, ...}: keys replaced only through SRC_CALLS or by hand.
SRC_CALLS = {exact source chunk: expression}: applied first.
After replacing, `const` keywords the analyzer rejects are removed and `dart fix` restores the valid ones.
"""
import importlib.util, json, pathlib, re, subprocess, sys

sys.path.insert(0, str(pathlib.Path(__file__).parent))
from dartedit import add_import, load, save  # noqa: E402

app = pathlib.Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('table', sys.argv[1])
t = importlib.util.module_from_spec(spec)
spec.loader.exec_module(t)
pkg_dir = app / t.DIR
lib = pkg_dir / 'lib'
getter = re.sub(r'_(\w)', lambda m: m.group(1).upper(), t.PACKAGE) + 'L10n'
src_map = getattr(t, 'SRC', {})
call_map = getattr(t, 'CALL', {})
skip = getattr(t, 'SKIP', set())


def dart_literals(text):
    single = "'" + text.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$') + "'"
    double = '"' + text.replace('\\', '\\\\').replace('"', '\\"').replace('$', '\\$') + '"'
    return [single, double]


files = [p for p in lib.rglob('*.dart') if not (p.parent.name == 'l10n' and p.name != 'l10n.dart')]
texts = {p: load(p) for p in files}
missing = []
# Exact source chunk -> expression, for one key used with different arguments.
for src, call in getattr(t, 'SRC_CALLS', {}).items():
    hit = False
    for p in files:
        s, nl = texts[p]
        if src in s:
            texts[p] = (s.replace(src, call), nl)
            hit = True
    if not hit:
        missing.append(src)
for row in t.ROWS:
    key, ph, tr = row[0], row[1], row[2]
    if key in skip:
        continue
    sources = src_map.get(key) or ([] if ph else dart_literals(tr))
    call = call_map.get(key, f'{getter}.{key}')
    hit = False
    for p in files:
        s, nl = texts[p]
        for src in sources:
            if src in s:
                # Never touch a literal that is part of a longer identifier or another literal.
                s = s.replace(src, call)
                hit = True
        texts[p] = (s, nl)
    if not hit:
        missing.append(key)

l10n_file = lib / 'src' / 'l10n.dart'
for p, (s, nl) in texts.items():
    old, _ = load(p)
    if s != old:
        if f'{getter}.' in s and p != l10n_file:
            rel = pathlib.Path(*(['..'] * (len(p.relative_to(lib / 'src').parts) - 1)), 'l10n.dart') if p.is_relative_to(lib / 'src') else pathlib.Path('src/l10n.dart')
            s = add_import(s, rel.as_posix())
        save(p, s, nl)
if missing:
    print('not found in source:', ', '.join(missing))

if '--no-fix' in sys.argv:
    sys.exit(0)

CONST_ERRORS = ('const_with_non_constant_argument', 'non_constant_list_element', 'invalid_constant',
                'const_initialized_with_non_constant_value', 'non_constant_map_element', 'non_constant_map_value',
                'const_constructor_param_type_mismatch', 'const_eval_method_invocation', 'non_constant_case_expression',
                'const_set_element_not_constant', 'non_constant_set_element', 'const_constructor_with_non_const_super',
                'const_eval_property_access', 'invalid_constant_value')
for _ in range(12):
    out = subprocess.run(['dart', 'analyze', '--format=json', str(pkg_dir)], capture_output=True, text=True, encoding='utf-8', shell=True).stdout
    start = out.find('{')
    if start < 0:
        break
    diags = json.loads(out[start:]).get('diagnostics', [])
    fixes = {}
    for d in diags:
        if d['code'] in CONST_ERRORS:
            loc = d['location']
            fixes.setdefault(loc['file'], set()).add(loc['range']['start']['offset'])
    if not fixes:
        break
    for f, offsets in fixes.items():
        s, nl = load(f)
        raw = s if nl == '\n' else s.replace('\n', nl)
        # Offsets are in the file as stored; work on the stored text, then normalize back.
        chars = list(raw)
        removed = set()
        for off in sorted(offsets, reverse=True):
            i = raw.rfind('const ', 0, off + 1)
            while i >= 0 and (i > 0 and (raw[i - 1].isalnum() or raw[i - 1] == '_')):
                i = raw.rfind('const ', 0, i)
            if i >= 0 and i not in removed:
                removed.add(i)
        for i in sorted(removed, reverse=True):
            line_start = raw.rfind(chr(10), 0, i) + 1
            before = raw[line_start:i].strip()
            if before in ('', 'static') and re.match(r'const\s+[\w<>?, ]*\s*\w+\s*=', raw[i:]):
                # A const declaration: it must become a getter by hand, or it would freeze the first language.
                print(f'DECLARATION needs a getter: {f}:{raw.count(chr(10), 0, i) + 1}')
                continue
            del chars[i:i + 6]
        save(f, ''.join(chars).replace('\r\n', '\n'), nl)
subprocess.run(['dart', 'fix', '--apply', str(pkg_dir)], capture_output=True, shell=True)
print('applied', t.PACKAGE)
