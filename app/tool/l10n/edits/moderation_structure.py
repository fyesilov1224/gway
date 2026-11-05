"""Moderation: enum labels become getters; split sentences get their own keys."""
import pathlib, re, sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))
from dartedit import edit, load  # noqa: E402

app = pathlib.Path(__file__).resolve().parents[3]
src = app / 'packages/features/moderation/lib/src'


def enum_getter(text, enum, keys, extra=None):
    """`a('a', 'Label')` values with `const E(this.code, this.label)` -> code only plus a label getter from [keys]."""
    start = text.index(f'enum {enum} {{')
    end = text.index('\n}', start)
    block = text[start:end]
    names = re.findall(r"^  (\w+)\('([^']+)'(?:, '[^']*')+\)[,;]", block, re.M)
    assert len(names) == len(keys), (enum, names)
    new = block
    for (name, code) in names:
        new = re.sub(rf"^  {name}\('{re.escape(code)}'(?:, '[^']*')+\)", f"  {name}('{code}')", new, flags=re.M)
    fields = ['label'] + ([extra[0]] if extra else [])
    new = new.replace(f"const {enum}(this.code, this.{', this.'.join(fields)});", f'const {enum}(this.code);')
    for f in fields:
        new = new.replace(f'  final String {f};\n', '')
    getters = '\n  String get label => switch (this) {\n' + ''.join(
        f'        {n} => moderationL10n.{k},\n' for (n, _), k in zip(names, keys)) + '      };\n'
    if extra:
        getters += f'\n  String get {extra[0]} => switch (this) {{\n' + ''.join(
            f'        {n} => moderationL10n.{k},\n' for (n, _), k in zip(names, extra[1])) + '      };\n'
    new = new.replace('  final String code;\n', '  final String code;\n' + getters, 1)
    return text[:start] + new + text[end:]


f = str(src / 'domain/moderation.dart')
s, nl = load(f)
s = s.replace('\r\n', '\n')
s = enum_getter(s, 'ReportReason', ['reasonSpam', 'reasonHarassment', 'reasonHate', 'reasonViolence', 'reasonSexual', 'reasonMisinformation', 'reasonOther'])
s = enum_getter(s, 'SanctionType', ['sanctionWarning', 'sanctionMute', 'sanctionKick', 'sanctionBan'])
s = enum_getter(s, 'IllegalCategory', ['illegalViolence', 'illegalThreat', 'illegalInsult', 'illegalHate', 'illegalSexual', 'illegalFraud', 'illegalDrugs',
                                       'illegalTerror', 'illegalOther'])
s = enum_getter(s, 'CaseThreshold', ['thresholdMajority', 'thresholdTwoThirds', 'thresholdUnanimous'],
                ('description', ['thresholdMajorityText', 'thresholdTwoThirdsText', 'thresholdUnanimousText']))
s = enum_getter(s, 'AppealStatus', ['appealPending', 'appealUpheld', 'appealOverturned'])
old = """      SanctionType.mute => '$days gün susturma',
      SanctionType.ban => days == null ? 'Kalıcı ban' : '$days gün ban',"""
assert old in s
s = s.replace(old, """      SanctionType.mute => moderationL10n.muteDays(days ?? 0),
      SanctionType.ban => days == null ? moderationL10n.permanentBan : moderationL10n.banDays(days),""")
old = """        'post' => 'Gönderi',
        'comment' => 'Yorum',
        'event' => 'Organizasyon',
        'live_comment' => 'Canlı yayın yorumu',
        'message' => 'Grup sohbeti mesajı',
        _ => 'Üye',"""
assert old in s
s = s.replace(old, """        'post' => moderationL10n.targetPost,
        'comment' => moderationL10n.targetComment,
        'event' => moderationL10n.targetEvent,
        'live_comment' => moderationL10n.targetLiveComment,
        'message' => moderationL10n.targetMessage,
        _ => moderationL10n.targetMember,""")
s = s.replace("import 'package:core/core.dart';\n", "import 'package:core/core.dart';\n\nimport '../l10n.dart';\n", 1)
open(f, 'w', encoding='utf-8', newline='').write(s.replace('\n', nl))

edit(str(src / 'data/moderation_repository_impl.dart'), [
    ("""const _rules = {
  'report_rate_limited': 'Bugün çok fazla şikayet gönderdin. Yarın tekrar deneyebilirsin.',
  'report_target_invalid': 'Bu içerik artık yok ya da göremiyorsun.',
  'report_self': 'Kendini ya da kendi içeriğini şikayet edemezsin.',
  'appeal_not_allowed': 'Bu yaptırıma artık itiraz edilemez.',
};""", """Map<String, String> get _rules => {
      'report_rate_limited': moderationL10n.ruleRateLimited,
      'report_target_invalid': moderationL10n.ruleTargetInvalid,
      'report_self': moderationL10n.ruleSelf,
      'appeal_not_allowed': moderationL10n.ruleAppealNotAllowed,
    };"""),
    ("const RuleFailure('moderation.duplicate', 'Bunu zaten bildirdin; inceleniyor.')", "RuleFailure('moderation.duplicate', moderationL10n.ruleDuplicate)"),
    ("_person(json) ?? const ModerationPerson(id: '', username: '', displayName: 'Silinmiş hesap');",
     "_person(json) ?? ModerationPerson(id: '', username: '', displayName: moderationL10n.deletedAccount);"),
], ['../l10n.dart'])

p = src / 'presentation'
edit(str(p / 'group_moderation_screen.dart'), [
    ("""    return hours == 0 ? '${left.inDays} gün' : '${left.inDays} gün $hours saat';
  }
  return left.inHours >= 1 ? '${left.inHours} saat' : 'birkaç dakika';""",
     """    return hours == 0 ? moderationL10n.leftDays(left.inDays) : moderationL10n.leftDaysHours(left.inDays, hours);
  }
  return left.inHours >= 1 ? moderationL10n.leftHours(left.inHours) : moderationL10n.leftFewMinutes;"""),
    ("""              ? '${s.type.label} · ${s.endsAt == null ? 'kalıcı' : '${formatDateTime(s.endsAt!)} tarihine kadar'}'""",
     """              ? '${s.type.label} · ${s.endsAt == null ? moderationL10n.permanentLower : moderationL10n.until(formatDateTime(s.endsAt!))}'"""),
    ("""Text('${c.direct ? 'Banlayan' : 'Dosyayı açan'}: ${opener.displayName}', style: secondary)""",
     """Text(c.direct ? moderationL10n.bannedBy(opener.displayName) : moderationL10n.openedBy(opener.displayName), style: secondary)"""),
], ['../l10n.dart'])
edit(str(p / 'case_sheet.dart'), [
    ("""                subtitle: Text(
                  '${_now ? 'Ban uygulanınca' : 'Kurul onaylarsa'} dosya platform ekibine gider ve hesap incelemeye kadar askıya '
                  'alınır. Bu işaret sonradan değişmez.',
                ),""", """                subtitle: Text(_now ? moderationL10n.illegalHintNow : moderationL10n.illegalHintVote),"""),
], ['../l10n.dart'])
edit(str(p / 'moderation_entry.dart'), [
    ("'${desk.pendingAppeals.length} itiraz'", 'moderationL10n.appealsCount(desk.pendingAppeals.length)'),
], ['../l10n.dart'])
print('moderation structure done')
