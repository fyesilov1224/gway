import 'package:core/core.dart';

import 'events.dart';

enum GoalKind {
  personal('personal', 'Kişisel hedef', 'Her üye kendi sayısını tamamlar.'),
  group('group', 'Grup hedefi', 'Herkesin katkısı tek sayaçta toplanır.'),
  team('team', 'Takım hedefi', 'Yönetici takımları kurar; takımın ortak sayacı olur.'),
  task('task', 'Onaylı görev', 'Üye "Yaptım" der, yönetici onaylar.');

  const GoalKind(this.code, this.label, this.description);

  final String code;
  final String label;
  final String description;

  static GoalKind parse(Object? code) => values.firstWhere((k) => k.code == code, orElse: () => personal);
}

enum GoalMetric {
  attended('attended', 'katılım'),
  organized('organized', 'düzenleme'),
  memories('memories', 'anı');

  const GoalMetric(this.code, this.unit);

  final String code;

  /// "4 katılım".
  final String unit;

  static GoalMetric? tryParse(Object? code) => values.where((m) => m.code == code).firstOrNull;
}

enum ClaimStatus {
  pending('pending', 'Onay bekliyor'),
  approved('approved', 'Onaylandı'),
  rejected('rejected', 'Onaylanmadı');

  const ClaimStatus(this.code, this.label);

  final String code;
  final String label;

  static ClaimStatus? tryParse(Object? code) => values.where((s) => s.code == code).firstOrNull;
}

/// A goal of a group with the viewer's progress (docs/ARCHITECTURE.md §3d, Hedefler ve görevler).
class Goal {
  const Goal({
    required this.id,
    required this.group,
    required this.title,
    required this.kind,
    required this.target,
    required this.startsAt,
    required this.endsAt,
    this.description = '',
    this.metric,
    this.canceledAt,
    this.progress = 0,
    this.myTeam,
    this.myClaim,
    this.completed = false,
    this.completions = 0,
    this.canManage = false,
  });

  final String id;
  final EventGroup group;
  final String title;
  final String description;
  final GoalKind kind;
  final GoalMetric? metric;

  /// 1 for a task.
  final int target;
  final DateTime startsAt;
  final DateTime endsAt;
  final DateTime? canceledAt;

  /// The viewer's own count, the group's total, their team's total, or 1 for an approved task.
  final int progress;
  final String? myTeam;
  final ClaimStatus? myClaim;

  /// The viewer has the goal badge.
  final bool completed;
  final int completions;
  final bool canManage;

  bool isRunning(DateTime now) => canceledAt == null && !startsAt.isAfter(now) && now.isBefore(endsAt);

  double get share => (progress / target).clamp(0, 1).toDouble();

  /// "3 / 4 katılım", "31 / 50 katılım".
  String get progressLabel => metric == null ? (myClaim?.label ?? 'Henüz bildirilmedi') : '${formatCount(progress)} / ${formatCount(target)} ${metric!.unit}';
}

class GoalTeam {
  const GoalTeam({required this.id, required this.name, required this.progress, this.members = const []});

  final String id;
  final String name;
  final int progress;
  final List<EventPerson> members;
}

class GoalClaim {
  const GoalClaim({required this.person, this.note = ''});

  final EventPerson person;
  final String note;
}

class GoalDetail {
  const GoalDetail({
    required this.goal,
    this.teams = const [],
    this.claims,
    this.completers = const [],
    this.candidates,
  });

  final Goal goal;
  final List<GoalTeam> teams;

  /// Pending task claims; managers only.
  final List<GoalClaim>? claims;
  final List<EventPerson> completers;

  /// Members not in a team yet; managers of a team goal only.
  final List<EventPerson>? candidates;
}

class GoalForm {
  const GoalForm({
    required this.title,
    required this.kind,
    required this.startsAt,
    required this.endsAt,
    this.description = '',
    this.metric,
    this.target,
  });

  final String title;
  final String description;
  final GoalKind kind;
  final GoalMetric? metric;
  final int? target;
  final DateTime startsAt;
  final DateTime endsAt;

  Map<String, Object?> toJson() => {
        'title': title.trim(),
        'description': description.trim(),
        'kind': kind.code,
        'metric': kind == GoalKind.task ? null : metric?.code,
        'target': kind == GoalKind.task ? null : target,
        'startsAt': startsAt.toUtc().toIso8601String(),
        'endsAt': endsAt.toUtc().toIso8601String(),
      };
}

abstract interface class GoalsRepository {
  Future<Result<List<Goal>>> groupGoals(String groupId);

  Future<Result<GoalDetail>> goal(String id);

  Future<Result<String>> create(String groupId, GoalForm form);

  Future<Result<void>> cancel(String id);

  Future<Result<void>> createTeam(String goalId, String name, List<String> memberIds);

  Future<Result<void>> deleteTeam(String goalId, String teamId);

  /// The member's own "Yaptım" (Supabase, RLS).
  Future<Result<void>> claim(String goalId, {String note = ''});

  Future<Result<void>> withdrawClaim(String goalId);

  Future<Result<void>> decideClaim(String goalId, String userId, {required bool approve});
}
