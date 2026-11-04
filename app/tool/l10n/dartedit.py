"""Small helpers for scripted Dart edits during localization (keeps line endings and import order)."""
import re


def load(path):
    raw = open(path, encoding='utf-8', newline='').read()
    return raw.replace('\r\n', '\n'), ('\r\n' if '\r\n' in raw else '\n')


def save(path, text, nl):
    open(path, 'w', encoding='utf-8', newline='').write(text.replace('\n', nl))


_IMPORT = re.compile(r"^import '([^']+)'(.*);$")


def add_import(text, uri):
    """Adds `import '<uri>';` keeping dart: / package: / relative groups sorted (directives_ordering)."""
    if f"import '{uri}'" in text:
        return text
    lines = text.split('\n')
    idx = [i for i, l in enumerate(lines) if _IMPORT.match(l)]
    if not idx:
        return f"import '{uri}';\n\n" + text
    first, last = idx[0], idx[-1]
    block = [l for l in lines[first:last + 1] if l.strip()]
    if any(not _IMPORT.match(l) for l in block):  # comments or multi-line imports: append at end of block
        lines.insert(last + 1, f"import '{uri}';")
        return '\n'.join(lines)
    block.append(f"import '{uri}';")

    def group(l):
        u = _IMPORT.match(l).group(1)
        return 0 if u.startswith('dart:') else 1 if u.startswith('package:') else 2

    out = []
    for g in (0, 1, 2):
        items = sorted({l for l in block if group(l) == g}, key=lambda l: _IMPORT.match(l).group(1))
        if items:
            if out:
                out.append('')
            out.extend(items)
    return '\n'.join(lines[:first] + out + lines[last + 1:])


def edit(path, pairs, imports=(), count_check=True):
    """Replaces each (old, new) exactly once (or all with ('*', old, new)) and adds imports."""
    s, nl = load(path)
    for pair in pairs:
        if len(pair) == 3:
            _, a, b = pair
            assert a in s, (path, a)
            s = s.replace(a, b)
        else:
            a, b = pair
            n = s.count(a)
            assert n == 1 or (not count_check and n >= 1), (path, n, a)
            s = s.replace(a, b, 1)
    for uri in imports:
        s = add_import(s, uri)
    save(path, s, nl)
