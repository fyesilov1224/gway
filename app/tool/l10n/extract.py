"""Lists user-facing string literals of a package that are not localized yet.

Usage: python tool/l10n/extract.py <package-dir from app/> [--all]
Prints `file:line: 'literal'`. Heuristic: literals with Turkish letters or with a space between words;
imports, keys, routes and generated code are skipped. --all prints every multi-word literal too.
"""
import pathlib, re, sys

root = pathlib.Path(__file__).resolve().parents[2]
d = root / sys.argv[1] / 'lib'
show_all = '--all' in sys.argv
lit = re.compile(r"(?<![A-Za-z0-9_])(r?)'((?:[^'\\\n]|\\.)*)'|(?<![A-Za-z0-9_])\"((?:[^\"\\\n]|\\.)*)\"")
tr = re.compile('[çğıöşüÇĞİÖŞÜâîûÂÎÛ]')
word = re.compile(r'^[A-ZÇĞİÖŞÜ][a-zçğıöşüâîû]{2,}[.!?]?$')
skip_line = re.compile(r"^\s*(import|export|part)\b|^\s*//")
n = 0
for p in sorted(d.rglob('*.dart')):
    rel = p.relative_to(root / sys.argv[1])
    if 'l10n' in p.parts and p.parts[-2] == 'l10n' and p.name != 'l10n.dart':
        continue
    for i, line in enumerate(p.read_text(encoding='utf-8').split('\n'), 1):
        if skip_line.match(line):
            continue
        for m in lit.finditer(line):
            text = m.group(2) if m.group(2) is not None else m.group(3)
            if text is None or text == '':
                continue
            ui = re.search(r"(Text|label|labelText|hintText|helperText|title|tooltip|message|semanticLabel|content|subtitle|actionLabel|errorText|counterText|prefixText|suffixText)\s*[:(]\s*(const\s+)?(Text\()?$", line[:m.start()].rstrip()) is not None
            ctor = re.search(r'[A-Z]\w*\(\s*$', line[:m.start()]) is not None and re.fullmatch('[a-zçğıöşü]{3,}', text) is not None
            if ctor or (ui and re.search('[A-Za-zÇĞİÖŞÜçğıöşü]{2,}', text) and not re.fullmatch(r'[a-z_.]+', text)) or tr.search(text) or word.match(text) or (show_all and re.search(r'[A-Za-z]{2,} [A-Za-z]{2,}', text)) or re.match(r'^[A-ZÇĞİÖŞÜ][a-zçğıöşü]+( [a-zçğıöşüA-Z]+){1,}[.!?…]?$', text):
                print(f'{rel}:{i}: {m.group(0)}')
                n += 1
print(f'-- {n} literals', file=sys.stderr)
