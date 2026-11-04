import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'language.dart';

// Dates and numbers follow the app language (docs/ARCHITECTURE.md §11). The Turkish forms are the reference.

var _symbolsLoaded = false;

String get _locale {
  if (!_symbolsLoaded) {
    // Loads every locale's date symbols synchronously; the returned future is already complete.
    initializeDateFormatting();
    _symbolsLoaded = true;
  }
  return currentAppLanguage.code;
}

/// `18 Ekim 2026` / `October 18, 2026` in local time.
String formatDate(DateTime date) => DateFormat.yMMMMd(_locale).format(date.toLocal());

/// `18 Eki` / `Oct 18` in local time, for chart axes.
String formatDayMonth(DateTime date) => DateFormat.MMMd(_locale).format(date.toLocal());

/// `950`, `12,5 B`, `1,2 Mn` / `12.5K`: a short count for chart axes.
String formatCompact(num value) => NumberFormat.compact(locale: _locale).format(value);

/// `18 Ekim 2026, 09:05` / `October 18, 2026, 9:05 AM` in local time.
String formatDateTime(DateTime date) {
  final d = date.toLocal();
  return '${formatDate(d)}, ${DateFormat.jm(_locale).format(d)}';
}

/// `09:05` / `9:05 AM` in local time.
String formatTime(DateTime date) => DateFormat.jm(_locale).format(date.toLocal());

/// `Ekim 2026` / `October 2026` in local time.
String formatMonthYear(DateTime date) => DateFormat.yMMMM(_locale).format(date.toLocal());

/// Turkish: `249 ₺`, `2.490 ₺`, `249,90 ₺`; `$9.99`, `$1,999.00`. Other languages use their own currency format.
String formatMoney(int amountMinor, String currency) {
  if (_locale != 'tr') {
    final symbol = switch (currency) {
      'TRY' => '₺',
      'USD' => r'$',
      'EUR' => '€',
      _ => currency,
    };
    return NumberFormat.currency(
      locale: _locale,
      name: currency,
      symbol: symbol,
      decimalDigits: 2,
    ).format(amountMinor / 100);
  }
  final whole = amountMinor ~/ 100;
  final cents = (amountMinor % 100).toString().padLeft(2, '0');
  return switch (currency) {
    'TRY' => cents == '00' ? '${_grouped(whole, '.')} ₺' : '${_grouped(whole, '.')},$cents ₺',
    'USD' => '\$${_grouped(whole, ',')}.$cents',
    _ => '${_grouped(whole, '.')},$cents $currency',
  };
}

/// `10.000` / `10,000`, for limits.
String formatCount(int value) =>
    _locale == 'tr' ? _grouped(value, '.') : NumberFormat.decimalPattern(_locale).format(value);

String _grouped(int value, String separator) {
  final digits = value.toString();
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(separator);
    out.write(digits[i]);
  }
  return out.toString();
}
