import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:events/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _group = EventGroup(id: 'g1', handle: 'doga', name: 'Doğa Yürüyüşçüleri');
const _ayse = EventPerson(id: 'u2', username: 'ayse', displayName: 'Ayşe Yıldız');

class _FakeEvents implements EventsRepository {
  final shaken = <String>[];
  List<MetPerson> met = const [];

  @override
  Future<Result<HandshakeCode>> handshakeCode(String eventId) async =>
      Ok(HandshakeCode(code: 'ABC234', expiresAt: DateTime.now().add(const Duration(minutes: 3))));

  @override
  Future<Result<HandshakeResult>> shake(String eventId, String code) async {
    shaken.add(code);
    return const Ok(HandshakeResult(person: _ayse, alreadyMet: false));
  }

  @override
  Future<Result<List<MetPerson>>> metPeople() async => Ok(met);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(Widget child, _FakeEvents events) => ProviderScope(
      overrides: [currentUserIdProvider.overrideWithValue('u1'), eventsRepositoryProvider.overrideWithValue(events)],
      child: MaterialApp(theme: GwTheme.light(), home: child),
    );

GroupEvent _event(DateTime startsAt, {AttendanceStatus? status = AttendanceStatus.going}) =>
    GroupEvent(id: 'e1', group: _group, title: 'Akşam yürüyüşü', startsAt: startsAt, location: 'Sahil', myStatus: status);

void main() {
  test('handshakes open an hour before the start and close six hours after the end, for those going', () {
    final start = DateTime(2026, 11, 7, 18);
    expect(handshakeOpen(_event(start), start.subtract(const Duration(minutes: 61))), isFalse);
    expect(handshakeOpen(_event(start), start.subtract(const Duration(minutes: 59))), isTrue);
    // Without an end an event takes two hours.
    expect(handshakeOpen(_event(start), start.add(const Duration(hours: 7, minutes: 59))), isTrue);
    expect(handshakeOpen(_event(start), start.add(const Duration(hours: 8, minutes: 1))), isFalse);
    expect(handshakeOpen(_event(start, status: AttendanceStatus.waitlisted), start), isFalse);
    expect(HandshakeCode(code: 'ABC234', expiresAt: start).qrData('e1'), 'gway-handshake:e1:ABC234');
  });

  testWidgets('my code shows as a QR code and as letters', (tester) async {
    await tester.pumpWidget(_app(const HandshakeScreen(eventId: 'e1', eventTitle: 'Akşam yürüyüşü'), _FakeEvents()));
    await tester.pump();
    expect(find.text('ABC 234'), findsOneWidget);
    expect(find.bySemanticsLabel('El sıkış kodun'), findsOneWidget);
  });

  testWidgets('a typed code shakes hands and says who it was', (tester) async {
    final events = _FakeEvents();
    await tester.pumpWidget(_app(const HandshakeScreen(eventId: 'e1'), events));
    await tester.tap(find.text('Okut'));
    await tester.pumpAndSettle();
    expect(find.text('Karşındakinin ekranındaki 6 haneli kodu yaz.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'xyz 789');
    await tester.ensureVisible(find.widgetWithText(GwButton, 'El sıkış'));
    await tester.tap(find.widgetWithText(GwButton, 'El sıkış'));
    // The button keeps its spinner while the dialog is open, so the frames never settle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(events.shaken, ['xyz 789']);
    expect(find.text('Tanıştınız!'), findsOneWidget);
    expect(find.text('Ayşe Yıldız (@ayse)'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

  testWidgets('"Tanıştıklarım" says how to start when empty', (tester) async {
    await tester.pumpWidget(_app(const MetPeopleScreen(), _FakeEvents()));
    await tester.pumpAndSettle();
    expect(find.textContaining('El sıkış, organizasyon sayfasında açılır'), findsOneWidget);
  });

  testWidgets('"Tanıştıklarım" lists who and where', (tester) async {
    final events = _FakeEvents()
      ..met = [
        MetPerson(
          person: _ayse,
          eventId: 'e1',
          eventTitle: 'Akşam yürüyüşü',
          eventStartsAt: DateTime(2026, 10, 30, 18),
          groupName: 'Doğa Yürüyüşçüleri',
          metAt: DateTime(2026, 10, 30, 19),
        ),
      ];
    await tester.pumpWidget(_app(const MetPeopleScreen(), events));
    await tester.pumpAndSettle();
    expect(find.text('Ayşe Yıldız'), findsOneWidget);
    expect(find.textContaining('@ayse · Akşam yürüyüşü'), findsOneWidget);
  });

  test('contributions count handshakes', () {
    expect(contributionLine(const Contributions(attended: 3, handshakes: 12)), '3 katılım · 12 el sıkış');
  });
}

