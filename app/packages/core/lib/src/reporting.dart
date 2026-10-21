import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Something a user can report (docs/ARCHITECTURE.md §3e).
class ReportTarget {
  const ReportTarget.post(this.id) : type = 'post', groupId = null;

  const ReportTarget.comment(this.id) : type = 'comment', groupId = null;

  const ReportTarget.event(this.id) : type = 'event', groupId = null;

  const ReportTarget.liveComment(int commentId) : id = '$commentId', type = 'live_comment', groupId = null;

  /// A person; reported from a group's member list it goes to that group's moderation.
  const ReportTarget.user(this.id, {this.groupId}) : type = 'user';

  final String type;
  final String id;
  final String? groupId;
}

/// Opens the report sheet. Features call it; the app provides the moderation feature's sheet.
typedef ReportLauncher = Future<void> Function(BuildContext context, ReportTarget target);

final reportLauncherProvider = Provider<ReportLauncher>(
  (ref) => throw UnimplementedError('reportLauncherProvider must be overridden'),
);
