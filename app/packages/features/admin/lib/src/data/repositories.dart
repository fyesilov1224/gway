import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/admin_analytics.dart';
import '../domain/admin_billing.dart';
import '../domain/admin_content.dart';
import '../domain/admin_events.dart';
import '../domain/admin_group.dart';
import '../domain/admin_legal.dart';
import '../domain/admin_live.dart';
import '../domain/admin_matching.dart';
import '../domain/admin_moderation.dart';
import '../domain/admin_notifications.dart';
import '../domain/admin_security.dart';
import '../domain/admin_support.dart';
import '../domain/admin_user.dart';

class SupabaseStaffRepository implements StaffRepository {
  SupabaseStaffRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<Result<StaffRole?>> myRole() async {
    final id = _client.auth.currentUser?.id;
    if (id == null) return const Err(UnauthorizedFailure());
    try {
      // RLS lets users read only their own staff row.
      final row = await _client.from('platform_staff').select('role').eq('user_id', id).maybeSingle();
      return Ok(StaffRole.tryParse(row?['role']));
    } on Object catch (e) {
      return Err(failureFromSupabase(e));
    }
  }
}

class ApiAdminUsersRepository implements AdminUsersRepository {
  ApiAdminUsersRepository(this._api);

  final ApiClient _api;

  static Map<String, Object?> _map(Object? json) => (json! as Map).cast<String, Object?>();

  @override
  Future<Result<UserPage>> search({String? query, AdminAccountStatus? status, int page = 1}) => _api.get(
        '/admin/users',
        query: {
          if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
          'status': ?status?.code,
          'page': '$page',
        },
        decode: (json) => UserPage.fromJson(_map(json), AdminUserSummary.fromJson),
      );

  @override
  Future<Result<AdminUserStats>> stats() =>
      _api.get('/admin/users/stats', decode: (json) => AdminUserStats.fromJson(_map(json)));

  @override
  Future<Result<AdminUserDetail>> get(String id) =>
      _api.get('/admin/users/$id', decode: (json) => AdminUserDetail.fromJson(_map(json)));

  @override
  Future<Result<void>> suspend(String id, {required String reason, DateTime? until}) => _api.post(
        '/admin/users/$id/suspension',
        body: {'reason': reason, 'until': until?.toUtc().toIso8601String()},
        decode: (_) {},
      );

  @override
  Future<Result<void>> unsuspend(String id) => _api.delete('/admin/users/$id/suspension', decode: (_) {});
}

class ApiAdminGroupsRepository implements AdminGroupsRepository {
  ApiAdminGroupsRepository(this._api);

  final ApiClient _api;

  static Map<String, Object?> _map(Object? json) => (json! as Map).cast<String, Object?>();

  @override
  Future<Result<GroupPage>> search({String? query, AdminGroupStatus? status, int page = 1}) => _api.get(
        '/admin/groups',
        query: {
          if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
          'status': ?status?.code,
          'page': '$page',
        },
        decode: (json) => GroupPage.fromJson(_map(json), AdminGroupSummary.fromJson),
      );

  @override
  Future<Result<AdminGroupStats>> stats() =>
      _api.get('/admin/groups/stats', decode: (json) => AdminGroupStats.fromJson(_map(json)));

  @override
  Future<Result<AdminGroupDetail>> get(String id) =>
      _api.get('/admin/groups/$id', decode: (json) => AdminGroupDetail.fromJson(_map(json)));

  @override
  Future<Result<void>> suspend(String id, {required String reason}) =>
      _api.post('/admin/groups/$id/suspension', body: {'reason': reason}, decode: (_) {});

  @override
  Future<Result<void>> unsuspend(String id) => _api.delete('/admin/groups/$id/suspension', decode: (_) {});
}

class ApiAdminBillingRepository implements AdminBillingRepository {
  ApiAdminBillingRepository(this._api);

  final ApiClient _api;

  static Map<String, Object?> _map(Object? json) => (json! as Map).cast<String, Object?>();

  @override
  Future<Result<AdminBillingStats>> stats() =>
      _api.get('/admin/billing/stats', decode: (json) => AdminBillingStats.fromJson(_map(json)));

  @override
  Future<Result<OrderPage>> orders({String? query, AdminOrderStatus? status, String? provider, int page = 1}) => _api.get(
        '/admin/billing/orders',
        query: {
          if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
          'status': ?status?.code,
          'provider': ?provider,
          'page': '$page',
        },
        decode: (json) => OrderPage.fromJson(_map(json), AdminOrder.fromJson),
      );

  @override
  Future<Result<SubscriptionPage>> subscriptions({String? query, int page = 1}) => _api.get(
        '/admin/billing/subscriptions',
        query: {
          if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
          'page': '$page',
        },
        decode: (json) => SubscriptionPage.fromJson(_map(json), AdminSubscription.fromJson),
      );

  @override
  Future<Result<List<AdminPlan>>> plans() => _api.get(
        '/admin/plans',
        decode: (json) => [for (final p in (json! as List).cast<Map<String, Object?>>()) AdminPlan.fromJson(p)],
      );

  @override
  Future<Result<void>> updatePlan(String slug, AdminPlanUpdate update) =>
      _api.put('/admin/plans/$slug', body: update.toJson(), decode: (_) {});

  @override
  Future<Result<void>> cancelSubscription(String id, {required String reason, required bool refunded}) => _api.post(
        '/admin/subscriptions/$id/cancellation',
        body: {'reason': reason, 'refunded': refunded},
        decode: (_) {},
      );

  @override
  Future<Result<void>> grantGroupPlan(String groupId, {required String slug, required int days, required String reason}) => _api.post(
        '/admin/groups/$groupId/plan',
        body: {'slug': slug, 'days': days, 'reason': reason},
        decode: (_) {},
      );

  @override
  Future<Result<void>> cancelGroupPlan(String groupId, {required String reason, required bool refunded}) => _api.post(
        '/admin/groups/$groupId/plan/cancellation',
        body: {'reason': reason, 'refunded': refunded},
        decode: (_) {},
      );

  @override
  Future<Result<List<PaymentProviderStatus>>> providers() => _api.get(
        '/admin/billing/providers',
        decode: (json) => [
          for (final p in (_map(json)['providers']! as List).cast<Map<String, Object?>>()) PaymentProviderStatus.fromJson(p),
        ],
      );

  @override
  Future<Result<ProviderCheck>> checkProvider(String provider) =>
      _api.post('/admin/billing/providers/$provider/check', decode: (json) => ProviderCheck.fromJson(_map(json)));
}

class ApiAdminContentRepository implements AdminContentRepository {
  ApiAdminContentRepository(this._api);

  final ApiClient _api;

  static Map<String, Object?> _map(Object? json) => (json! as Map).cast<String, Object?>();

  @override
  Future<Result<PostPage>> search({String? query, AdminContentFilter? filter, int page = 1}) => _api.get(
        '/admin/posts',
        query: {
          if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
          'removed': ?filter?.isRemoved.toString(),
          'page': '$page',
        },
        decode: (json) => PostPage.fromJson(_map(json), AdminPostSummary.fromJson),
      );

  @override
  Future<Result<AdminPostDetail>> get(String id) =>
      _api.get('/admin/posts/$id', decode: (json) => AdminPostDetail.fromJson(_map(json)));

  @override
  Future<Result<void>> removePost(String id, {required String reason}) =>
      _api.post('/admin/posts/$id/removal', body: {'reason': reason}, decode: (_) {});

  @override
  Future<Result<void>> restorePost(String id) => _api.delete('/admin/posts/$id/removal', decode: (_) {});

  @override
  Future<Result<void>> removeComment(String id, {required String reason}) =>
      _api.post('/admin/comments/$id/removal', body: {'reason': reason}, decode: (_) {});
}

class ApiAdminEventsRepository implements AdminEventsRepository {
  ApiAdminEventsRepository(this._api);

  final ApiClient _api;

  @override
  Future<Result<AdminEventPage>> search({String? query, AdminEventStatus? status, int page = 1}) => _api.get(
        '/admin/events',
        query: {
          if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
          'status': ?status?.code,
          'page': '$page',
        },
        decode: (json) => AdminEventPage.fromJson((json! as Map).cast(), AdminEvent.fromJson),
      );

  @override
  Future<Result<void>> cancel(String id, {required String reason}) =>
      _api.post('/admin/events/$id/cancellation', body: {'reason': reason}, decode: (_) {});

  @override
  Future<Result<void>> removeMeetingPoint(String id) => _api.delete('/admin/events/$id/meeting-point', decode: (_) {});

  @override
  Future<Result<AdminGoalPage>> goals({AdminGoalStatus? status, int page = 1}) => _api.get(
        '/admin/goals',
        query: {'status': ?status?.code, 'page': '$page'},
        decode: (json) => AdminGoalPage.fromJson((json! as Map).cast(), AdminGoal.fromJson),
      );

  @override
  Future<Result<void>> cancelGoal(String id) => _api.post('/admin/goals/$id/cancellation', decode: (_) {});
}

class ApiAdminModerationRepository implements AdminModerationRepository {
  ApiAdminModerationRepository(this._api);

  final ApiClient _api;

  @override
  Future<Result<AdminReportPage>> reports({AdminReportScope? scope, AdminReportStatus? status, int page = 1}) => _api.get(
        '/admin/reports',
        query: {'scope': ?scope?.code, 'status': ?status?.code, 'page': '$page'},
        decode: (json) => AdminReportPage.fromJson((json! as Map).cast(), AdminReport.fromJson),
      );

  @override
  Future<Result<void>> review(String reportId, {required bool actioned}) =>
      _api.post('/admin/reports/$reportId/${actioned ? 'resolution' : 'dismissal'}', decode: (_) {});

  @override
  Future<Result<AdminAppealPage>> appeals({AdminAppealStatus? status, int page = 1}) => _api.get(
        '/admin/appeals',
        query: {'status': ?status?.code, 'page': '$page'},
        decode: (json) => AdminAppealPage.fromJson((json! as Map).cast(), AdminAppeal.fromJson),
      );

  @override
  Future<Result<void>> decideAppeal(String appealId, {required bool overturn, required String note}) =>
      _api.post('/admin/appeals/$appealId/decision', body: {'overturn': overturn, 'note': note}, decode: (_) {});

  @override
  Future<Result<AdminReferralPage>> referrals({AdminReferralStatus? status, int page = 1}) => _api.get(
        '/admin/referrals',
        query: {'status': ?status?.code, 'page': '$page'},
        decode: (json) => AdminReferralPage.fromJson((json! as Map).cast(), AdminReferral.fromJson),
      );

  @override
  Future<Result<AdminReferralOutcome>> decideReferral(
    String referralId, {
    required bool ban,
    int? banDays,
    required bool lawEnforcement,
    required String note,
  }) =>
      _api.post(
        '/admin/referrals/$referralId/decision',
        body: {'ban': ban, 'banDays': banDays, 'lawEnforcement': lawEnforcement, 'note': note},
        decode: (json) => AdminReferralOutcome.fromJson((json! as Map).cast()),
      );

  @override
  Future<Result<void>> markAuthoritiesNotified(String referralId, {required String note}) =>
      _api.post('/admin/referrals/$referralId/authorities', body: {'note': note}, decode: (_) {});

  @override
  Future<Result<List<AdminContextMessage>>> messageContext(String reportId) => _api.get(
        '/admin/reports/$reportId/message-context',
        decode: (json) => [for (final m in json! as List) AdminContextMessage.fromJson((m as Map).cast())],
      );

  @override
  Future<Result<void>> removeMessage(String messageId, {required String reason}) =>
      _api.post('/admin/messages/$messageId/removal', body: {'reason': reason}, decode: (_) {});
}

class ApiAdminLiveRepository implements AdminLiveRepository {
  ApiAdminLiveRepository(this._api);

  final ApiClient _api;

  @override
  Future<Result<BroadcastPage>> search({required AdminLiveStatus status, int page = 1}) => _api.get(
        '/admin/live',
        query: {'status': status.code, 'page': '$page'},
        decode: (json) => BroadcastPage.fromJson((json! as Map).cast(), AdminBroadcast.fromJson),
      );

  @override
  Future<Result<void>> end(String id, {required String reason}) =>
      _api.post('/admin/live/$id/end', body: {'reason': reason}, decode: (_) {});
}

class ApiAdminMatchingRepository implements AdminMatchingRepository {
  ApiAdminMatchingRepository(this._api, this._client);

  final ApiClient _api;
  final SupabaseClient _client;

  @override
  Future<Result<AdminMatchingStats>> stats() =>
      _api.get('/admin/matching/stats', decode: (json) => AdminMatchingStats.fromJson((json! as Map).cast()));

  @override
  Future<Result<void>> suspend(String userId, {required String reason, DateTime? until}) => _api.post(
        '/admin/matching/profiles/$userId/suspension',
        body: {'reason': reason, 'until': until?.toUtc().toIso8601String()},
        decode: (_) {},
      );

  @override
  Future<Result<void>> removePhoto(String photoId, {required String reason}) =>
      _api.post('/admin/matching/photos/$photoId/removal', body: {'reason': reason}, decode: (_) {});

  @override
  Future<Result<void>> updateSettings(AdminMatchingSettings settings) =>
      _api.put('/admin/matching/settings', body: settings.toJson(), decode: (_) {});

  @override
  Future<Result<List<AdminPremium>>> packages() => _api.get('/admin/matching/packages',
      decode: (json) => [for (final p in (json! as List).cast<Map<String, Object?>>()) AdminPremium.fromJson(p)]);

  @override
  Future<Result<void>> updatePackage(String slug, {required String name, required bool isActive, required List<AdminPrice> prices}) =>
      _api.put(
        '/admin/matching/packages/$slug',
        body: {
          'name': name,
          'isActive': isActive,
          'prices': [for (final p in prices) {'currency': p.currency, 'period': p.period, 'amountMinor': p.amountMinor}],
        },
        decode: (_) {},
      );

  @override
  Future<Result<void>> grantPackage({required String username, required String slug, required int days, required String reason}) =>
      _api.post(
        '/admin/matching/packages/grants',
        body: {'username': username, 'slug': slug, 'days': days, 'reason': reason},
        decode: (_) {},
      );

  @override
  Future<Result<List<AdminPersonalSubscription>>> userPackages(String userId) => _api.get(
        '/admin/users/$userId/packages',
        decode: (json) => [
          for (final s in (json! as List).cast<Map<String, Object?>>()) AdminPersonalSubscription.fromJson(s),
        ],
      );

  @override
  Future<Result<void>> grantUserPackage(String userId, {required String slug, required int days, required String reason}) =>
      _api.post('/admin/users/$userId/packages', body: {'slug': slug, 'days': days, 'reason': reason}, decode: (_) {});

  @override
  Future<Result<void>> cancelUserPackage(String userId, String slug, {required String reason, required bool refunded}) => _api.post(
        '/admin/users/$userId/packages/$slug/cancellation',
        body: {'reason': reason, 'refunded': refunded},
        decode: (_) {},
      );

  @override
  Future<Result<String>> photoUrl(String path) async {
    try {
      return Ok(await _client.storage.from('match-photos').createSignedUrl(path, const Duration(minutes: 10).inSeconds));
    } on Object catch (e) {
      return Err(failureFromSupabase(e));
    }
  }
}

class ApiAdminLegalRepository implements AdminLegalRepository {
  ApiAdminLegalRepository(this._api);

  final ApiClient _api;

  @override
  Future<Result<List<LegalKind>>> list() => _api.get(
        '/admin/legal',
        decode: (json) => [for (final k in (json! as List).cast<Map<String, Object?>>()) LegalKind.fromJson(k)],
      );

  @override
  Future<Result<LegalDocument>> get(String kind, int version) =>
      _api.get('/admin/legal/$kind/$version', decode: (json) => LegalDocument.fromJson((json! as Map).cast()));

  @override
  Future<Result<void>> publish(String kind, {required String title, required String body, DateTime? publishedAt}) => _api.post(
        '/admin/legal/$kind',
        body: {'title': title, 'body': body, 'publishedAt': publishedAt?.toUtc().toIso8601String()},
        decode: (_) {},
      );

  @override
  Future<Result<void>> update(String kind, int version, {required String title, required String body, required DateTime publishedAt}) =>
      _api.put(
        '/admin/legal/$kind/$version',
        body: {'title': title, 'body': body, 'publishedAt': publishedAt.toUtc().toIso8601String()},
        decode: (_) {},
      );

  @override
  Future<Result<void>> remove(String kind, int version) => _api.delete('/admin/legal/$kind/$version', decode: (_) {});
}

class ApiAdminSecurityRepository implements AdminSecurityRepository {
  ApiAdminSecurityRepository(this._api);

  final ApiClient _api;

  static AdminSecuritySettings _settings(Object? json) => AdminSecuritySettings.fromJson((json! as Map).cast());

  @override
  Future<Result<AdminSecuritySettings>> settings() => _api.get('/admin/security/settings', decode: _settings);

  @override
  Future<Result<AdminSecuritySettings>> updateSettings({
    bool? enforce,
    bool? detectVpn,
    bool? warnInstalledVpn,
    bool? detectPhoneMismatch,
  }) =>
      _api.put(
        '/admin/security/settings',
        body: {
          'enforce': enforce,
          'detectVpn': detectVpn,
          'warnInstalledVpn': warnInstalledVpn,
          'detectPhoneMismatch': detectPhoneMismatch,
        },
        decode: _settings,
      );

  @override
  Future<Result<List<AdminSecurityReview>>> reviews(AdminReviewStatus? status, {int page = 1}) => _api.get(
        '/admin/security/reviews',
        query: {'status': ?status?.code, 'page': '$page'},
        decode: (json) => [for (final r in (json! as List).cast<Map<String, Object?>>()) AdminSecurityReview.fromJson(r)],
      );

  @override
  Future<Result<void>> approve(String reviewId, {required int exemptDays, String? note}) => _api.post(
        '/admin/security/reviews/$reviewId/approval',
        body: {'exemptDays': exemptDays, 'note': note},
        decode: (_) {},
      );

  @override
  Future<Result<void>> ban(String reviewId, {required String note}) =>
      _api.post('/admin/security/reviews/$reviewId/ban', body: {'note': note}, decode: (_) {});

  @override
  Future<Result<void>> setReviewExempt(String userId, {required bool exempt, required String note}) => _api.put(
        '/admin/users/$userId/security/review-exempt',
        body: {'exempt': exempt, 'note': note},
        decode: (_) {},
      );

  @override
  Future<Result<AdminUserSecurity>> user(String userId) =>
      _api.get('/admin/users/$userId/security', decode: (json) => AdminUserSecurity.fromJson((json! as Map).cast()));
}

class ApiAdminAnalyticsRepository implements AdminAnalyticsRepository {
  ApiAdminAnalyticsRepository(this._api);

  final ApiClient _api;

  @override
  Future<Result<AdminOverview>> overview(int days) => _api.get(
        '/admin/analytics/overview',
        query: {'days': '$days'},
        decode: (json) => AdminOverview.fromJson((json! as Map).cast()),
      );
}

class ApiAdminNotificationsRepository implements AdminNotificationsRepository {
  ApiAdminNotificationsRepository(this._api);

  final ApiClient _api;

  @override
  Future<Result<AdminPushStats>> stats() =>
      _api.get('/admin/notifications/stats', decode: (json) => AdminPushStats.fromJson((json! as Map).cast()));
}

class ApiAdminSupportRepository implements AdminSupportRepository {
  ApiAdminSupportRepository(this._api, this._client);

  final ApiClient _api;
  final SupabaseClient _client;

  static Map<String, Object?> _map(Object? json) => (json! as Map).cast<String, Object?>();

  @override
  Future<Result<AdminSupportStats>> stats() =>
      _api.get('/admin/support/stats', decode: (json) => AdminSupportStats.fromJson(_map(json)));

  @override
  Future<Result<TicketPage>> search({String? query, AdminSupportKind? kind, AdminSupportStatus? status, int page = 1}) => _api.get(
        '/admin/support/tickets',
        query: {
          if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
          'kind': ?kind?.code,
          'status': ?status?.code,
          'page': '$page',
        },
        decode: (json) => TicketPage.fromJson(_map(json), AdminTicket.fromJson),
      );

  @override
  Future<Result<AdminTicketDetail>> get(String id) =>
      _api.get('/admin/support/tickets/$id', decode: (json) => AdminTicketDetail.fromJson(_map(json)));

  @override
  Future<Result<void>> reply(String id, String body) =>
      _api.post('/admin/support/tickets/$id/messages', body: {'body': body}, decode: (_) {});

  @override
  Future<Result<void>> setStatus(String id, AdminSupportStatus status) =>
      _api.put('/admin/support/tickets/$id/status', body: {'status': status.code}, decode: (_) {});

  @override
  Future<Result<String>> attachmentUrl(String path) async {
    try {
      return Ok(await _client.storage.from('support-attachments').createSignedUrl(path, const Duration(minutes: 30).inSeconds));
    } on Object catch (e) {
      return Err(failureFromSupabase(e));
    }
  }
}
