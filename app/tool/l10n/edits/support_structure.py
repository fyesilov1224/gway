"""Support: enum labels and rule messages become getters; the guide is chosen by the app language."""
import pathlib, subprocess, sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))
from dartedit import edit, load  # noqa: E402

app = pathlib.Path(__file__).resolve().parents[3]
src = app / 'packages/features/support/lib/src'
edit(str(src / 'domain/support.dart'), [
    ("""  problem('problem', 'Sorun', 'Bir şey bozuk ya da çalışmıyor.'),
  request('request', 'Talep', 'Hesabın, grubun ya da ödemen için bir işlem iste.'),
  suggestion('suggestion', 'İstek', 'Yeni bir özellik ya da öneri paylaş.');

  const SupportKind(this.code, this.label, this.description);

  final String code;
  final String label;
  final String description;""", """  problem('problem'),
  request('request'),
  suggestion('suggestion');

  const SupportKind(this.code);

  final String code;

  String get label => switch (this) {
        problem => supportL10n.kindProblem,
        request => supportL10n.kindRequest,
        suggestion => supportL10n.kindSuggestion,
      };

  String get description => switch (this) {
        problem => supportL10n.kindProblemText,
        request => supportL10n.kindRequestText,
        suggestion => supportL10n.kindSuggestionText,
      };"""),
    ("""  open('open', 'Yeni'),
  inProgress('in_progress', 'İnceleniyor'),
  resolved('resolved', 'Çözüldü'),
  closed('closed', 'Kapatıldı');

  const SupportStatus(this.code, this.label);

  final String code;
  final String label;""", """  open('open'),
  inProgress('in_progress'),
  resolved('resolved'),
  closed('closed');

  const SupportStatus(this.code);

  final String code;

  String get label => switch (this) {
        open => supportL10n.statusOpen,
        inProgress => supportL10n.statusInProgress,
        resolved => supportL10n.statusResolved,
        closed => supportL10n.statusClosed,
      };"""),
], ['../l10n.dart'])
edit(str(src / 'data/support_repository_impl.dart'), [
    ("""  /// Trigger codes users can run into, as Turkish messages.
  static const _rules = {
    'ticket_rate_limited': 'Bugün çok fazla mesaj açtın. Yarın tekrar deneyebilir ya da açık mesajlarına yazabilirsin.',
    'reply_rate_limited': 'Kısa sürede çok fazla yanıt yazdın. Biraz bekleyip tekrar dene.',
    'ticket_closed': 'Bu mesaj kapatıldı. Devam etmek için yeni bir mesaj aç.',
  };""", """  /// Trigger codes users can run into, in the app language.
  static Map<String, String> get _rules => {
        'ticket_rate_limited': supportL10n.ruleTicketRate,
        'reply_rate_limited': supportL10n.ruleReplyRate,
        'ticket_closed': supportL10n.ticketClosed,
      };"""),
], ['../l10n.dart'])

# The Turkish guide moves to its own file; guide_content.dart picks the language.
domain = src / 'domain'
(domain / 'guide').mkdir(exist_ok=True)
subprocess.run(['git', 'mv', str(domain / 'guide_content.dart'), str(domain / 'guide' / 'tr.dart')], check=True)
f = str(domain / 'guide' / 'tr.dart')
s, nl = load(f)
s = s.replace("import 'guide.dart';", "import '../guide.dart';", 1).replace('const guideChapters = <GuideChapter>[', 'const guideTr = <GuideChapter>[', 1)
open(f, 'w', encoding='utf-8', newline='').write(s)
print('support structure done')
