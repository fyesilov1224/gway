import 'package:core/core.dart';

import 'admin_user.dart';

/// Message kinds; the color follows the kind (docs/ARCHITECTURE.md §7b).
enum AdminSupportKind {
  problem('problem', 'Sorun', 'Sorunlar'),
  request('request', 'Talep', 'Talepler'),
  suggestion('suggestion', 'İstek', 'İstekler');

  const AdminSupportKind(this.code, this.label, this.plural);

  final String code;
  final String label;
  final String plural;

  static AdminSupportKind parse(Object? code) => values.firstWhere((k) => k.code == code, orElse: () => problem);
}

enum AdminSupportStatus {
  open('open', 'Yeni'),
  inProgress('in_progress', 'İnceleniyor'),
  resolved('resolved', 'Çözüldü'),
  closed('closed', 'Kapatıldı');

  const AdminSupportStatus(this.code, this.label);

  final String code;
  final String label;

  static AdminSupportStatus parse(Object? code) => values.firstWhere((s) => s.code == code, orElse: () => open);
}

class AdminSupportStats {
  const AdminSupportStats({
    required this.openProblems,
    required this.openRequests,
    required this.openSuggestions,
    required this.awaitingReply,
  });

  factory AdminSupportStats.fromJson(Map<String, Object?> j) => AdminSupportStats(
        openProblems: j['openProblems']! as int,
        openRequests: j['openRequests']! as int,
        openSuggestions: j['openSuggestions']! as int,
        awaitingReply: j['awaitingReply']! as int,
      );

  final int openProblems;
  final int openRequests;
  final int openSuggestions;

  /// Open or in progress, last message from the user.
  final int awaitingReply;

  int openOf(AdminSupportKind kind) => switch (kind) {
        AdminSupportKind.problem => openProblems,
        AdminSupportKind.request => openRequests,
        AdminSupportKind.suggestion => openSuggestions,
      };
}

class AdminTicket {
  const AdminTicket({
    required this.id,
    required this.kind,
    required this.subject,
    required this.status,
    required this.userId,
    required this.createdAt,
    required this.lastMessageAt,
    required this.lastFromUser,
    required this.messageCount,
    this.username,
    this.displayName,
    this.groupId,
    this.groupName,
  });

  factory AdminTicket.fromJson(Map<String, Object?> j) => AdminTicket(
        id: j['id']! as String,
        kind: AdminSupportKind.parse(j['kind']),
        subject: j['subject']! as String,
        status: AdminSupportStatus.parse(j['status']),
        userId: j['userId']! as String,
        username: j['username'] as String?,
        displayName: j['displayName'] as String?,
        groupId: j['groupId'] as String?,
        groupName: j['groupName'] as String?,
        createdAt: DateTime.parse(j['createdAt']! as String),
        lastMessageAt: DateTime.parse(j['lastMessageAt']! as String),
        lastFromUser: j['lastMessageBy'] == 'user',
        messageCount: j['messageCount']! as int,
      );

  final String id;
  final AdminSupportKind kind;
  final String subject;
  final AdminSupportStatus status;
  final String userId;
  final String? username;
  final String? displayName;
  final String? groupId;
  final String? groupName;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final bool lastFromUser;
  final int messageCount;

  /// The user wrote last and the ticket is still being handled.
  bool get awaitingReply =>
      lastFromUser && (status == AdminSupportStatus.open || status == AdminSupportStatus.inProgress);
}

class AdminTicketMessage {
  const AdminTicketMessage({
    required this.id,
    required this.fromStaff,
    required this.body,
    required this.attachments,
    required this.createdAt,
    this.authorName,
  });

  factory AdminTicketMessage.fromJson(Map<String, Object?> j) => AdminTicketMessage(
        id: j['id']! as int,
        fromStaff: j['authorKind'] == 'staff',
        authorName: j['authorName'] as String?,
        body: j['body']! as String,
        attachments: (j['attachments']! as List).cast<String>(),
        createdAt: DateTime.parse(j['createdAt']! as String),
      );

  final int id;
  final bool fromStaff;
  final String? authorName;
  final String body;

  /// Paths in the private `support-attachments` bucket.
  final List<String> attachments;
  final DateTime createdAt;
}

class AdminTicketDetail {
  const AdminTicketDetail({required this.ticket, required this.messages, this.email, this.groupHandle});

  factory AdminTicketDetail.fromJson(Map<String, Object?> j) => AdminTicketDetail(
        ticket: AdminTicket.fromJson((j['ticket']! as Map).cast()),
        email: j['email'] as String?,
        groupHandle: j['groupHandle'] as String?,
        messages: [for (final m in (j['messages']! as List).cast<Map<String, Object?>>()) AdminTicketMessage.fromJson(m)],
      );

  final AdminTicket ticket;
  final String? email;
  final String? groupHandle;
  final List<AdminTicketMessage> messages;
}

typedef TicketPage = PagedList<AdminTicket>;

abstract interface class AdminSupportRepository {
  Future<Result<AdminSupportStats>> stats();

  Future<Result<TicketPage>> search({String? query, AdminSupportKind? kind, AdminSupportStatus? status, int page = 1});

  Future<Result<AdminTicketDetail>> get(String id);

  Future<Result<void>> reply(String id, String body);

  Future<Result<void>> setStatus(String id, AdminSupportStatus status);

  /// A short-lived link to a private attachment (staff may read every attachment).
  Future<Result<String>> attachmentUrl(String path);
}
