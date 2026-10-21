import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats dates in Turkish', () {
    final date = DateTime(2026, 2, 3, 9, 5);

    expect(formatDateTr(date), '3 Şubat 2026');
    expect(formatDateTimeTr(date), '3 Şubat 2026, 09:05');
    expect(formatMonthYearTr(date), 'Şubat 2026');
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
}
