"""Writes a package's ARB files from a translation table (docs/ARCHITECTURE.md §11).

Usage: python tool/l10n/write_arb.py <table.py>
The table module defines PACKAGE (e.g. 'core'), DIR (package path from app/),
KEYS: list of (key, description, placeholders: dict name->type, list of String names, or None) and T: {lang: [text, ...]} in KEYS order.
Turkish ('tr') is the template. Existing keys not in the table are kept, so a package can be filled in parts.
"""
import importlib.util, json, pathlib, sys

LANGS = ['tr', 'en', 'de', 'fr', 'nl', 'es', 'pt', 'it', 'ru', 'ar', 'az', 'uk']

def main(path):
    spec = importlib.util.spec_from_file_location('table', path)
    t = importlib.util.module_from_spec(spec); spec.loader.exec_module(t)
    root = pathlib.Path(__file__).resolve().parents[2] / t.DIR / 'lib' / 'l10n'
    root.mkdir(parents=True, exist_ok=True)
    for lang in LANGS:
        texts = t.T[lang]
        if len(texts) != len(t.KEYS):
            sys.exit(f'{lang}: {len(texts)} texts for {len(t.KEYS)} keys')
        f = root / f'{t.PACKAGE}_{lang}.arb'
        data = json.loads(f.read_text(encoding='utf-8')) if f.exists() else {}
        data['@@locale'] = lang
        for (key, desc, ph), text in zip(t.KEYS, texts):
            data[key] = text
            if lang == 'tr':
                meta = {'description': desc}
                if ph:
                    # {'count': 'int'}; a plain list means String placeholders.
                    types = ph if isinstance(ph, dict) else {p: 'String' for p in ph}
                    meta['placeholders'] = {p: {'type': ty} for p, ty in types.items()}
                data['@' + key] = meta
        ordered = {'@@locale': lang, **{k: v for k, v in data.items() if k != '@@locale'}}
        f.write_text(json.dumps(ordered, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(f'{t.PACKAGE}: {len(t.KEYS)} keys x {len(LANGS)} languages')

if __name__ == '__main__':
    main(sys.argv[1])
