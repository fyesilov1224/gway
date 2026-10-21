import 'dart:math';

import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/support.dart';

/// The user's own tickets, written straight to Supabase under RLS (docs/ARCHITECTURE.md §7b).
class SupportRepositoryImpl implements SupportRepository {
  SupportRepositoryImpl(this._client);

  final SupabaseClient _client;

  static const _bucket = 'support-attachments';

  /// Trigger codes users can run into, as Turkish messages.
  static const _rules = {
    'ticket_rate_limited': 'Bugün çok fazla mesaj açtın. Yarın tekrar deneyebilir ya da açık mesajlarına yazabilirsin.',
    'reply_rate_limited': 'Kısa sürede çok fazla yanıt yazdın. Biraz bekleyip tekrar dene.',
    'ticket_closed': 'Bu mesaj kapatıldı. Devam etmek için yeni bir mesaj aç.',
  };

  Future<Result<T>> _run<T>(Future<T> Function() action) async {
    try {
      return Ok(await action());
    } on Failure catch (f) {
      return Err(f);
    } on PostgrestException catch (e) {
      final message = _rules[e.message];
      return Err(e.code == 'P0001' && message != null ? RuleFailure('support.${e.message}', message) : failureFromSupabase(e));
    } on Object catch (e) {
      return Err(failureFromSupabase(e));
    }
  }

  static SupportTicket _ticket(Map<String, dynamic> r) => SupportTicket(
        id: r['id'] as String,
        kind: SupportKind.parse(r['kind']),
        subject: r['subject'] as String,
        status: SupportStatus.parse(r['status']),
        createdAt: DateTime.parse(r['created_at'] as String),
        lastMessageAt: DateTime.parse(r['last_message_at'] as String),
        lastFromStaff: r['last_message_by'] == 'staff',
        userReadAt: DateTime.parse(r['user_read_at'] as String),
        groupName: (r['groups'] as Map?)?['name'] as String?,
      );

  static const _ticketColumns = 'id, kind, subject, status, created_at, last_message_at, last_message_by, user_read_at, groups(name)';

  String get _userId => _client.auth.currentUser?.id ?? (throw const UnauthorizedFailure());

  @override
  Future<Result<List<SupportTicket>>> myTickets() => _run(() async {
        final rows = await _client
            .from('support_tickets')
            .select(_ticketColumns)
            .eq('user_id', _userId)
            .order('last_message_at', ascending: false);
        return [for (final r in rows) _ticket(r)];
      });

  @override
  Future<Result<SupportThread>> thread(String ticketId) => _run(() async {
        final ticket = await _client.from('support_tickets').select(_ticketColumns).eq('id', ticketId).single();
        final rows = await _client
            .from('support_messages')
            .select('id, author_kind, body, attachments, created_at')
            .eq('ticket_id', ticketId)
            .order('created_at', ascending: true);
        return SupportThread(
          ticket: _ticket(ticket),
          messages: [
            for (final r in rows)
              SupportMessage(
                id: r['id'] as int,
                fromStaff: r['author_kind'] == 'staff',
                body: r['body'] as String,
                attachments: (r['attachments'] as List).cast<String>(),
                createdAt: DateTime.parse(r['created_at'] as String),
              ),
          ],
        );
      });

  @override
  Future<Result<List<ManagedGroup>>> managedGroups() => _run(() async {
        final rows = await _client.rpc<List<dynamic>>('my_managed_groups');
        return [
          for (final r in rows.cast<Map<String, dynamic>>())
            ManagedGroup(id: r['id'] as String, name: r['name'] as String, handle: r['handle'] as String),
        ];
      });

  @override
  Future<Result<String>> create(NewTicket ticket) async {
    final id = _uuid();
    final List<String> attachments;
    switch (await _upload(id, ticket.images)) {
      case Ok(:final value):
        attachments = value;
      case Err(:final failure):
        return Err(failure);
    }
    return _run(() async {
      await _client.rpc<dynamic>('create_support_ticket', params: {
        'ticket_id': id,
        'kind': ticket.kind.code,
        'subject': ticket.subject,
        'body': ticket.body,
        'target_group': ticket.groupId,
        'attachments': attachments,
      });
      return id;
    });
  }

  @override
  Future<Result<void>> reply(String ticketId, String body, {List<ImageUpload> images = const []}) async {
    final List<String> attachments;
    switch (await _upload(ticketId, images)) {
      case Ok(:final value):
        attachments = value;
      case Err(:final failure):
        return Err(failure);
    }
    return _run(() => _client.from('support_messages').insert({'ticket_id': ticketId, 'body': body, 'attachments': attachments}));
  }

  @override
  Future<Result<void>> markRead(String ticketId) => _run(() => _client
      .from('support_tickets')
      .update({'user_read_at': DateTime.now().toUtc().toIso8601String()})
      .eq('id', ticketId));

  @override
  Future<Result<String>> attachmentUrl(String path) =>
      _run(() => _client.storage.from(_bucket).createSignedUrl(path, const Duration(minutes: 30).inSeconds));

  /// `<uid>/<ticket>-<n>.<ext>`, the only layout the database accepts. A time-based n keeps names unique.
  Future<Result<List<String>>> _upload(String ticketId, List<ImageUpload> images) async {
    if (images.any((i) => i.contentType == null)) {
      return const Err(RuleFailure('storage.unsupported_type', 'Bu dosya türü desteklenmiyor. JPEG, PNG veya WebP seç.'));
    }
    final stamp = DateTime.now().millisecondsSinceEpoch;
    return _run(() async {
      final paths = <String>[];
      for (final (i, image) in images.indexed) {
        final path = '$_userId/$ticketId-${stamp + i}.${image.extension}';
        await _client.storage.from(_bucket).uploadBinary(path, image.bytes, fileOptions: FileOptions(contentType: image.contentType));
        paths.add(path);
      }
      return paths;
    });
  }

  /// Random (v4) uuid, chosen here so screenshots can be uploaded before the ticket exists.
  static String _uuid() {
    final random = Random.secure();
    final b = [for (var i = 0; i < 16; i++) random.nextInt(256)];
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    final hex = [for (final x in b) x.toRadixString(16).padLeft(2, '0')].join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
