import 'package:core/core.dart';

/// What a message is about; the color follows the kind (docs/ARCHITECTURE.md §7b).
enum SupportKind {
  problem('problem', 'Sorun', 'Bir şey bozuk ya da çalışmıyor.'),
  request('request', 'Talep', 'Hesabın, grubun ya da ödemen için bir işlem iste.'),
  suggestion('suggestion', 'İstek', 'Yeni bir özellik ya da öneri paylaş.');

  const SupportKind(this.code, this.label, this.description);

  final String code;
  final String label;
  final String description;

  static SupportKind parse(Object? code) => values.firstWhere((k) => k.code == code, orElse: () => problem);
}

enum SupportStatus {
  open('open', 'Yeni'),
  inProgress('in_progress', 'İnceleniyor'),
  resolved('resolved', 'Çözüldü'),
  closed('closed', 'Kapatıldı');

  const SupportStatus(this.code, this.label);

  final String code;
  final String label;

  static SupportStatus parse(Object? code) => values.firstWhere((s) => s.code == code, orElse: () => open);
}

class SupportTicket {
  const SupportTicket({
    required this.id,
    required this.kind,
    required this.subject,
    required this.status,
    required this.createdAt,
    required this.lastMessageAt,
    required this.lastFromStaff,
    required this.userReadAt,
    this.groupName,
  });

  final String id;
  final SupportKind kind;
  final String subject;
  final SupportStatus status;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final bool lastFromStaff;
  final DateTime userReadAt;
  final String? groupName;

  /// The team answered after the user last opened the ticket.
  bool get hasUnreadReply => lastFromStaff && lastMessageAt.isAfter(userReadAt);

  bool get isClosed => status == SupportStatus.closed;
}

class SupportMessage {
  const SupportMessage({
    required this.id,
    required this.fromStaff,
    required this.body,
    required this.createdAt,
    this.attachments = const [],
  });

  final int id;
  final bool fromStaff;
  final String body;
  final DateTime createdAt;

  /// Paths in the private `support-attachments` bucket.
  final List<String> attachments;
}

/// A ticket with its conversation, oldest message first.
class SupportThread {
  const SupportThread({required this.ticket, required this.messages});

  final SupportTicket ticket;
  final List<SupportMessage> messages;
}

/// A group the user manages (owner or Yönetici) and may attach to a message.
class ManagedGroup {
  const ManagedGroup({required this.id, required this.name, required this.handle});

  final String id;
  final String name;
  final String handle;
}

class NewTicket {
  const NewTicket({
    required this.kind,
    required this.subject,
    required this.body,
    this.groupId,
    this.images = const [],
  });

  final SupportKind kind;
  final String subject;
  final String body;
  final String? groupId;
  final List<ImageUpload> images;
}

abstract final class SupportRules {
  static const subjectMin = 3;
  static const subjectMax = 120;
  static const bodyMax = 4000;
  static const maxImages = 3;
}

abstract interface class SupportRepository {
  /// The user's tickets, most recently active first.
  Future<Result<List<SupportTicket>>> myTickets();

  Future<Result<SupportThread>> thread(String ticketId);

  Future<Result<List<ManagedGroup>>> managedGroups();

  /// Uploads the images, then opens the ticket; returns its id.
  Future<Result<String>> create(NewTicket ticket);

  Future<Result<void>> reply(String ticketId, String body, {List<ImageUpload> images = const []});

  Future<Result<void>> markRead(String ticketId);

  /// A short-lived link to a private attachment.
  Future<Result<String>> attachmentUrl(String path);
}
