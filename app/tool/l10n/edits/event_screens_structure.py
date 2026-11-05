"""Structural edits in event_screens.dart before localizing it (dates, month badges, seat lines)."""
import pathlib, sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))
from dartedit import edit  # noqa: E402

app = pathlib.Path(__file__).resolve().parents[3]
f = str(app / 'packages/features/events/lib/src/presentation/event_screens.dart')

edit(f, [
    ("""const _weekdays = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
const _shortMonths = ['OCA', 'ŞUB', 'MAR', 'NİS', 'MAY', 'HAZ', 'TEM', 'AĞU', 'EYL', 'EKİ', 'KAS', 'ARA'];

String _two(int v) => v.toString().padLeft(2, '0');

/// `Cumartesi, 25 Ekim 2026 · 09:00–13:00`
String eventWhen(GroupEvent e) {
  final s = e.startsAt.toLocal();
  final end = e.endsAt?.toLocal();
  final sameDay = end != null && end.year == s.year && end.month == s.month && end.day == s.day;
  final until = end == null ? '' : sameDay ? '–${_two(end.hour)}:${_two(end.minute)}' : ' – ${formatDateTime(end)}';
  return '${_weekdays[s.weekday - 1]}, ${formatDate(s)} · ${_two(s.hour)}:${_two(s.minute)}$until';
}""", """/// `25 Ekim 2026 Cumartesi · 09:00–13:00` in the app language.
String eventWhen(GroupEvent e) {
  final s = e.startsAt.toLocal();
  final end = e.endsAt?.toLocal();
  final sameDay = end != null && end.year == s.year && end.month == s.month && end.day == s.day;
  final until = end == null ? '' : sameDay ? '–${formatTime(end)}' : ' – ${formatDateTime(end)}';
  return '${formatWeekdayDateYear(s)} · ${formatTime(s)}$until';
}

/// `EKİ` / `OCT`: the month on a calendar sheet.
String _shortMonth(DateTime d) => DateFormat.MMM(currentAppLanguage.code).format(d).replaceAll('.', '').toUpperCase();"""),
    ("""/// "12 / 20 kişi", "12 kişi katılıyor".
String eventSeats(GroupEvent e) => e.capacity == null
    ? '${formatCount(e.goingCount)} kişi katılıyor'
    : '${formatCount(e.goingCount)} / ${formatCount(e.capacity!)} kişi${e.waitlistCount > 0 ? ' · ${formatCount(e.waitlistCount)} bekliyor' : ''}';""",
     """/// "12 / 20 kişi", "12 kişi katılıyor".
String eventSeats(GroupEvent e) => e.capacity == null
    ? eventsL10n.seatsGoing(e.goingCount)
    : e.waitlistCount > 0
        ? eventsL10n.seatsOfWaiting(e.goingCount, e.capacity!, e.waitlistCount)
        : eventsL10n.seatsOf(e.goingCount, e.capacity!);"""),
    ("""      '${formatCount(e.goingCount)} kişi katıldı',
      if (e.ratingAvg case final avg?) '${ratingLabel(avg)} ★ (${formatCount(e.ratingCount)} değerlendirme)',
      if (e.postsCount > 0) '${formatCount(e.postsCount)} anı',""", """      eventsL10n.summaryAttended(e.goingCount),
      if (e.ratingAvg case final avg?) eventsL10n.summaryRating(ratingLabel(avg), e.ratingCount),
      if (e.postsCount > 0) eventsL10n.countMemories(e.postsCount),"""),
    ("Text(_shortMonths[d.month - 1], style:", "Text(_shortMonth(d), style:"),
    ("GwBadge('Bekleme listesi · ${e.myPlace ?? '-'}. sıra', tone: GwBadgeTone.info),", "GwBadge(eventsL10n.waitlistPlace(e.myPlace ?? 0), tone: GwBadgeTone.info),"),
    ("""Text('Bu organizasyon iptal edildi${e.cancelReason == null ? '.' : ': ${e.cancelReason}'}',""",
     """Text(e.cancelReason == null ? eventsL10n.eventCanceled : eventsL10n.eventCanceledBecause(e.cancelReason!),"""),
    ("""Text('${r.person!.displayName} · ${'★' * r.rating}', style: textTheme.labelLarge),""",
     """Text('${r.person!.displayName} · ${'★' * r.rating}', style: textTheme.labelLarge, semanticsLabel: eventsL10n.reviewBy(r.person!.displayName, r.rating)),"""),
], ['package:intl/intl.dart'])
print('event_screens structure done')
