import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/age.dart';
import 'auth_layout.dart';
import 'providers.dart';

/// Asks once for the date of birth; under 18 cannot go on (docs/ARCHITECTURE.md §3a, Yaş sınırı).
class BirthDateScreen extends ConsumerStatefulWidget {
  const BirthDateScreen({super.key});

  @override
  ConsumerState<BirthDateScreen> createState() => _BirthDateScreenState();
}

class _BirthDateScreenState extends ConsumerState<BirthDateScreen> {
  DateTime? _date;
  bool _saving = false;
  String? _error;

  Future<void> _pick() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime(today.year - 25),
      firstDate: DateTime(1900),
      lastDate: today,
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Doğum tarihin',
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final date = _date;
    if (date == null) {
      setState(() => _error = 'Doğum tarihini seç.');
      return;
    }
    if (ageOn(date, DateTime.now()) < minimumAge) {
      setState(() => _error = 'GrupX\'i kullanmak için en az $minimumAge yaşında olmalısın.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final result = await ref.read(birthDateRepositoryProvider).save(date);
    if (!mounted) return;
    switch (result) {
      case Ok():
        ref.invalidate(birthDateProvider);
      case Err(:final failure):
        setState(() {
          _saving = false;
          _error = failure.userMessage;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Doğum tarihin',
      subtitle: 'GrupX $minimumAge yaş ve üstündekiler içindir. Doğum tarihin kimseye gösterilmez ve sonradan değiştirilemez.',
      children: [
        OutlinedButton.icon(
          onPressed: _saving ? null : _pick,
          icon: const Icon(Icons.cake_outlined),
          label: Text(_date == null ? 'Tarih seç' : formatDateTr(_date!)),
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(GxSpacing.buttonHeight)),
        ),
        const SizedBox(height: GxSpacing.md),
        if (_error != null) ...[GxFormMessage(_error!), const SizedBox(height: GxSpacing.md)],
        GxButton(label: 'Devam et', onPressed: _save, isLoading: _saving, expand: true),
        const SizedBox(height: GxSpacing.sm),
        GxButton(
          label: 'Çıkış yap',
          variant: GxButtonVariant.text,
          onPressed: _saving ? null : () => ref.read(authRepositoryProvider).signOut(),
        ),
      ],
    );
  }
}
