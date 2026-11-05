"""One-off structural edits before localizing the events package (enum labels, weekday names, counts)."""
import pathlib, sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))
from dartedit import edit  # noqa: E402

app = pathlib.Path(__file__).resolve().parents[3]
E = str(app / 'packages/features/events/lib/src') + '/'

edit(str(app / 'packages/core/lib/src/formatting.dart'), [("/// `09:05` / `9:05 AM` in local time.", """/// `21 Ekim 2026 Salı` / `Tuesday, October 21, 2026` in local time.
String formatWeekdayDateYear(DateTime date) => DateFormat.yMMMMEEEEd(_locale).format(date.toLocal());

/// `Salı` / `Tuesday`.
String formatWeekday(DateTime date) => DateFormat.EEEE(_locale).format(date.toLocal());

/// Short weekday names from Monday: `Pzt … Paz` / `Mon … Sun`.
List<String> weekdayShortNames() => [for (var i = 0; i < 7; i++) DateFormat.E(_locale).format(DateTime(2024, 1, 1 + i))];

/// `09:05` / `9:05 AM` in local time.""")])

edit(E + 'presentation/calendar_screen.dart', [
    ("""  day('Gün'),
  week('Hafta'),
  month('Ay');

  const CalendarView(this.label);

  final String label;
}

const _weekdayNames = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
const _weekdayShort = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
""", """  day,
  week,
  month;

  String get label => switch (this) {
        day => eventsL10n.viewDay,
        week => eventsL10n.viewWeek,
        month => eventsL10n.viewMonth,
      };
}
"""),
    ("      return '${_weekdayNames[focus.weekday - 1]}, ${formatDate(focus)}';", "      return formatWeekdayDateYear(focus);"),
    ("Text('${_weekdayNames[_focus.weekday - 1]}, ${formatDate(_focus)}',", "Text(formatWeekdayDateYear(_focus),"),
    ("Text('${_weekdayNames[i]}, ${formatDate(DateTime(monday.year, monday.month, monday.day + i))}',",
     "Text(formatWeekdayDateYear(DateTime(monday.year, monday.month, monday.day + i)),"),
    ("            for (final name in _weekdayShort)", "            for (final name in weekdayShortNames())"),
], ["../l10n.dart"])

edit(E + 'presentation/upcoming.dart', [
    ("const _weekdays = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];\n\n", ""),
    ("      _ => _weekdays[day.weekday - 1],", "      _ => formatWeekday(day),"),
])

edit(E + 'domain/goals.dart', [
    ("""  personal('personal', 'Kişisel hedef', 'Her üye kendi sayısını tamamlar.'),
  group('group', 'Grup hedefi', 'Herkesin katkısı tek sayaçta toplanır.'),
  team('team', 'Takım hedefi', 'Yönetici takımları kurar; takımın ortak sayacı olur.'),
  task('task', 'Onaylı görev', 'Üye "Yaptım" der, yönetici onaylar.');

  const GoalKind(this.code, this.label, this.description);

  final String code;
  final String label;
  final String description;
""", """  personal('personal'),
  group('group'),
  team('team'),
  task('task');

  const GoalKind(this.code);

  final String code;

  String get label => switch (this) {
        personal => eventsL10n.goalPersonal,
        group => eventsL10n.goalGroup,
        team => eventsL10n.goalTeam,
        task => eventsL10n.goalTask,
      };

  String get description => switch (this) {
        personal => eventsL10n.goalPersonalHint,
        group => eventsL10n.goalGroupHint,
        team => eventsL10n.goalTeamHint,
        task => eventsL10n.goalTaskHint,
      };
"""),
    ("""  attended('attended', 'katılım'),
  organized('organized', 'düzenleme'),
  memories('memories', 'anı');

  const GoalMetric(this.code, this.unit);

  final String code;

  /// "4 katılım".
  final String unit;
""", """  attended('attended'),
  organized('organized'),
  memories('memories');

  const GoalMetric(this.code);

  final String code;

  /// The unit after a number: "4 katılım".
  String unitFor(int count) => switch (this) {
        attended => eventsL10n.unitAttended(count),
        organized => eventsL10n.unitOrganized(count),
        memories => eventsL10n.unitMemories(count),
      };
"""),
    ("""  pending('pending', 'Onay bekliyor'),
  approved('approved', 'Onaylandı'),
  rejected('rejected', 'Onaylanmadı');

  const ClaimStatus(this.code, this.label);

  final String code;""", """  pending('pending'),
  approved('approved'),
  rejected('rejected');

  const ClaimStatus(this.code);

  final String code;

  String get label => switch (this) {
        pending => eventsL10n.claimPending,
        approved => eventsL10n.claimApproved,
        rejected => eventsL10n.claimRejected,
      };"""),
    ("myClaim?.label ?? 'Henüz bildirilmedi') : '${formatCount(progress)} / ${formatCount(target)} ${metric!.unit}';",
     "myClaim?.label ?? eventsL10n.notClaimedYet) : '${formatCount(progress)} / ${formatCount(target)} ${metric!.unitFor(target)}';"),
], ["../l10n.dart"])

edit(E + 'domain/map.dart', [("""  any('Her zaman'),
  today('Bugün'),
  week('7 gün içinde');

  const MapWhen(this.label);

  final String label;""", """  any,
  today,
  week;

  String get label => switch (this) {
        any => eventsL10n.whenAny,
        today => eventsL10n.whenToday,
        week => eventsL10n.whenWeek,
      };""")], ["../l10n.dart"])

edit(E + 'domain/events.dart', [
    ("  String get label => weeks == 1 ? 'Her hafta tekrarlanır' : 'İki haftada bir tekrarlanır';",
     "  String get label => weeks == 1 ? eventsL10n.repeatsWeekly : eventsL10n.repeatsBiweekly;"),
    ("  String get place => surprise == null ? location : 'Sürpriz mekan · ${surprise!.venue ?? location}';",
     "  String get place => surprise == null ? location : eventsL10n.surprisePlace(surprise!.venue ?? location);"),
], ["../l10n.dart"])

edit(E + 'presentation/contributions.dart', [
    ("""      if (c.attended > 0) '${formatCount(c.attended)} katılım',
      if (c.organized > 0) '${formatCount(c.organized)} düzenleme',
      if (c.memories > 0) '${formatCount(c.memories)} anı',
      if (c.reviews > 0) '${formatCount(c.reviews)} değerlendirme',
      if (c.welcomed > 0) '${formatCount(c.welcomed)} karşılama',
      if (c.handshakes > 0) '${formatCount(c.handshakes)} el sıkış',""", """      if (c.attended > 0) eventsL10n.countAttended(c.attended),
      if (c.organized > 0) eventsL10n.countOrganized(c.organized),
      if (c.memories > 0) eventsL10n.countMemories(c.memories),
      if (c.reviews > 0) eventsL10n.countReviews(c.reviews),
      if (c.welcomed > 0) eventsL10n.countWelcomed(c.welcomed),
      if (c.handshakes > 0) eventsL10n.countHandshakes(c.handshakes),"""),
    ("""        if (c.attended > 0) '${formatCount(c.attended)} katılım',
        if (c.organized > 0) '${formatCount(c.organized)} düzenleme',""", """        if (c.attended > 0) eventsL10n.countAttended(c.attended),
        if (c.organized > 0) eventsL10n.countOrganized(c.organized),"""),
], ["../l10n.dart"])

edit(E + 'presentation/league.dart', [
    ("""      '${formatCount(r.attended)} katılım',
      '${formatCount(r.held)} organizasyon',
      if (r.welcomes > 0) '${formatCount(r.welcomes)} karşılama',
      if (r.goodReviews > 0) '${formatCount(r.goodReviews)} memnuniyet',""", """      eventsL10n.countAttended(r.attended),
      eventsL10n.countHeld(r.held),
      if (r.welcomes > 0) eventsL10n.countWelcomed(r.welcomes),
      if (r.goodReviews > 0) eventsL10n.countGoodReviews(r.goodReviews),"""),
    ("""                final rank? => '${formatMonthYear(l.month)}: ${formatCount(l.groups)} grup arasında $rank. sırada, '
                    '${formatCount(l.points)} puan.',""", """                final rank? => eventsL10n.leagueStanding(formatMonthYear(l.month), l.groups, rank, l.points),"""),
], ["../l10n.dart"])

edit(E + 'presentation/map_screens.dart', [
    ("""    e.capacity == null ? '${formatCount(e.goingCount)} katılımcı' : '${formatCount(e.goingCount)} / ${formatCount(e.capacity!)} katılımcı';""",
     """    e.capacity == null ? eventsL10n.goingCount(e.goingCount) : eventsL10n.goingOfCapacity(e.goingCount, e.capacity!);"""),
    ("""Text('${formatDateTime(e.startsAt.toLocal())} · ${e.surprise ? 'Sürpriz mekan · ' : ''}${e.location}',""",
     """Text('${formatDateTime(e.startsAt.toLocal())} · ${e.surprise ? eventsL10n.surprisePlace(e.location) : e.location}',"""),
], ["../l10n.dart"])

edit(E + 'presentation/goals.dart', [("""subtitle: Text('${formatCount(t.progress)} / ${formatCount(g.target)} ${g.metric?.unit ?? ''} · '
                    '${t.members.map((m) => m.displayName).join(', ')}'),""", """subtitle: Text('${formatCount(t.progress)} / ${formatCount(g.target)} ${g.metric?.unitFor(g.target) ?? ''} · '
                    '${formatList(t.members.map((m) => m.displayName))}'),""")], ["../l10n.dart"])

edit(E + 'presentation/story_cards.dart', [("""'Yılın ilk organizasyonu: $first${summary.firstEventAt == null ? '' : ' · ${formatDate(summary.firstEventAt!.toLocal())}'}',""",
                                             """summary.firstEventAt == null
                      ? eventsL10n.firstEventOfYear(first)
                      : eventsL10n.firstEventOfYearOn(first, formatDate(summary.firstEventAt!.toLocal())),""")], ["../l10n.dart"])
print('structure edits done')
