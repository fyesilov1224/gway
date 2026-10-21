import 'package:core/core.dart';

enum AccountStatus { active, suspended, pendingDeletion }

class AccountState {
  const AccountState({
    required this.status,
    this.suspendedUntil,
    this.suspensionReason,
    this.deletionScheduledFor,
  });

  factory AccountState.fromJson(Map<String, Object?> json) => AccountState(
        status: switch (json['status']) {
          'suspended' => AccountStatus.suspended,
          'pending_deletion' => AccountStatus.pendingDeletion,
          _ => AccountStatus.active,
        },
        suspendedUntil: _date(json['suspendedUntil']),
        suspensionReason: json['suspensionReason'] as String?,
        deletionScheduledFor: _date(json['deletionScheduledFor']),
      );

  final AccountStatus status;
  final DateTime? suspendedUntil;
  final String? suspensionReason;
  final DateTime? deletionScheduledFor;

  /// A suspension whose end date has passed no longer applies.
  bool isSuspendedAt(DateTime now) =>
      status == AccountStatus.suspended &&
      (suspendedUntil == null || suspendedUntil!.isAfter(now));

  static DateTime? _date(Object? value) =>
      value is String ? DateTime.parse(value) : null;
}

abstract interface class AccountRepository {
  Future<Result<AccountState>> get();

  Future<Result<AccountState>> requestDeletion();

  Future<Result<AccountState>> cancelDeletion();
}
