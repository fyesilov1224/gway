import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/age.dart';
import '../l10n.dart';
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
      helpText: identityL10n.birthDateTitle,
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final date = _date;
    if (date == null) {
      setState(() => _error = identityL10n.chooseBirthDate);
      return;
    }
    if (ageOn(date, DateTime.now()) < minimumAge) {
      setState(() => _error = identityL10n.ageMinimum(minimumAge));
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
      title: identityL10n.birthDateTitle,
      subtitle: identityL10n.birthDateExplain(minimumAge),
      children: [
        OutlinedButton.icon(
          onPressed: _saving ? null : _pick,
          icon: const Icon(Icons.cake_outlined),
          label: Text(_date == null ? identityL10n.chooseDate : formatDate(_date!)),
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(GwSpacing.buttonHeight)),
        ),
        const SizedBox(height: GwSpacing.md),
        if (_error != null) ...[GwFormMessage(_error!), const SizedBox(height: GwSpacing.md)],
        GwButton(label: identityL10n.continueAction, onPressed: _save, isLoading: _saving, expand: true),
        const SizedBox(height: GwSpacing.sm),
        GwButton(
          label: identityL10n.signOut,
          variant: GwButtonVariant.text,
          onPressed: _saving ? null : () => ref.read(authRepositoryProvider).signOut(),
        ),
      ],
    );
  }
}
