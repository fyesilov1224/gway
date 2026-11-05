import 'dart:ui';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats dates in Turkish', () {
    final date = DateTime(2026, 2, 3, 9, 5);

    expect(formatDate(date), '3 Şubat 2026');
    expect(formatDateTime(date), '3 Şubat 2026, 09:05');
    expect(formatMonthYear(date), 'Şubat 2026');
  });

  test('formats lira and dollars from minor units', () {
    expect(formatMoney(24900, 'TRY'), '249 ₺');
    expect(formatMoney(1999000, 'TRY'), '19.990 ₺');
    expect(formatMoney(24990, 'TRY'), '249,90 ₺');
    expect(formatMoney(999, 'USD'), r'$9.99');
    expect(formatMoney(199900, 'USD'), r'$1,999.00');
    expect(formatMoney(0, 'TRY'), '0 ₺');
    expect(formatCount(10000), '10.000');
  });

  test('chart axes: short counts and short dates', () {
    expect(formatCompact(950), '950');
    expect(formatCompact(1000), '1 B');
    expect(formatCompact(12500), '12,5 B');
    expect(formatCompact(250000), '250 B');
    expect(formatCompact(1200000), '1,2 Mn');
    expect(formatDayMonth(DateTime(2026, 10, 27)), '27 Eki');
    expect(formatDayMonth(DateTime(2026, 8, 3)), '3 Ağu');
  });

  test('follows the app language', () {
    final date = DateTime(2026, 2, 3, 9, 5);
    addTearDown(() => setCurrentAppLanguage(AppLanguage.tr));
    setCurrentAppLanguage(AppLanguage.en);
    expect(formatDate(date), 'February 3, 2026');
    expect(formatMoney(999, 'USD'), r'$9.99');
    expect(formatCount(10000), '10,000');
    setCurrentAppLanguage(AppLanguage.de);
    expect(formatDate(date), '3. Februar 2026');
    expect(formatMoney(24900, 'TRY'), '249,00 ₺');
    expect(coreL10n.networkFailure, startsWith('Keine Verbindung'));
  });

  test('Arabic: 0-9 digits like the rest of the app, @names kept whole in right-to-left text', () {
    addTearDown(() => setCurrentAppLanguage(AppLanguage.tr));
    setCurrentAppLanguage(AppLanguage.ar);
    expect(formatDate(DateTime(2026, 11, 5)), contains('2026'));
    expect(atName('demo'), '\u{2066}@demo\u{2069}');
  });

  test('picks the device language or English', () {
    expect(AppLanguage.fromDevice(const [Locale('ja'), Locale('de', 'AT')]), AppLanguage.de);
    expect(AppLanguage.fromDevice(const [Locale('ja')]), AppLanguage.en);
    expect(AppLanguage.parse('pt-BR'), AppLanguage.pt);
  });
}
