"""Prepares a package for gen_l10n (docs/ARCHITECTURE.md §11).

Usage: python tool/l10n/setup_package.py <package-dir from app/> <package name> <ClassName>
Creates l10n.yaml, lib/src/l10n.dart (global getter `<package>L10n`), adds flutter_localizations, intl and
`flutter: generate: true` to pubspec.yaml (keeping its line endings). Safe to run twice.
"""
import pathlib, re, sys

root = pathlib.Path(__file__).resolve().parents[2]
pkg_dir, pkg, cls = sys.argv[1], sys.argv[2], sys.argv[3]
d = root / pkg_dir
getter = re.sub(r'_(\w)', lambda m: m.group(1).upper(), pkg) + 'L10n'
CR = chr(13)
LF = chr(10)

(d / 'l10n.yaml').write_text(
    f"""arb-dir: lib/l10n
template-arb-file: {pkg}_tr.arb
output-dir: lib/src/l10n
output-localization-file: {pkg}_l10n.dart
output-class: {cls}
nullable-getter: false
""", encoding='utf-8')

src = d / 'lib' / 'src' / 'l10n.dart'
src.parent.mkdir(parents=True, exist_ok=True)
src.write_text(
    f"""import 'package:core/core.dart';

import 'l10n/{pkg}_l10n.dart';

export 'l10n/{pkg}_l10n.dart' show {cls};

/// This package's texts in the app language (docs/ARCHITECTURE.md §11).
{cls} get {getter} => lookup{cls}(currentAppLocale);
""", encoding='utf-8')

p = d / 'pubspec.yaml'
raw = p.read_bytes().decode('utf-8')
crlf = CR + LF in raw
s = raw.replace(CR + LF, LF)
if 'flutter_localizations:' not in s:
    s = s.replace('  flutter:\n    sdk: flutter\n', '  flutter:\n    sdk: flutter\n  flutter_localizations:\n    sdk: flutter\n', 1)
if re.search(r'^  intl:', s, re.M) is None:
    s = re.sub(r'(^dependencies:\n)', r'\1  intl: ^0.20.2\n', s, count=1, flags=re.M)
if re.search(r'^flutter:', s, re.M) is None:
    s = s.rstrip('\n') + '\n\nflutter:\n  generate: true\n'
elif 'generate: true' not in s:
    s = re.sub(r'^flutter:\n', 'flutter:\n  generate: true\n', s, count=1, flags=re.M)
p.write_bytes((s.replace(LF, CR + LF) if crlf else s).encode('utf-8'))
print(f'{pkg_dir}: {cls}, getter {getter}')
