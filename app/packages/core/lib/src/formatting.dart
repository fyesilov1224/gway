const _months = [
  'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
  'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
];

/// `18 Ekim 2026` in local time.
String formatDateTr(DateTime date) {
  final d = date.toLocal();
  return '${d.day} ${_months[d.month - 1]} ${d.year}';
}

/// `18 Eki` in local time, for chart axes.
String formatDayMonthTr(DateTime date) {
  final d = date.toLocal();
  return '${d.day} ${_months[d.month - 1].substring(0, 3)}';
}

/// `950`, `12,5 B`, `1,2 Mn`: a short count for chart axes.
String formatCompactTr(num value) {
  String one(double v) => (v >= 100 ? v.round().toString() : v.toStringAsFixed(1).replaceAll('.0', '')).replaceAll('.', ',');
  final abs = value.abs();
  if (abs >= 1000000) return '${one(value / 1000000)} Mn';
  if (abs >= 1000) return '${one(value / 1000)} B';
  return value.round().toString();
}

/// `18 Ekim 2026, 09:05` in local time.
String formatDateTimeTr(DateTime date) {
  final d = date.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${formatDateTr(d)}, ${two(d.hour)}:${two(d.minute)}';
}

/// `Ekim 2026` in local time.
String formatMonthYearTr(DateTime date) {
  final d = date.toLocal();
  return '${_months[d.month - 1]} ${d.year}';
}

/// `249 ₺`, `2.490 ₺`, `249,90 ₺`; `$9.99`, `$1,999.00`.
String formatMoney(int amountMinor, String currency) {
  final whole = amountMinor ~/ 100;
  final cents = (amountMinor % 100).toString().padLeft(2, '0');
  return switch (currency) {
    'TRY' => cents == '00' ? '${_grouped(whole, '.')} ₺' : '${_grouped(whole, '.')},$cents ₺',
    'USD' => '\$${_grouped(whole, ',')}.$cents',
    _ => '${_grouped(whole, '.')},$cents $currency',
  };
}

/// `10.000`, for limits.
String formatCount(int value) => _grouped(value, '.');

String _grouped(int value, String separator) {
  final digits = value.toString();
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(separator);
    out.write(digits[i]);
  }
  return out.toString();
}
