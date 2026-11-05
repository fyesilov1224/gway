import 'events.dart';

/// The person's current handshake code at an event (docs/ARCHITECTURE.md §3d, El sıkış).
class HandshakeCode {
  const HandshakeCode({required this.code, required this.expiresAt});

  /// Six letters and digits without look-alikes.
  final String code;
  final DateTime expiresAt;

  /// What the QR code carries; the server also accepts the bare code.
  String qrData(String eventId) => 'gway-handshake:$eventId:$code';

  /// "ABC 234": easier to read aloud and type.
  String get spaced => '${code.substring(0, 3)} ${code.substring(3)}';
}

/// Who the person just met.
class HandshakeResult {
  const HandshakeResult({required this.person, required this.alreadyMet});

  final EventPerson person;

  /// They had already shaken hands at this event.
  final bool alreadyMet;
}

/// One line of "Tanıştıklarım": the person, and where and when they met.
class MetPerson {
  const MetPerson({
    required this.person,
    required this.eventId,
    required this.eventTitle,
    required this.eventStartsAt,
    required this.groupName,
    required this.metAt,
  });

  final EventPerson person;
  final String eventId;
  final String eventTitle;
  final DateTime eventStartsAt;
  final String groupName;
  final DateTime metAt;
}

/// From an hour before the start until six hours after the end, for those going.
bool handshakeOpen(GroupEvent e, DateTime now) =>
    !e.isCanceled &&
    e.myStatus == AttendanceStatus.going &&
    !now.isBefore(e.startsAt.subtract(const Duration(hours: 1))) &&
    !now.isAfter(e.endsOrDefault.add(const Duration(hours: 6)));
