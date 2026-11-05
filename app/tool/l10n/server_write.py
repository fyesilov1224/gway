"""Writes the server translations (tables/server_*.py) to Gway.SharedKernel/Localization/server_texts.json.

Usage: python tool/l10n/server_write.py

Each Turkish sentence must still exist in the C# source; a missing one is
reported, because the backend would never ask for it. See docs/ARCHITECTURE.md §11, Sunucu.
"""
import importlib.util, json, os, pathlib, subprocess, sys

here = pathlib.Path(__file__).resolve().parent
repo = here.parents[2]
langs = ['en', 'de', 'fr', 'nl', 'es', 'pt', 'it', 'ru', 'ar', 'az', 'uk']
texts = {}
for table in sorted((here / 'tables').glob('server_*.py')):
    spec = importlib.util.spec_from_file_location(table.stem, table)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    for row in mod.ROWS:
        tr, rest = row[0], list(row[1:])
        assert len(rest) == len(langs), (table.name, tr)
        assert tr not in texts, ('duplicate', tr)
        for lang, value in zip(langs, rest):
            for i in range(10):
                if ('{%d}' % i in tr) != ('{%d}' % i in value):
                    sys.exit(f'placeholder {{{i}}} differs in {lang}: {tr}')
        texts[tr] = rest

out = subprocess.run([sys.executable, str(here / 'server_extract.py')], capture_output=True, text=True, encoding='utf-8',
                     env={**os.environ, 'PYTHONIOENCODING': 'utf-8'}).stdout
extracted = {line.split('\t', 1)[1] for line in out.splitlines() if '\t' in line}
# Sentences the extractor cannot see (no Turkish letters, raw strings) count when the source has them anywhere.
source = ''.join(f.read_text(encoding='utf-8') for f in (repo / 'backend/src').rglob('*.cs') if 'obj' not in f.parts)
source = source.replace('\\"', '"')
missing = [t for t in texts if t not in extracted and t not in source]
for t in missing:
    print('not in the backend:', t)

target = repo / 'backend/src/Gway.SharedKernel/Localization/server_texts.json'
target.parent.mkdir(exist_ok=True)
target.write_text(json.dumps({'languages': langs, 'texts': texts}, ensure_ascii=False, indent=1) + '\n', encoding='utf-8', newline='\n')
print(f'{len(texts)} sentences x {len(langs) + 1} languages -> {target.relative_to(repo)}')
