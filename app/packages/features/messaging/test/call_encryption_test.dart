import 'package:flutter_test/flutter_test.dart';
import 'package:messaging/src/data/call_encryption.dart';

void main() {
  test('both phones derive the same audio key and safety code', () {
    final a = CallKeyAgreement.generate();
    final b = CallKeyAgreement.generate();

    final onA = a.derive(b.publicKey, 'call-1')!;
    final onB = b.derive(a.publicKey, 'call-1')!;

    expect(onA.audioKey, onB.audioKey);
    expect(onA.safetyCode, onB.safetyCode);
    expect(onA.safetyCode, matches(RegExp(r'^\d{4} \d{4} \d{4}$')));
    expect(onA.confirmation, onB.confirmation, reason: 'the phones confirm the match to each other');
  });

  test('someone in between gets different codes on the two phones', () {
    final a = CallKeyAgreement.generate();
    final b = CallKeyAgreement.generate();
    final m1 = CallKeyAgreement.generate();
    final m2 = CallKeyAgreement.generate();

    final onA = a.derive(m1.publicKey, 'call-1')!;
    final onB = b.derive(m2.publicKey, 'call-1')!;

    expect(onA.safetyCode, isNot(onB.safetyCode));
    expect(onA.audioKey, isNot(onB.audioKey));
    expect(onA.confirmation, isNot(onB.confirmation), reason: 'the phones see that the codes differ');
  });

  test('another call or a fresh key pair gives another key', () {
    final a = CallKeyAgreement.generate();
    final b = CallKeyAgreement.generate();

    expect(a.derive(b.publicKey, 'call-1')!.audioKey, isNot(a.derive(b.publicKey, 'call-2')!.audioKey));
    expect(CallKeyAgreement.generate().publicKey, isNot(a.publicKey));
  });

  test('a broken or own key is refused', () {
    final a = CallKeyAgreement.generate();

    expect(a.derive('not-a-key', 'call-1'), isNull);
    expect(a.derive('AAAA', 'call-1'), isNull);
    expect(a.derive(a.publicKey, 'call-1'), isNull);
  });
}
