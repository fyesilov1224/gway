import 'package:core/core.dart';

/// Push health (docs/ARCHITECTURE.md §3c, Admin). Counts only; no contents or tokens.
class AdminPushStats {
  const AdminPushStats({
    required this.configured,
    required this.androidDevices,
    required this.iosDevices,
    required this.webDevices,
    required this.usersWithDevice,
    required this.created24h,
    required this.delivered24h,
    required this.deliveries24h,
    required this.waiting,
    required this.byType24h,
  });

  factory AdminPushStats.fromJson(Map<String, Object?> j) => AdminPushStats(
        configured: j['configured']! as bool,
        androidDevices: j['androidDevices']! as int,
        iosDevices: j['iosDevices']! as int,
        webDevices: j['webDevices']! as int,
        usersWithDevice: j['usersWithDevice']! as int,
        created24h: j['created24h']! as int,
        delivered24h: j['delivered24h']! as int,
        deliveries24h: j['deliveries24h']! as int,
        waiting: j['waiting']! as int,
        byType24h: [
          for (final t in (j['byType24h']! as List).cast<Map<String, Object?>>()) (type: t['type']! as String, count: t['count']! as int),
        ],
      );

  /// The server has the Firebase key; without it notifications stay in the app.
  final bool configured;
  final int androidDevices;
  final int iosDevices;
  final int webDevices;
  final int usersWithDevice;

  /// Notifications created in the last 24 hours.
  final int created24h;

  /// Of those, the ones that reached at least one phone.
  final int delivered24h;

  /// Phones reached in total.
  final int deliveries24h;

  /// Waiting for the backend to push them; stays near zero while push works.
  final int waiting;

  /// Most frequent first.
  final List<({String type, int count})> byType24h;

  int get devices => androidDevices + iosDevices + webDevices;
}

/// What a notification type is about, in the panel's words.
String notificationTypeLabel(String type) => switch (type) {
      'like' => 'Gönderi beğenisi',
      'comment' => 'Yorum',
      'reply' => 'Yorum yanıtı',
      'comment_like' => 'Yorum beğenisi',
      'mention' => 'Bahsetme',
      'follow' => 'Takip',
      'follow_request' => 'Takip isteği',
      'follow_accepted' => 'Takip isteği kabulü',
      'live_scheduled' => 'Canlı yayın planlandı',
      'live_started' => 'Canlı yayın başladı',
      'event_promoted' => 'Bekleme listesinden yükselme',
      'event_updated' => 'Organizasyon değişikliği',
      'event_canceled' => 'Organizasyon iptali',
      'event_reminder' => 'Organizasyon hatırlatması',
      'case_vote' => 'Disiplin oylaması',
      'sanction_applied' => 'Yaptırım',
      'appeal_submitted' => 'İtiraz',
      'appeal_decided' => 'İtiraz kararı',
      'event_approved' => 'Katılım onayı',
      'event_declined' => 'Katılım reddi',
      'event_review' => 'Değerlendirme isteği',
      'goal_completed' => 'Hedef tamamlandı',
      'teammate_request' => 'Ekip arkadaşlığı isteği',
      'teammate_accepted' => 'Ekip arkadaşlığı kabulü',
      'event_series_limit' => 'Tekrar limiti',
      'event_venue_revealed' => 'Sürpriz mekan',
      _ => type,
    };

abstract interface class AdminNotificationsRepository {
  Future<Result<AdminPushStats>> stats();
}
