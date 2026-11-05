"""Points guide_content.dart at every translated guide file in support/lib/src/domain/guide/ (docs/ARCHITECTURE.md §11).

Usage: python tool/l10n/guide_register.py
"""
import pathlib

app = pathlib.Path(__file__).resolve().parents[2]
domain = app / 'packages/features/support/lib/src/domain'
langs = sorted(p.stem for p in (domain / 'guide').glob('*.dart') if p.stem != 'tr')
imports = ''.join(f"import 'guide/{l}.dart';\n" for l in sorted(langs + ['tr']))
cases = ''.join(f'      AppLanguage.{l} => guide{l.capitalize()},\n' for l in langs)
fallback = '      AppLanguage.tr => guideTr,\n' if len(langs) == 11 else '      _ => guideTr,\n'
text = f"""import 'package:core/core.dart';

import 'guide.dart';
{imports}
/// The guide in the app language (docs/ARCHITECTURE.md §11, Kullanma kılavuzu). Every language has the same
/// chapters, topics, steps and notes; test/guide_test.dart checks it.
List<GuideChapter> get guideChapters => guideIn(currentAppLanguage);

List<GuideChapter> guideIn(AppLanguage language) => switch (language) {{
{cases}{fallback}    }};
"""
(domain / 'guide_content.dart').write_text(text, encoding='utf-8', newline='\n')
print('guide languages:', ', '.join(langs))
