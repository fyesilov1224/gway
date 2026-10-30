import 'package:core/core.dart';

/// A table is the chat of tonight's small table (docs/ARCHITECTURE.md §3d, Bu akşam boşum ve küçük masa).
enum ConversationKind { direct, group, table }

/// A person's side of a direct conversation (docs/ARCHITECTURE.md §3f).
enum MemberState {
  active,

  /// Waiting in the recipient's "Mesaj istekleri".
  request,
  declined;

  static MemberState parse(Object? value) => values.where((s) => s.name == value).firstOrNull ?? active;
}

class ChatPeer {
  const ChatPeer({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.state = MemberState.active,
    this.readAt,
  });

  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final MemberState state;

  /// Shown as "Görüldü"; null while they have not accepted the request.
  final DateTime? readAt;
}

class ChatGroup {
  const ChatGroup({required this.id, required this.handle, required this.name, this.logoUrl});

  final String id;
  final String handle;
  final String name;
  final String? logoUrl;
}

class LastMessage {
  const LastMessage({required this.senderId, required this.body, required this.createdAt, this.hasImage = false, this.deleted = false});

  final String senderId;
  final String body;
  final DateTime createdAt;
  final bool hasImage;
  final bool deleted;

  String get preview => deleted
      ? 'Mesaj silindi'
      : body.isNotEmpty
          ? body
          : 'Fotoğraf';
}

class Conversation {
  const Conversation({
    required this.id,
    required this.kind,
    this.myState = MemberState.active,
    this.peer,
    this.group,
    this.lastMessage,
    this.unread = 0,
    this.adminsOnly = false,
    this.blocker,
    this.canManage = false,
    this.tableMembers = 0,
  });

  final String id;
  final ConversationKind kind;
  final MemberState myState;
  final ChatPeer? peer;
  final ChatGroup? group;
  final LastMessage? lastMessage;
  final int unread;

  /// Group chat: only the owner and Yöneticiler write.
  final bool adminsOnly;

  /// Why the user cannot write now (a database rule code), or null.
  final String? blocker;

  /// May switch the group chat to admins-only.
  final bool canManage;

  /// People at a small table.
  final int tableMembers;

  bool get isRequest => myState == MemberState.request;
  String get title => kind == ConversationKind.table ? 'Bu akşamın masası' : group?.name ?? peer?.displayName ?? '';
  String? get avatarUrl => group?.logoUrl ?? peer?.avatarUrl;

  /// What the composer shows instead of the text field, in Turkish.
  String? get blockerText => switch (blocker) {
        null => null,
        'message_request_pending' => 'Yanıt vermek için önce mesaj isteğini kabul et.',
        'message_declined' => 'Bu kişi mesaj isteğini kabul etmedi.',
        'message_muted' => 'Bu grupta susturulduğun için şu anda yazamazsın.',
        'message_admins_only' => 'Bu sohbette yalnızca yöneticiler yazabilir.',
        'table_closed' => 'Masa kapandı; mesajları okuyabilirsin ama yeni mesaj yazılamaz.',
        'blocked' => 'Engel olduğu için bu sohbete yazılamıyor.',
        'match_ended' => 'Eşleşme bittiği için bu sohbet kapandı.',
        'match_chat_locked' => 'Eşleştiğin kişiye yazmak için Eşleşme Sohbeti paketi gerekir. Mesajları okumak ücretsiz.',
        'teammate_chat_locked' => 'Ekip arkadaşına yazmak için Ekip Arkadaşı paketi gerekir. Mesajları okumak ücretsiz.',
        'message_not_allowed' => 'Özel mesaj artık yalnızca eşleşenler ve ekip arkadaşları içindir. Eski mesajlarını okuyabilirsin.',
        _ => 'Bu sohbete şu anda yazamazsın.',
      };
}

class MessageSender {
  const MessageSender({required this.id, required this.username, required this.displayName, this.avatarUrl});

  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.sender,
    required this.createdAt,
    this.body = '',
    this.imagePath,
    this.imageUrl,
    this.deletedAt,
    this.removed = false,
  });

  final String id;
  final MessageSender sender;
  final DateTime createdAt;
  final String body;
  final String? imagePath;

  /// A signed address of the private photo.
  final String? imageUrl;
  final DateTime? deletedAt;

  /// Taken down by a moderator rather than deleted by the sender.
  final bool removed;

  bool get isDeleted => deletedAt != null;
}

/// Opening a direct conversation: the id, and whether it went to the other person's requests.
typedef DirectChat = ({String id, bool isRequest});

/// Reads through Supabase (RLS, Realtime); writes through the C# API (docs/ARCHITECTURE.md §3f).
abstract interface class MessagingRepository {
  Future<Result<List<Conversation>>> conversations();

  Future<Result<Conversation?>> conversation(String id);

  /// The newest [limit] messages, oldest first.
  Future<Result<List<ChatMessage>>> messages(String conversationId, {int limit = 100});

  /// Fires when a message in the user's conversations arrives or changes (all of them without [conversationId]).
  Stream<void> changes({String? conversationId});

  Future<Result<DirectChat>> openDirect(String userId);

  /// Whether the profile offers a chat with [userId]: a match, a teammate, or an earlier conversation (docs/ARCHITECTURE.md §3f).
  Future<Result<bool>> canMessage(String userId);

  Future<Result<String?>> groupConversation(String groupId);

  Future<Result<void>> send(String conversationId, {String body = '', ImageUpload? image});

  Future<Result<void>> answerRequest(String conversationId, {required bool accept});

  Future<Result<void>> delete(String messageId);

  Future<Result<void>> markRead(String conversationId);

  Future<Result<void>> setAdminsOnly(String groupId, {required bool adminsOnly});
}

/// A conversation with its newest messages, as the chat screen shows it.
class ChatThread {
  const ChatThread({required this.conversation, required this.messages});

  final Conversation conversation;

  /// Oldest first.
  final List<ChatMessage> messages;
}

abstract final class MessagingRules {
  static const bodyMax = 2000;
}
