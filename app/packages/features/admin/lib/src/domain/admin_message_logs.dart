import 'package:core/core.dart';

/// Conversation kinds of the message logs (docs/ARCHITECTURE.md §3f, Mesaj kayıtları).
enum LogConversationKind {
  direct('direct', 'Birebir'),
  group('group', 'Grup sohbeti'),
  table('table', 'Küçük masa');

  const LogConversationKind(this.code, this.label);

  final String code;
  final String label;

  static LogConversationKind parse(Object? code) => values.firstWhere((k) => k.code == code, orElse: () => direct);
}

DateTime? _date(Object? v) => v == null ? null : DateTime.parse(v as String);

class LogPerson {
  const LogPerson({required this.id, required this.username, required this.displayName, this.avatarPath});

  static LogPerson? tryFromJson(Object? json) {
    if (json == null) return null;
    final j = (json as Map).cast<String, Object?>();
    return LogPerson(
      id: j['id']! as String,
      username: j['username']! as String,
      displayName: j['displayName']! as String,
      avatarPath: j['avatarPath'] as String?,
    );
  }

  final String id;
  final String username;
  final String displayName;
  final String? avatarPath;

  String get label => '$displayName (@$username)';
}

class LogGroup {
  const LogGroup({required this.id, required this.handle, required this.name, this.logoPath});

  static LogGroup? tryFromJson(Object? json) {
    if (json == null) return null;
    final j = (json as Map).cast<String, Object?>();
    return LogGroup(id: j['id']! as String, handle: j['handle']! as String, name: j['name']! as String, logoPath: j['logoPath'] as String?);
  }

  final String id;
  final String handle;
  final String name;
  final String? logoPath;
}

/// One conversation of the searched person.
class LogConversation {
  const LogConversation({
    required this.id,
    required this.kind,
    required this.createdAt,
    required this.lastMessageAt,
    required this.messageCount,
    required this.targetMessageCount,
    required this.deletedCount,
    this.peer,
    this.group,
    this.tableEvening,
  });

  factory LogConversation.fromJson(Map<String, Object?> j) => LogConversation(
        id: j['id']! as String,
        kind: LogConversationKind.parse(j['kind']),
        createdAt: DateTime.parse(j['createdAt']! as String),
        lastMessageAt: _date(j['lastMessageAt']),
        messageCount: j['messageCount']! as int,
        targetMessageCount: j['targetMessageCount']! as int,
        deletedCount: j['deletedCount']! as int,
        peer: LogPerson.tryFromJson(j['peer']),
        group: LogGroup.tryFromJson(j['group']),
        tableEvening: _date(j['tableEvening']),
      );

  final String id;
  final LogConversationKind kind;
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  final int messageCount;

  /// Messages the searched person wrote here.
  final int targetMessageCount;
  final int deletedCount;
  final LogPerson? peer;
  final LogGroup? group;
  final DateTime? tableEvening;

  String get title => switch (kind) {
        LogConversationKind.direct => peer?.label ?? 'Silinmiş hesap',
        LogConversationKind.group => group == null ? 'Grup' : '${group!.name} (@${group!.handle})',
        LogConversationKind.table => tableEvening == null ? 'Küçük masa' : 'Küçük masa · ${formatDateTr(tableEvening!)}',
      };
}

class LogConversationPage {
  const LogConversationPage({
    required this.user,
    required this.withUser,
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  factory LogConversationPage.fromJson(Map<String, Object?> j) => LogConversationPage(
        user: LogPerson.tryFromJson(j['user'])!,
        withUser: LogPerson.tryFromJson(j['withUser']),
        items: [for (final c in (j['items']! as List).cast<Map<String, Object?>>()) LogConversation.fromJson(c)],
        page: j['page']! as int,
        pageSize: j['pageSize']! as int,
        total: j['total']! as int,
      );

  final LogPerson user;
  final LogPerson? withUser;
  final List<LogConversation> items;
  final int page;
  final int pageSize;
  final int total;

  int get pageCount => total == 0 ? 1 : (total / pageSize).ceil();
  (int, int) get range => total == 0 ? (0, 0) : ((page - 1) * pageSize + 1, (page - 1) * pageSize + items.length);
}

class LogMessage {
  const LogMessage({
    required this.id,
    required this.sender,
    required this.body,
    required this.imageUrl,
    required this.hadImage,
    required this.archived,
    required this.createdAt,
    required this.deletedAt,
    required this.removedReason,
    required this.purgeAfter,
  });

  factory LogMessage.fromJson(Map<String, Object?> j) => LogMessage(
        id: j['id']! as String,
        sender: LogPerson.tryFromJson(j['sender']),
        body: j['body']! as String,
        imageUrl: j['imageUrl'] as String?,
        hadImage: j['hadImage']! as bool,
        archived: j['archived']! as bool,
        createdAt: DateTime.parse(j['createdAt']! as String),
        deletedAt: _date(j['deletedAt']),
        removedReason: j['removedReason'] as String?,
        purgeAfter: _date(j['purgeAfter']),
      );

  final String id;
  final LogPerson? sender;

  /// For a deleted message the archived text; empty when the archive no longer holds it.
  final String body;
  final String? imageUrl;
  final bool hadImage;
  final bool archived;
  final DateTime createdAt;
  final DateTime? deletedAt;

  /// Set when moderation removed the message.
  final String? removedReason;

  /// When the archived text is deleted for good.
  final DateTime? purgeAfter;

  bool get isDeleted => deletedAt != null;
}

class LogConversationView {
  const LogConversationView({required this.conversation, required this.participants, required this.messages, required this.hasOlder});

  factory LogConversationView.fromJson(Map<String, Object?> j) {
    final c = (j['conversation']! as Map).cast<String, Object?>();
    return LogConversationView(
      conversation: LogConversation(
        id: c['id']! as String,
        kind: LogConversationKind.parse(c['kind']),
        createdAt: DateTime.parse(c['createdAt']! as String),
        lastMessageAt: _date(c['lastMessageAt']),
        messageCount: c['messageCount']! as int,
        targetMessageCount: 0,
        deletedCount: 0,
        group: LogGroup.tryFromJson(c['group']),
        tableEvening: _date(c['tableEvening']),
      ),
      participants: [for (final p in (c['participants']! as List)) ?LogPerson.tryFromJson(p)],
      messages: [for (final m in (j['messages']! as List).cast<Map<String, Object?>>()) LogMessage.fromJson(m)],
      hasOlder: j['hasOlder']! as bool,
    );
  }

  final LogConversation conversation;
  final List<LogPerson> participants;

  /// Oldest first.
  final List<LogMessage> messages;
  final bool hasOlder;

  String get title => switch (conversation.kind) {
        LogConversationKind.direct => participants.map((p) => '@${p.username}').join(' ↔ '),
        _ => conversation.title,
      };
}

abstract interface class AdminMessageLogsRepository {
  Future<Result<LogConversationPage>> search({
    required String username,
    String? withUsername,
    LogConversationKind? kind,
    int page = 1,
    required String reason,
  });

  /// [before] pages back: the oldest loaded message's time.
  Future<Result<LogConversationView>> view(String conversationId, {required String reason, DateTime? before, String? query});
}
