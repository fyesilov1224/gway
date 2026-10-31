import 'package:admin/admin.dart';
import 'package:admin/src/presentation/group_plan_panel.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _users = [
  AdminUserSummary(
    id: 'u1',
    email: 'ayse@gway.app',
    username: 'ayse.k',
    displayName: 'Ayşe Kaya',
    status: AdminAccountStatus.active,
    createdAt: DateTime(2026, 10, 1),
  ),
  AdminUserSummary(
    id: 'u2',
    email: 'can@gway.app',
    username: 'can_dag',
    displayName: 'Can Dağ',
    status: AdminAccountStatus.suspended,
    suspendedUntil: DateTime(2026, 10, 25),
    createdAt: DateTime(2026, 9, 20),
  ),
  const AdminUserSummary(id: 'u3', email: 'yeni@gway.app', status: AdminAccountStatus.active, staffRole: StaffRole.support),
];

final _groups = [
  AdminGroupSummary(
    id: 'g1',
    handle: 'istanbul.kosu',
    name: 'İstanbul Koşu Kulübü',
    categorySlug: 'running',
    joinPolicy: 'open',
    status: AdminGroupStatus.active,
    memberCount: 42,
    ownerId: 'u1',
    ownerUsername: 'ayse.k',
    createdAt: DateTime(2026, 10, 1),
  ),
  AdminGroupSummary(
    id: 'g2',
    handle: 'pedal',
    name: 'Pedal Kadıköy',
    categorySlug: 'cycling',
    joinPolicy: 'request',
    status: AdminGroupStatus.suspended,
    memberCount: 7,
    ownerId: 'u2',
    createdAt: DateTime(2026, 10, 5),
  ),
];

final _subscription = AdminSubscription(
  id: 's1',
  groupId: 'g2',
  groupName: 'Pedal Kadıköy',
  groupHandle: 'pedal',
  planName: 'Başlangıç',
  period: 'month',
  startsAt: DateTime.now().subtract(const Duration(days: 10)),
  endsAt: DateTime.now().add(const Duration(days: 20)),
  orderId: 'o1',
  orderStatus: AdminOrderStatus.paid,
  provider: 'paytr',
  currency: 'TRY',
  amountMinor: 24900,
);

final _groupDetail = AdminGroupDetail(
  group: _groups[1],
  plan: const AdminGroupPlan(slug: 'starter', name: 'Başlangıç', maxMembers: 250),
  subscriptions: [_subscription],
  about: 'Hafta sonu sürüşleri.',
  suspensionReason: 'Dolandırıcılık şikayetleri',
  suspendedAt: DateTime(2026, 10, 18),
  pendingRequests: 2,
  pendingInvitations: 0,
  team: const [
    AdminGroupTeamMember(userId: 'u2', username: 'can_dag', displayName: 'Can Dağ', roles: ['owner']),
    AdminGroupTeamMember(userId: 'u1', username: 'ayse.k', displayName: 'Ayşe Kaya', roles: ['admin', 'moderator']),
  ],
  history: [
    AdminAuditItem(
      occurredAt: DateTime(2026, 10, 18),
      action: 'group.suspended',
      actorKind: 'staff',
      actorName: 'GWAY Ekibi',
      detail: 'Dolandırıcılık şikayetleri',
    ),
    AdminAuditItem(
      occurredAt: DateTime(2026, 10, 6),
      action: 'group.role_assigned',
      actorKind: 'user',
      actorName: 'Can Dağ',
      targetName: 'Ayşe Kaya',
      detail: 'admin',
    ),
  ],
);

final _detail = AdminUserDetail(
  user: _users[1],
  bio: 'Dağcı.',
  suspensionReason: 'Spam paylaşımları',
  consents: [AdminConsent(kind: 'terms', version: 1, acceptedAt: DateTime(2026, 9, 20))],
  history: [
    AdminAuditItem(occurredAt: DateTime(2026, 10, 18), action: 'user.suspended', actorKind: 'staff', actorName: 'GWAY Ekibi'),
    AdminAuditItem(occurredAt: DateTime(2026, 10, 1), action: 'account.deletion_cancelled', actorKind: 'user'),
  ],
);

final _orders = [
  AdminOrder(
    id: 'o1',
    groupId: 'g2',
    groupName: 'Pedal Kadıköy',
    groupHandle: 'pedal',
    buyerId: 'u2',
    buyerUsername: 'can_dag',
    planName: 'Başlangıç',
    period: 'month',
    provider: 'paytr',
    country: 'TR',
    currency: 'TRY',
    amountMinor: 24900,
    status: AdminOrderStatus.paid,
    createdAt: DateTime(2026, 10, 9),
    paidAt: DateTime(2026, 10, 9),
  ),
  AdminOrder(
    id: 'o2',
    groupName: 'Silinmiş Grup',
    groupHandle: 'eski',
    buyerId: 'u9',
    planName: 'Pro',
    period: 'year',
    provider: 'iyzico',
    country: 'DE',
    currency: 'USD',
    amountMinor: 24990,
    status: AdminOrderStatus.pending,
    createdAt: DateTime(2026, 10, 1),
  ),
];

final _stats = AdminBillingStats(
  activeSubscriptions: 3,
  paidGroups: 3,
  revenueThisMonth: const [AdminMoney(currency: 'TRY', amountMinor: 94800), AdminMoney(currency: 'USD', amountMinor: 24990)],
  pendingOrders: 1,
  months: [
    for (var i = 0; i < 12; i++)
      AdminRevenueMonth(
        month: DateTime(2026, 10 - i),
        revenue: i == 0 ? const [AdminMoney(currency: 'TRY', amountMinor: 94800)] : const [],
        paidOrders: i == 0 ? 2 : 0,
      ),
  ],
);

const _plans = [
  AdminPlan(
    slug: 'free',
    name: 'Ücretsiz',
    tier: 0,
    maxMembers: 50,
    monthlyEvents: 2,
    monthlyLiveMinutes: 60,
    isActive: true,
    activeGroups: 0,
    prices: [],
  ),
  AdminPlan(
    slug: 'starter',
    name: 'Başlangıç',
    tier: 1,
    maxMembers: 250,
    monthlyEvents: 10,
    monthlyLiveMinutes: 600,
    isActive: true,
    activeGroups: 2,
    prices: [
      AdminPlanPrice(currency: 'TRY', period: 'month', amountMinor: 24900),
      AdminPlanPrice(currency: 'TRY', period: 'year', amountMinor: 249000),
      AdminPlanPrice(currency: 'USD', period: 'month', amountMinor: 999),
      AdminPlanPrice(currency: 'USD', period: 'year', amountMinor: 9990),
    ],
  ),
];

/// Records plan edits; everything else is read through provider overrides.
class _FakeBilling implements AdminBillingRepository {
  final updates = <(String, AdminPlanUpdate)>[];
  final grants = <(String, String, int, String)>[];
  final groupCancels = <(String, String, bool)>[];
  final checks = <String>[];

  @override
  Future<Result<ProviderCheck>> checkProvider(String provider) async {
    checks.add(provider);
    return provider == 'paytr'
        ? const Ok(ProviderCheck(connected: true, message: 'Bağlantı başarılı; anahtarlar sağlayıcı tarafından kabul edildi.'))
        : const Ok(ProviderCheck(connected: false, message: 'iyzico reddetti: 1001 api bilgileri bulunamadı'));
  }

  @override
  Future<Result<void>> grantGroupPlan(String groupId, {required String slug, required int days, required String reason}) async {
    grants.add((groupId, slug, days, reason));
    return const Ok(null);
  }

  @override
  Future<Result<void>> cancelGroupPlan(String groupId, {required String reason, required bool refunded}) async {
    groupCancels.add((groupId, reason, refunded));
    return const Ok(null);
  }

  @override
  Future<Result<void>> updatePlan(String slug, AdminPlanUpdate update) async {
    updates.add((slug, update));
    return const Ok(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _billing = _FakeBilling();

const _paymentProviders = [
  PaymentProviderStatus(
    provider: 'paytr',
    market: 'TR · TL',
    configured: true,
    testMode: true,
    addresses: [ProviderAddress(label: 'Bildirim URL (PayTR paneli)', url: 'https://api.gway.app/billing/paytr/notify')],
    warnings: ['Test modu açık: kartlardan para çekilmez.'],
  ),
  PaymentProviderStatus(
    provider: 'iyzico',
    market: 'Yurt dışı · USD',
    configured: true,
    testMode: true,
    addresses: [ProviderAddress(label: 'Webhook adresi (iyzico paneli)', url: 'https://api.gway.app/billing/iyzico/webhook')],
  ),
];

final _ticket = AdminTicket(
  id: 't1',
  kind: AdminSupportKind.request,
  subject: 'Grup adresini değiştirmek istiyorum',
  status: AdminSupportStatus.open,
  userId: 'u2',
  username: 'can_dag',
  displayName: 'Can Dağ',
  groupId: 'g2',
  groupName: 'Pedal Kadıköy',
  createdAt: DateTime(2026, 10, 18),
  lastMessageAt: DateTime(2026, 10, 19),
  lastFromUser: true,
  messageCount: 1,
);

final _tickets = [
  _ticket,
  AdminTicket(
    id: 't2',
    kind: AdminSupportKind.problem,
    subject: 'Kapak fotoğrafı yüklenmiyor',
    status: AdminSupportStatus.inProgress,
    userId: 'u1',
    username: 'ayse.k',
    createdAt: DateTime(2026, 10, 17),
    lastMessageAt: DateTime(2026, 10, 18),
    lastFromUser: false,
    messageCount: 2,
  ),
  AdminTicket(
    id: 't3',
    kind: AdminSupportKind.suggestion,
    subject: 'Takvim görünümü',
    status: AdminSupportStatus.resolved,
    userId: 'u1',
    username: 'ayse.k',
    createdAt: DateTime(2026, 10, 10),
    lastMessageAt: DateTime(2026, 10, 12),
    lastFromUser: false,
    messageCount: 3,
  ),
];

/// Records support replies and status changes.
class _FakeSupport implements AdminSupportRepository {
  final replies = <(String, String)>[];
  final statuses = <(String, AdminSupportStatus)>[];

  @override
  Future<Result<void>> reply(String id, String body) async {
    replies.add((id, body));
    return const Ok(null);
  }

  @override
  Future<Result<void>> setStatus(String id, AdminSupportStatus status) async {
    statuses.add((id, status));
    return const Ok(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _support = _FakeSupport();

final _post = AdminPostSummary(
  id: 'p1',
  caption: 'Pazar sabahı Belgrad Ormanı turu',
  mediaCount: 0,
  likeCount: 12,
  commentCount: 1,
  createdAt: DateTime(2026, 10, 19),
  authorId: 'u1',
  authorUsername: 'ayse.k',
);

final _removedPost = AdminPostSummary(
  id: 'p2',
  caption: 'Kampanya bağlantısı',
  mediaCount: 0,
  likeCount: 0,
  commentCount: 0,
  createdAt: DateTime(2026, 10, 18),
  authorId: 'u2',
  authorUsername: 'can_dag',
  removedAt: DateTime(2026, 10, 19),
  removedReason: 'Spam',
);

/// Records content removals.
class _FakeContent implements AdminContentRepository {
  final removedPosts = <(String, String)>[];
  final removedComments = <(String, String)>[];

  @override
  Future<Result<void>> removePost(String id, {required String reason}) async {
    removedPosts.add((id, reason));
    return const Ok(null);
  }

  @override
  Future<Result<void>> removeComment(String id, {required String reason}) async {
    removedComments.add((id, reason));
    return const Ok(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _content = _FakeContent();

final _broadcast = AdminBroadcast(
  id: 'b1',
  title: 'Akşam sohbeti',
  groupId: 'g1',
  groupName: 'Akustik Geceler',
  groupHandle: 'akustik',
  hostUsername: 'deniz',
  startedAt: DateTime.now().subtract(const Duration(minutes: 12)),
  participants: 37,
);

final _scheduledBroadcast = AdminBroadcast(
  id: 'b2',
  title: 'Pazar konseri',
  groupId: 'g1',
  groupName: 'Doğa Yürüyüşçüleri',
  groupHandle: 'doga.yuruyus',
  status: AdminLiveStatus.scheduled,
  hostUsername: 'elif',
  scheduledAt: DateTime(2026, 11, 2, 20),
  notified: 42,
);

const _pushStats = AdminPushStats(
  configured: false,
  androidDevices: 12,
  iosDevices: 0,
  webDevices: 0,
  usersWithDevice: 11,
  created24h: 85,
  delivered24h: 0,
  deliveries24h: 0,
  waiting: 0,
  byType24h: [(type: 'live_scheduled', count: 42), (type: 'like', count: 30)],
);

/// Records emergency closes.
class _FakeLive implements AdminLiveRepository {
  final ended = <(String, String)>[];

  @override
  Future<Result<void>> end(String id, {required String reason}) async {
    ended.add((id, reason));
    return const Ok(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _live = _FakeLive();

final _adminEvent = AdminEvent(
  id: 'ev1',
  title: 'Belgrad Ormanı yürüyüşü',
  groupId: 'g1',
  groupName: 'Doğa Yürüyüşçüleri',
  groupHandle: 'doga',
  startsAt: DateTime.now().add(const Duration(days: 3)),
  location: 'Bahçeköy',
  capacity: 20,
  goingCount: 12,
  waitlistCount: 0,
);

/// Records event cancellations.
class _FakeEvents implements AdminEventsRepository {
  final canceled = <(String, String)>[];
  final canceledGoals = <String>[];
  final excluded = <(String, String)>[];

  @override
  Future<Result<void>> excludeFromLeague(DateTime month, String groupId, {required String reason}) async {
    excluded.add((groupId, reason));
    return const Ok(null);
  }

  @override
  Future<Result<void>> cancelGoal(String id) async {
    canceledGoals.add(id);
    return const Ok(null);
  }

  @override
  Future<Result<void>> cancel(String id, {required String reason}) async {
    canceled.add((id, reason));
    return const Ok(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _events = _FakeEvents();

class _FakeModeration implements AdminModerationRepository {
  final reviewed = <(String, bool)>[];
  final decided = <(String, bool, String)>[];

  @override
  Future<Result<void>> review(String reportId, {required bool actioned}) async {
    reviewed.add((reportId, actioned));
    return const Ok(null);
  }

  @override
  Future<Result<void>> decideAppeal(String appealId, {required bool overturn, required String note}) async {
    decided.add((appealId, overturn, note));
    return const Ok(null);
  }

  final referralDecisions = <(String, bool, int?, bool, String)>[];
  final authorities = <(String, String)>[];

  @override
  Future<Result<AdminReferralOutcome>> decideReferral(
    String referralId, {
    required bool ban,
    int? banDays,
    required bool lawEnforcement,
    required String note,
  }) async {
    referralDecisions.add((referralId, ban, banDays, lawEnforcement, note));
    return const Ok(AdminReferralOutcome(banned: true, canceledPlans: 2, suspendedGroups: 1));
  }

  @override
  Future<Result<void>> markAuthoritiesNotified(String referralId, {required String note}) async {
    authorities.add((referralId, note));
    return const Ok(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _moderation = _FakeModeration();

final _report = AdminReport(
  id: 'r1',
  targetType: 'user',
  targetId: 'u9',
  reason: 'spam',
  note: 'Reklam yapıyor',
  excerpt: '@reklamci · Reklamcı',
  status: AdminReportStatus.open,
  openCount: 2,
  createdAt: DateTime(2026, 10, 21),
  reporterUsername: 'elif',
  subjectId: 'u9',
  subjectUsername: 'reklamci',
);

final _appeal = AdminAppeal(
  id: 'a1',
  userId: 'u9',
  username: 'reklamci',
  groupId: 'g1',
  groupName: 'Doğa Yürüyüşçüleri',
  groupHandle: 'doga.yuruyus',
  sanctionType: 'warning',
  caseReason: 'Grupta reklam paylaştı.',
  body: 'Reklam değil, etkinlik duyurusuydu.',
  status: AdminAppealStatus.pending,
  createdAt: DateTime(2026, 10, 21),
);

AdminReferral _referral({AdminReferralStatus status = AdminReferralStatus.pending, LawEnforcementState law = LawEnforcementState.none}) =>
    AdminReferral(
      id: 'f1',
      groupId: 'g1',
      groupName: 'Doğa Yürüyüşçüleri',
      subjectId: 'u9',
      subjectUsername: 'tehditci',
      category: 'threat',
      reason: 'Üyeleri ölümle tehdit etti.',
      evidence: [AdminReferralEvidence(targetType: 'comment', reason: 'violence', excerpt: 'Seni bulacağım', reportedAt: DateTime(2026, 10, 27))],
      status: status,
      lawEnforcement: law,
      createdAt: DateTime(2026, 10, 28),
    );

var _referralRow = _referral();

Widget _app(Widget child, {StaffRole role = StaffRole.admin}) => ProviderScope(
      overrides: [
        adminBillingRepositoryProvider.overrideWithValue(_billing),
        adminSupportRepositoryProvider.overrideWithValue(_support),
        adminContentRepositoryProvider.overrideWithValue(_content),
        adminLiveRepositoryProvider.overrideWithValue(_live),
        adminEventsRepositoryProvider.overrideWithValue(_events),
        adminModerationRepositoryProvider.overrideWithValue(_moderation),
        adminGoalSearchProvider.overrideWith(
          (ref, search) async => AdminGoalPage(items: [
            AdminGoal(
              id: 'q1', title: 'Ekim yürüyüşleri', kind: 'group', metric: 'attended', target: 50, groupId: 'g1',
              groupName: 'Doğa Yürüyüşçüleri', groupHandle: 'doga.yuruyus', startsAt: DateTime(2026, 10, 1),
              endsAt: DateTime.now().add(const Duration(days: 10)), completions: 7,
            ),
          ], total: 1, page: 1, pageSize: 20),
        ),
        adminLeaguesProvider.overrideWith(
          (ref, month) async => AdminLeagueMonth(month: month, leagues: const [
            AdminLeague(
              category: 'hiking', categoryName: 'Yürüyüş', province: 6, groups: 2, leaderId: 'g1',
              leaderName: 'Doğa Yürüyüşçüleri', leaderPoints: 42, excluded: 1,
            ),
          ]),
        ),
        adminLeagueTableProvider.overrideWith(
          (ref, key) async => AdminLeagueTable(
            finalized: false,
            rows: const [
              AdminLeagueRow(
                rank: 1, groupId: 'g1', groupName: 'Doğa Yürüyüşçüleri', groupHandle: 'doga.yuruyus', points: 42,
                attended: 22, held: 3, welcomes: 1, goodReviews: 2,
              ),
            ],
            exclusions: [
              AdminLeagueExclusion(
                groupId: 'g9', groupName: 'Hızlı Adımlar', groupHandle: 'hizli', reason: 'Sahte katılım',
                createdAt: DateTime(2026, 10, 20), by: 'moderator',
              ),
            ],
          ),
        ),
        adminReportSearchProvider.overrideWith(
          (ref, search) async => AdminReportPage(items: [_report], total: 1, page: 1, pageSize: 20),
        ),
        adminAppealSearchProvider.overrideWith(
          (ref, search) async => AdminAppealPage(items: [_appeal], total: 1, page: 1, pageSize: 20),
        ),
        adminReferralSearchProvider.overrideWith(
          (ref, search) async => AdminReferralPage(items: [_referralRow], total: 1, page: 1, pageSize: 20),
        ),
        adminEventSearchProvider.overrideWith(
          (ref, search) async => AdminEventPage(items: [_adminEvent], total: 1, page: 1, pageSize: 20),
        ),
        broadcastSearchProvider.overrideWith(
          (ref, search) async => BroadcastPage(
            items: [if (search.status == AdminLiveStatus.scheduled) _scheduledBroadcast else _broadcast],
            total: 1,
            page: 1,
            pageSize: 20,
          ),
        ),
        pushStatsProvider.overrideWith((ref) async => _pushStats),
        matchingStatsProvider.overrideWith(
          (ref) async => const AdminMatchingStats(
            profiles: 120,
            friendProfiles: 90,
            datingProfiles: 70,
            women: 55,
            men: 60,
            nonbinary: 5,
            paused: 8,
            suspended: 2,
            likes24h: 340,
            passes24h: 410,
            matches24h: 23,
            activeMatches: 180,
            openReports: 3,
            premiumProfiles: 14,
            superLikes24h: 12,
            activeBoosts: 2,
            settings: AdminMatchingSettings(dailyFreeLikes: 10, dailyFreeSuperLikes: 1, dailyPremiumSuperLikes: 5, boostMinutes: 30),
          ),
        ),
        matchingPackagesProvider.overrideWith(
          (ref) async => const [
            AdminPremium(
              slug: 'matching_premium',
              name: 'Hepsi Bir Arada',
              isActive: true,
              prices: [(currency: 'TRY', period: 'month', amountMinor: 24900), (currency: 'TRY', period: 'year', amountMinor: 249000)],
              activeMembers: 16,
              grantedMembers: 2,
              revenue30d: [(currency: 'TRY', amountMinor: 498000, orders: 2)],
            ),
          ],
        ),
        contentSearchProvider.overrideWith(
          (ref, search) async => PostPage(items: [_post, _removedPost], total: 2, page: 1, pageSize: 24),
        ),
        postDetailProvider.overrideWith(
          (ref, id) async => AdminPostDetail(
            post: _post,
            media: const [],
            comments: [
              AdminComment(id: 'c1', authorId: 'u2', authorUsername: 'can_dag', body: 'Ben de geliyorum', createdAt: DateTime(2026, 10, 19)),
            ],
          ),
        ),
        supportStatsProvider.overrideWith(
          (ref) async => const AdminSupportStats(openProblems: 1, openRequests: 1, openSuggestions: 0, awaitingReply: 1),
        ),
        ticketSearchProvider.overrideWith(
          (ref, search) async => TicketPage(items: _tickets, total: _tickets.length, page: 1, pageSize: 20),
        ),
        ticketDetailProvider.overrideWith(
          (ref, id) async => AdminTicketDetail(
            ticket: _ticket,
            email: 'can@gway.app',
            groupHandle: 'pedal',
            messages: [
              AdminTicketMessage(
                id: 1,
                fromStaff: false,
                body: 'Yeni adres: pedal.istanbul',
                attachments: const [],
                createdAt: DateTime(2026, 10, 19),
              ),
            ],
          ),
        ),
        myStaffRoleProvider.overrideWith((ref) async => role),
        billingStatsProvider.overrideWith((ref) async => _stats),
        orderSearchProvider.overrideWith(
          (ref, search) async => OrderPage(items: _orders, total: _orders.length, page: 1, pageSize: 20),
        ),
        subscriptionSearchProvider.overrideWith(
          (ref, search) async => SubscriptionPage(items: [_subscription], total: 1, page: 1, pageSize: 20),
        ),
        adminPlansProvider.overrideWith((ref) async => _plans),
        paymentProvidersProvider.overrideWith((ref) async => _paymentProviders),
        userStatsProvider.overrideWith((ref) async => const AdminUserStats(total: 3, active: 2, suspended: 1, pendingDeletion: 0)),
        userSearchProvider.overrideWith(
          (ref, search) async => UserPage(items: _users, total: _users.length, page: 1, pageSize: 20),
        ),
        userDetailProvider.overrideWith((ref, id) async => _detail),
        userPackagesProvider.overrideWith((ref, id) async => _userPackages),
        overviewProvider.overrideWith((ref, days) async => _overview(days)),
        legalKindsProvider.overrideWith((ref) async => _legalKinds),
        securitySettingsProvider.overrideWith((ref) async => _securitySettings),
        securityReviewsProvider.overrideWith((ref, status) async => _securityReviews),
        userSecurityProvider.overrideWith((ref, id) async => _userSecurity),
        categoriesProvider.overrideWith((ref) async => const [Category(slug: 'cycling', name: 'Bisiklet')]),
        groupStatsProvider.overrideWith((ref) async => const AdminGroupStats(total: 2, active: 1, suspended: 1)),
        groupSearchProvider.overrideWith(
          (ref, search) async => GroupPage(items: _groups, total: _groups.length, page: 1, pageSize: 20),
        ),
        groupDetailProvider.overrideWith((ref, id) async => _groupDetail),
      ],
      child: MaterialApp(theme: GwTheme.light(), home: Scaffold(body: child)),
    );

// A week of every measure: rising, so the cards show a rise against the previous week.
AdminOverview _overview(int days) {
  const keys = [
    'new_users', 'active_users', 'new_groups', 'posts', 'comments', 'likes', 'reactions', 'messages', 'match_likes',
    'super_likes', 'matches', 'reports_opened', 'reports_reviewed', 'live_started', 'welcome_requests', 'welcomes_matched', 'welcomes_thanked', 'card_shares_year', 'card_shares_event', 'card_shares_map', 'tonight_free', 'tonight_tables', 'tonight_tables_set', 'revenue_try', 'revenue_usd', 'paid_orders',
  ];
  final points = [for (var i = 0; i < 7; i++) (i + 1) * 3];
  final previous = [for (var i = 0; i < 7; i++) i + 1];
  return AdminOverview(
    days: days,
    weekly: false,
    buckets: [for (var i = 0; i < 7; i++) DateTime(2026, 10, 21 + i)],
    metrics: {
      for (final k in keys)
        k: AdminMetric(
          key: k,
          current: k.startsWith('revenue') ? 2490000 : points.fold(0, (a, b) => a + b),
          previous: previous.fold(0, (a, b) => a + b),
          points: k.startsWith('revenue') ? [for (final p in points) p * 10000] : points,
          previousPoints: previous,
        ),
    },
    snapshot: const AdminSnapshot(users: 1250, groups: 48, openReports: 3, openTickets: 2, liveNow: 1, matchProfiles: 310),
  );
}

// A running granted package and an earlier bought one that was refunded.
final _userPackages = [
  AdminPersonalSubscription(
    id: 's1',
    planSlug: 'matching_chat',
    planName: 'Eşleşme Sohbeti',
    period: null,
    startsAt: DateTime.now().subtract(const Duration(days: 1)),
    endsAt: DateTime.now().add(const Duration(days: 29)),
    canceledAt: null,
    orderId: null,
    orderStatus: null,
    amountMinor: null,
    currency: null,
    grantReason: 'Destek telafisi',
    grantedByUsername: 'ekip',
  ),
  AdminPersonalSubscription(
    id: 's0',
    planSlug: 'matching_premium',
    planName: 'Hepsi Bir Arada',
    period: 'month',
    startsAt: DateTime(2026, 9, 1),
    endsAt: DateTime(2026, 9, 10),
    canceledAt: DateTime(2026, 9, 10),
    orderId: 'o0',
    orderStatus: 'refunded',
    amountMinor: 24900,
    currency: 'TRY',
    grantReason: null,
    grantedByUsername: null,
  ),
];

final _legalKinds = [
  LegalKind(kind: 'privacy_notice', audience: 'signup', versions: [
    LegalVersion(
        version: 2, title: 'Aydınlatma v2', publishedAt: DateTime(2026, 10, 1), isCurrent: true, isDraft: false, consentCount: 0),
    LegalVersion(
        version: 1, title: 'Aydınlatma v1', publishedAt: DateTime(2026, 9, 1), isCurrent: false, isDraft: false, consentCount: 42),
  ]),
  const LegalKind(kind: 'explicit_consent', audience: 'signup', versions: []),
  const LegalKind(kind: 'terms', audience: 'signup', versions: []),
  const LegalKind(kind: 'distance_sales', audience: 'purchase', versions: []),
];

final _securitySettings = AdminSecuritySettings(
  enforce: true,
  smsConfigured: false,
  lookupEnabled: false,
  updatedAt: DateTime(2026, 10, 27, 12),
);

final _check = AdminLocationCheck(
  checkedAt: DateTime(2026, 10, 27, 11),
  platform: 'android',
  gpsCountry: 'DE',
  ipCountry: 'TR',
  simCountry: 'TR',
  phoneCountry: null,
  isMocked: false,
  vpn: true,
  signals: const ['ip_mismatch', 'vpn', 'sim_mismatch'],
  verdict: 'restricted',
);

final _securityReviews = [
  AdminSecurityReview(
    id: 'r1',
    userId: 'u1',
    username: 'ayse',
    displayName: 'Ayşe Yılmaz',
    signals: const ['ip_mismatch', 'vpn', 'sim_mismatch'],
    status: AdminReviewStatus.open,
    openedAt: DateTime(2026, 10, 27, 11),
    resolvedAt: null,
    note: null,
    check: _check,
  ),
];

final _userSecurity = AdminUserSecurity(
  state: 'restricted',
  phoneMasked: '+90 ••• ••• •• 34',
  phoneCountry: 'TR',
  phoneVerifiedAt: DateTime(2026, 10, 20),
  totpEnabled: true,
  allowedCountry: 'DE',
  locationCheckedAt: DateTime(2026, 10, 27, 11),
  exemptUntil: null,
  checks: [_check],
);

Future<void> _pumpAt(WidgetTester tester, Size size, Widget child, {StaffRole role = StaffRole.admin}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_app(child, role: role));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('support sees no security switch and cannot act on reviews', (tester) async {
    await _pumpAt(tester, const Size(1280, 900), const AdminSecurityScreen(), role: StaffRole.support);

    expect(find.text('Konum, telefon ve giriş doğrulaması zorunlu'), findsNothing);
    expect(find.text('Ayşe Yılmaz'), findsOneWidget);
    expect(find.text('Onayla'), findsNothing);
  });

  for (final (name, size) in [('desktop', const Size(1280, 900)), ('phone', const Size(390, 844))]) {
    testWidgets('security reviews lay out on $name', (tester) async {
      await _pumpAt(tester, size, const AdminSecurityScreen());

      expect(tester.takeException(), isNull);
      expect(find.text('Konum, telefon ve giriş doğrulaması zorunlu'), findsOneWidget);
      expect(find.text('SMS sağlayıcısı yapılandırılmadı'), findsOneWidget);
      expect(find.text('VPN tespiti'), findsOneWidget);
      expect(find.text('Yüklü VPN uygulaması uyarısı'), findsOneWidget);
      expect(find.text('Farklı numara ve SIM tespiti'), findsOneWidget);
      expect(find.text('Ayşe Yılmaz'), findsOneWidget);
      expect(find.text('VPN açık'), findsOneWidget);
      expect(find.text('GPS DE · IP TR · SIM TR · Numara — · android'), findsOneWidget);
      expect(find.text('Onayla'), findsOneWidget);
      expect(find.text('Banla'), findsOneWidget);
    });

    testWidgets('legal management lays out on $name', (tester) async {
      await _pumpAt(tester, size, const AdminLegalScreen());

      expect(tester.takeException(), isNull);
      expect(find.text('KVKK Aydınlatma Metni'), findsOneWidget);
      expect(find.text('Aydınlatma v2'), findsOneWidget);
      expect(find.text('Yürürlükte'), findsOneWidget);
      // The consented v1 is frozen: it shows the lock badge, not a delete button.
      expect(find.text('42 onay · kilitli'), findsOneWidget);
      expect(find.text('Bu tür için henüz bir metin yayınlanmadı.'), findsWidgets);
      expect(find.text('Yeni sürüm'), findsWidgets);
    });

    testWidgets('overview lays out on $name', (tester) async {
      await _pumpAt(tester, size, const AdminOverviewScreen());

      expect(tester.takeException(), isNull);
      expect(find.text('Genel bakış'), findsWidgets);
      expect(find.text('Yeni kullanıcı'), findsWidgets);
      expect(find.text('1.250'), findsOneWidget);
      expect(find.text('Gelir (TRY)'), findsOneWidget);
      // 84 against 28: a 200% rise.
      expect(find.text('%200'), findsWidgets);
      expect(find.text('Kullanıcı büyümesi'), findsOneWidget);

      // Every chart has a table view.
      await tester.ensureVisible(find.byTooltip('Tablo olarak göster').first);
      await tester.tap(find.byTooltip('Tablo olarak göster').first);
      await tester.pumpAndSettle();
      expect(find.text('Toplam'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final (name, size) in [('desktop', const Size(1280, 900)), ('phone', const Size(390, 844))]) {
    testWidgets('users screen lays out on $name', (tester) async {
      await _pumpAt(tester, size, const UsersScreen());

      expect(tester.takeException(), isNull);
      expect(find.text('Toplam kullanıcı'), findsOneWidget);
      expect(find.text('Can Dağ'), findsOneWidget);
      expect(find.text('Askıda'), findsWidgets);
      expect(find.text('1–3 / 3 kullanıcı'), findsOneWidget);
    });

    testWidgets('user detail lays out on $name', (tester) async {
      await _pumpAt(tester, size, const UserDetailScreen(userId: 'u2'));

      expect(tester.takeException(), isNull);
      expect(find.text('Askıyı kaldır'), findsOneWidget);
      expect(find.textContaining('Spam paylaşımları'), findsOneWidget);
      expect(find.text('Hesap askıya alındı'), findsOneWidget);
      expect(find.textContaining('GWAY Ekibi'), findsOneWidget);
      expect(find.text('Paketleri'), findsOneWidget);
      expect(find.text('Eşleşme Sohbeti'), findsOneWidget);
      expect(find.text('Paket tanımla'), findsOneWidget);
      expect(find.text('İptal et'), findsOneWidget);
      expect(find.textContaining('iade edildi'), findsOneWidget);
      expect(find.text('Mağaza inceleme hesabı'), findsOneWidget);
    });
  }

  testWidgets('only platform admins give or cancel packages', (tester) async {
    await _pumpAt(tester, const Size(1280, 900), const UserDetailScreen(userId: 'u2'), role: StaffRole.support);

    expect(find.text('Eşleşme Sohbeti'), findsOneWidget);
    expect(find.text('Paket tanımla'), findsNothing);
    expect(find.text('İptal et'), findsNothing);
    // The store review exemption is for platform admins only.
    expect(find.text('Mağaza inceleme hesabı'), findsNothing);
  });

  for (final (name, size) in [('desktop', const Size(1280, 900)), ('phone', const Size(390, 844))]) {
    testWidgets('groups screen lays out on $name', (tester) async {
      await _pumpAt(tester, size, const AdminGroupsScreen());

      expect(tester.takeException(), isNull);
      expect(find.text('Toplam grup'), findsOneWidget);
      expect(find.text('Pedal Kadıköy'), findsOneWidget);
      expect(find.text('1–2 / 2 grup'), findsOneWidget);
    });

    testWidgets('group detail lays out on $name', (tester) async {
      await _pumpAt(tester, size, const AdminGroupDetailScreen(groupId: 'g2'));

      expect(tester.takeException(), isNull);
      expect(find.text('Askıyı kaldır'), findsOneWidget);
      expect(find.textContaining('Dolandırıcılık şikayetleri'), findsWidgets);
      expect(find.text('Yönetim ekibi'), findsOneWidget);
      expect(find.text('Bisiklet'), findsOneWidget);
      expect(find.text('Rol verildi'), findsOneWidget);
      expect(find.textContaining('Ayşe Kaya · Yönetici · '), findsOneWidget);
      expect(find.text('Paket'), findsOneWidget);
      expect(find.text('Başlangıç · Aylık'), findsOneWidget);
      expect(find.text('İptal et'), findsOneWidget);
    });

    testWidgets('billing screen lays out on $name', (tester) async {
      await _pumpAt(tester, size, const AdminBillingScreen());

      expect(tester.takeException(), isNull);
      expect(find.text('948 ₺'), findsWidgets);
      expect(find.text(r'$249.90'), findsWidgets);
      expect(find.text('Aylık gelir'), findsOneWidget);
      expect(find.text('Pedal Kadıköy (@pedal)'), findsOneWidget);
      expect(find.text('Yarım kaldı'), findsOneWidget);
    });

    testWidgets('plans screen lays out on $name', (tester) async {
      await _pumpAt(tester, size, const AdminPlansScreen());

      expect(tester.takeException(), isNull);
      expect(find.text('Başlangıç'), findsOneWidget);
      expect(find.text('249 ₺'), findsOneWidget);
      expect(find.text('Düzenle'), findsNWidgets(2));
    });
  }

  for (final (name, size) in [('desktop', const Size(1280, 900)), ('phone', const Size(390, 844))]) {
    testWidgets('support screen shows colored kinds on $name', (tester) async {
      await _pumpAt(tester, size, const AdminSupportScreen());

      expect(tester.takeException(), isNull);
      expect(find.text('Açık sorunlar'), findsOneWidget);
      expect(find.text('Açık talepler'), findsOneWidget);
      expect(find.text('Açık istekler'), findsOneWidget);
      expect(find.text('Grup adresini değiştirmek istiyorum'), findsOneWidget);
      expect(find.text('Yanıt bekliyor'), findsOneWidget);
      expect(find.byIcon(Icons.lightbulb_outline), findsWidgets);
    });

    testWidgets('ticket detail lays out on $name', (tester) async {
      await _pumpAt(tester, size, const AdminTicketDetailScreen(ticketId: 't1'));

      expect(tester.takeException(), isNull);
      expect(find.text('Yeni adres: pedal.istanbul'), findsOneWidget);
      expect(find.textContaining('Pedal Kadıköy'), findsOneWidget);
      expect(find.text('can@gway.app'), findsOneWidget);
    });
  }

  testWidgets('staff reply and change the status', (tester) async {
    await _pumpAt(tester, const Size(1280, 900), const AdminTicketDetailScreen(ticketId: 't1'));

    await tester.enterText(find.widgetWithText(TextField, 'Yanıt'), 'Adresi değiştirdik.');
    await tester.tap(find.text('Yanıtla'));
    await tester.pumpAndSettle();
    expect(_support.replies.last, ('t1', 'Adresi değiştirdik.'));

    await tester.tap(find.text('Yeni').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Çözüldü').last);
    await tester.pumpAndSettle();
    expect(_support.statuses.last, ('t1', AdminSupportStatus.resolved));
  });

  testWidgets('support sees orders but not revenue, and cannot edit plans or cancel', (tester) async {
    await _pumpAt(tester, const Size(1280, 900), const AdminBillingScreen(), role: StaffRole.support);
    expect(find.text('Aylık gelir'), findsNothing);
    expect(find.text('Pedal Kadıköy (@pedal)'), findsOneWidget);

    await tester.tap(find.text('Abonelikler').last);
    await tester.pumpAndSettle();
    expect(find.text('Aktif'), findsOneWidget);

    await _pumpAt(tester, const Size(1280, 900), const AdminPlansScreen(), role: StaffRole.support);
    expect(find.text('Düzenle'), findsNothing);

    await _pumpAt(tester, const Size(1280, 900), const AdminGroupDetailScreen(groupId: 'g2'), role: StaffRole.support);
    expect(find.text('Paket'), findsOneWidget);
    expect(find.text('İptal et'), findsNothing);
    expect(find.text('Paket tanımla'), findsNothing);
    expect(find.text('Paketi iptal et'), findsNothing);
  });

  testWidgets('admins see where to connect the payment providers and check their keys', (tester) async {
    await _pumpAt(tester, const Size(1280, 900), const AdminBillingScreen());

    expect(find.text('Ödeme sağlayıcıları'), findsOneWidget);
    expect(find.text('https://api.gway.app/billing/paytr/notify'), findsOneWidget);
    expect(find.text('https://api.gway.app/billing/iyzico/webhook'), findsOneWidget);
    expect(find.text('Test modu açık: kartlardan para çekilmez.'), findsOneWidget);

    await tester.tap(find.widgetWithText(GwButton, 'Bağlantıyı dene').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(GwButton, 'Bağlantıyı dene').last);
    await tester.pumpAndSettle();
    expect(_billing.checks.sublist(_billing.checks.length - 2), ['paytr', 'iyzico']);
    expect(find.textContaining('Bağlantı başarılı'), findsOneWidget);
    expect(find.text('iyzico reddetti: 1001 api bilgileri bulunamadı'), findsOneWidget);
  });

  testWidgets('support staff do not see the payment provider setup', (tester) async {
    await _pumpAt(tester, const Size(1280, 900), const AdminBillingScreen(), role: StaffRole.support);
    expect(find.text('Ödeme sağlayıcıları'), findsNothing);
  });

  testWidgets('an admin gives a group a plan for some days with a reason', (tester) async {
    await _pumpAt(tester, const Size(1280, 900), const AdminGroupDetailScreen(groupId: 'g2'));
    await tester.tap(find.widgetWithText(GwButton, 'Paket tanımla'));
    await tester.pumpAndSettle();

    expect(find.text('Grubun mevcut süresi bitince başlar.'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextFormField, 'Gün (1–365)'), '400');
    await tester.tap(find.widgetWithText(GwButton, 'Tanımla'));
    await tester.pumpAndSettle();
    expect(find.text('1 ile 365 arasında bir gün sayısı yaz.'), findsOneWidget);
    expect(find.text('Bir açıklama yaz.'), findsOneWidget);
    expect(_billing.grants, isEmpty);

    await tester.enterText(find.widgetWithText(TextFormField, 'Gün (1–365)'), '45');
    await tester.enterText(find.widgetWithText(TextFormField, 'Açıklama'), 'Festival sponsorluğu');
    await tester.tap(find.widgetWithText(GwButton, 'Tanımla'));
    await tester.pumpAndSettle();
    expect(_billing.grants.last, ('g2', 'starter', 45, 'Festival sponsorluğu'));
  });

  testWidgets('an admin cancels all of a group plan with a reason', (tester) async {
    await _pumpAt(tester, const Size(1280, 900), const AdminGroupDetailScreen(groupId: 'g2'));
    await tester.tap(find.widgetWithText(GwButton, 'Paketi iptal et'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Gerekçe'), 'Topluluk kuralları ihlali');
    await tester.tap(find.widgetWithText(GwButton, 'İptal et').last);
    await tester.pumpAndSettle();
    expect(_billing.groupCancels.last, ('g2', 'Topluluk kuralları ihlali', false));
  });

  testWidgets('a granted and a cancelled slice show who gave them and why', (tester) async {
    final now = DateTime.now();
    final detail = AdminGroupDetail(
      group: _groups[1],
      plan: const AdminGroupPlan(slug: 'free', name: 'Ücretsiz', maxMembers: 50),
      subscriptions: [
        AdminSubscription(
          id: 's9',
          groupId: 'g2',
          groupName: 'Pedal Kadıköy',
          groupHandle: 'pedal',
          planName: 'Pro',
          startsAt: now.subtract(const Duration(days: 5)),
          endsAt: now.subtract(const Duration(days: 1)),
          canceledAt: now.subtract(const Duration(days: 1)),
          cancelReason: 'admin',
          grantReason: 'Festival sponsorluğu',
          grantedByUsername: 'gway_ekip',
          cancelNote: 'Sponsorluk bitti',
        ),
      ],
      about: '',
      pendingRequests: 0,
      pendingInvitations: 0,
      team: const [],
      history: const [],
    );
    await _pumpAt(tester, const Size(1280, 900), Scaffold(body: SingleChildScrollView(child: GroupPlanPanel(detail: detail))));

    expect(tester.takeException(), isNull);
    expect(find.text('Pro'), findsOneWidget);
    expect(find.textContaining('Tanımlandı (@gway_ekip): Festival sponsorluğu'), findsOneWidget);
    expect(find.text('İptal gerekçesi: Sponsorluk bitti'), findsOneWidget);
    expect(find.text('Paketi iptal et'), findsNothing);
  });

  for (final (name, size) in [('desktop', const Size(1280, 900)), ('phone', const Size(390, 844))]) {
    testWidgets('content screen lays out on $name', (tester) async {
      await _pumpAt(tester, size, const AdminContentScreen());

      expect(tester.takeException(), isNull);
      expect(find.text('Pazar sabahı Belgrad Ormanı turu'), findsOneWidget);
      expect(find.text('Kaldırıldı'), findsOneWidget);
      expect(find.text('1–2 / 2 gönderi'), findsOneWidget);
    });

    testWidgets('post detail lays out on $name', (tester) async {
      await _pumpAt(tester, size, const AdminPostDetailScreen(postId: 'p1'));

      expect(tester.takeException(), isNull);
      expect(find.text('Ben de geliyorum'), findsOneWidget);
      expect(find.text('@ayse.k'), findsWidgets);
    });
  }

  testWidgets('moderators remove posts and comments with a reason', (tester) async {
    await _pumpAt(tester, const Size(1280, 900), const AdminPostDetailScreen(postId: 'p1'), role: StaffRole.moderator);

    await tester.tap(find.widgetWithText(GwButton, 'Kaldır'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Gerekçe'), 'Taciz');
    await tester.tap(find.widgetWithText(GwButton, 'Kaldır').last);
    await tester.pumpAndSettle();
    expect(_content.removedPosts.last, ('p1', 'Taciz'));

    await tester.tap(find.byTooltip('Yorumu kaldır'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Gerekçe'), 'Spam');
    await tester.tap(find.widgetWithText(GwButton, 'Kaldır').last);
    await tester.pumpAndSettle();
    expect(_content.removedComments.last, ('c1', 'Spam'));
  });

  testWidgets('support views content but cannot remove it', (tester) async {
    await _pumpAt(tester, const Size(1280, 900), const AdminPostDetailScreen(postId: 'p1'), role: StaffRole.support);
    expect(find.widgetWithText(GwButton, 'Kaldır'), findsNothing);
    expect(find.byTooltip('Yorumu kaldır'), findsNothing);
  });

  for (final (name, size) in [('desktop', const Size(1280, 900)), ('phone', const Size(390, 844))]) {
    testWidgets('live screen lays out on $name', (tester) async {
      await _pumpAt(tester, size, const AdminLiveScreen());

      expect(tester.takeException(), isNull);
      expect(find.text('Akşam sohbeti'), findsOneWidget);
      expect(find.byType(GwLiveBadge), findsOneWidget);
      expect(find.textContaining('37 kişi'), findsOneWidget);
    });
  }

  testWidgets('moderators close a live room with a reason; support only watches', (tester) async {
    await _pumpAt(tester, const Size(1280, 900), const AdminLiveScreen(), role: StaffRole.moderator);
    await tester.tap(find.widgetWithText(GwButton, 'Kapat'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Gerekçe'), 'Canlı yayında taciz');
    await tester.tap(find.widgetWithText(GwButton, 'Kapat').last);
    await tester.pumpAndSettle();
    expect(_live.ended.single, ('b1', 'Canlı yayında taciz'));
  });

  testWidgets('scheduled broadcasts show when and to how many members they were announced', (tester) async {
    await _pumpAt(tester, const Size(1280, 900), const AdminLiveScreen(), role: StaffRole.moderator);
    await tester.tap(find.text('Planlı'));
    await tester.pumpAndSettle();

    expect(find.text('Pazar konseri'), findsOneWidget);
    expect(find.textContaining('Planlanan 2 Kasım 2026, 20:00'), findsOneWidget);
    expect(find.textContaining('42 üyeye duyuruldu'), findsOneWidget);
    expect(find.byType(GwLiveBadge), findsNothing);
    expect(find.widgetWithText(GwButton, 'Kapat'), findsNothing);
  });

  for (final (name, size) in [('desktop', const Size(1280, 900)), ('phone', const Size(390, 844))]) {
    testWidgets('notifications screen lays out on $name', (tester) async {
      await _pumpAt(tester, size, const AdminNotificationsScreen(), role: StaffRole.support);

      expect(tester.takeException(), isNull);
      expect(find.text('Push kapalı'), findsOneWidget);
      expect(find.text('Canlı yayın planlandı'), findsOneWidget);
      expect(find.text('Gönderi beğenisi'), findsOneWidget);
      expect(find.text('12'), findsWidgets);
    });
  }

  for (final (name, size) in [('desktop', const Size(1280, 900)), ('phone', const Size(390, 844))]) {
    testWidgets('matching screen lays out on $name', (tester) async {
      await _pumpAt(tester, size, const AdminMatchingScreen());

      expect(tester.takeException(), isNull);
      expect(find.text('Son 24 saatte eşleşme'), findsWidgets);
      expect(find.text('23'), findsWidgets);
      expect(find.text('Günlük ücretsiz beğeni'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Hepsi Bir Arada'), 200, scrollable: find.byType(Scrollable).first);
      expect(find.textContaining('16 kişi (2)'), findsOneWidget);
    });
  }

  testWidgets('support cannot close a live room', (tester) async {
    await _pumpAt(tester, const Size(1280, 900), const AdminLiveScreen(), role: StaffRole.support);
    expect(find.widgetWithText(GwButton, 'Kapat'), findsNothing);
  });

  for (final (name, size) in [('desktop', const Size(1280, 900)), ('phone', const Size(390, 844))]) {
    testWidgets('events screen lays out on $name', (tester) async {
      await _pumpAt(tester, size, const AdminEventsScreen());

      expect(tester.takeException(), isNull);
      expect(find.text('Belgrad Ormanı yürüyüşü'), findsOneWidget);
      expect(find.textContaining('12 / 20'), findsOneWidget);
    });
  }

  for (final (name, size) in [('desktop', const Size(1280, 900)), ('phone', const Size(390, 844))]) {
    testWidgets('reports screen lays out on $name', (tester) async {
      await _pumpAt(tester, size, const AdminReportsScreen());

      expect(tester.takeException(), isNull);
      expect(find.text('2 açık şikayet'), findsOneWidget);
      expect(find.textContaining('Şikayet eden @elif'), findsOneWidget);
    });
  }

  testWidgets('moderators close reports and decide the platform appeals', (tester) async {
    await _pumpAt(tester, const Size(1280, 900), const AdminReportsScreen(), role: StaffRole.moderator);
    await tester.tap(find.widgetWithText(GwButton, 'İşlem yapıldı'));
    await tester.pumpAndSettle();
    expect(_moderation.reviewed.last, ('r1', true));

    await tester.tap(find.text('İtirazlar'));
    await tester.pumpAndSettle();
    expect(find.text('İtiraz: Reklam değil, etkinlik duyurusuydu.'), findsOneWidget);
    await tester.tap(find.widgetWithText(GwButton, 'Yaptırımı kaldır'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Gerekçe'), 'Duyuru reklam sayılmaz');
    await tester.tap(find.widgetWithText(GwButton, 'Kaldır'));
    await tester.pumpAndSettle();
    expect(_moderation.decided.single, ('a1', true, 'Duyuru reklam sayılmaz'));
  });

  testWidgets('an admin bans an illegal-activity referral and records the authorities', (tester) async {
    _referralRow = _referral();
    await _pumpAt(tester, const Size(1280, 900), const AdminReportsScreen());
    await tester.tap(find.text('Yasa dışı'));
    await tester.pumpAndSettle();
    expect(find.text('Kurulun gerekçesi: Üyeleri ölümle tehdit etti.'), findsOneWidget);
    expect(find.text('Seni bulacağım'), findsOneWidget);

    await tester.tap(find.widgetWithText(GwButton, 'Karar ver'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Kalıcı'));
    await tester.tap(find.text('Kolluğa bildirilecek'));
    await tester.tap(find.widgetWithText(GwButton, 'Banla').last);
    await tester.pumpAndSettle();
    expect(_moderation.referralDecisions, isEmpty, reason: 'a decision needs a note');
    await tester.enterText(find.widgetWithText(TextField, 'Karar notu'), 'Tehdit kanıtlandı');
    await tester.tap(find.widgetWithText(GwButton, 'Banla').last);
    await tester.pumpAndSettle();
    expect(_moderation.referralDecisions.single, ('f1', true, null, true, 'Tehdit kanıtlandı'));
    expect(find.textContaining('2 paket dilimi iadesiz iptal edildi, 1 grup askıya alındı'), findsOneWidget);
  });

  testWidgets('moderators read referrals but only an admin decides', (tester) async {
    _referralRow = _referral(status: AdminReferralStatus.banned, law: LawEnforcementState.toNotify);
    await _pumpAt(tester, const Size(390, 844), const AdminReportsScreen(), role: StaffRole.moderator);
    await tester.tap(find.text('Yasa dışı'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Kolluğa bildirilecek'), findsOneWidget);
    expect(find.widgetWithText(GwButton, 'Karar ver'), findsNothing);
    expect(find.widgetWithText(GwButton, 'Kolluğa bildirildi'), findsNothing);
  });

  testWidgets('support staff only read reports', (tester) async {
    await _pumpAt(tester, const Size(1280, 900), const AdminReportsScreen(), role: StaffRole.support);
    expect(find.widgetWithText(GwButton, 'Reddet'), findsNothing);
    expect(find.widgetWithText(GwButton, 'Görüntüle'), findsOneWidget);
  });

  testWidgets('moderators cancel an event with a reason', (tester) async {
    await _pumpAt(tester, const Size(1280, 900), const AdminEventsScreen(), role: StaffRole.moderator);
    await tester.tap(find.widgetWithText(GwButton, 'İptal et'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Gerekçe'), 'Kurallara aykırı');
    await tester.tap(find.widgetWithText(GwButton, 'İptal et').last);
    await tester.pumpAndSettle();
    expect(_events.canceled.single, ('ev1', 'Kurallara aykırı'));
  });

  testWidgets('a plan edit sends every price in minor units', (tester) async {
    await _pumpAt(tester, const Size(1280, 900), const AdminPlansScreen());
    await tester.tap(find.text('Düzenle').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'Üye limiti'), '300');
    await tester.enterText(find.widgetWithText(TextFormField, 'Aylık fiyat').first, '299,90');
    expect(find.text('Satışta'), findsWidgets);
    await tester.tap(find.text('Kaydet'));
    await tester.pumpAndSettle();

    final (slug, update) = _billing.updates.single;
    expect(slug, 'starter');
    expect(update.maxMembers, 300);
    expect(update.prices, hasLength(4));
    expect(update.prices.firstWhere((p) => p.currency == 'TRY' && p.period == 'month').amountMinor, 29990);
    expect(update.prices.firstWhere((p) => p.currency == 'USD' && p.period == 'year').amountMinor, 9990);
  });

  testWidgets('table header appears only on wide layouts', (tester) async {
    await _pumpAt(tester, const Size(1280, 900), const UsersScreen());
    expect(find.text('E-POSTA'), findsOneWidget);

    await _pumpAt(tester, const Size(390, 844), const UsersScreen());
    expect(find.text('E-POSTA'), findsNothing);
  });
  testWidgets('moderators cancel a goal', (tester) async {
    await _pumpAt(tester, const Size(1280, 900), const AdminGoalsScreen(), role: StaffRole.moderator);
    expect(find.textContaining('Grup · 50 katılım · 7 tamamlayan'), findsOneWidget);
    await tester.tap(find.widgetWithText(GwButton, 'İptal et'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(GwButton, 'İptal et').last);
    await tester.pumpAndSettle();
    expect(_events.canceledGoals, ['q1']);
  });

  testWidgets('moderators read a league and take a group out of it', (tester) async {
    await _pumpAt(tester, const Size(1280, 900), const AdminLeaguesScreen(), role: StaffRole.moderator);
    expect(find.text('Ankara · Yürüyüş'), findsOneWidget);
    expect(find.textContaining('lider Doğa Yürüyüşçüleri (42 puan)'), findsOneWidget);

    await tester.tap(find.text('Ankara · Yürüyüş'));
    await tester.pumpAndSettle();
    expect(find.text('22 katılım · 3 organizasyon · 1 karşılama · 2 memnuniyet'), findsOneWidget);
    expect(find.textContaining('Sahte katılım'), findsOneWidget);

    await tester.tap(find.widgetWithText(GwButton, 'Ligden çıkar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Aynı kişiler her gün katılmış görünüyor');
    await tester.pump();
    await tester.tap(find.widgetWithText(GwButton, 'Ligden çıkar').last);
    await tester.pumpAndSettle();
    expect(_events.excluded, [('g1', 'Aynı kişiler her gün katılmış görünüyor')]);
  });

  testWidgets('support reads leagues but cannot exclude', (tester) async {
    await _pumpAt(tester, const Size(1280, 900), const AdminLeaguesScreen(), role: StaffRole.support);
    await tester.tap(find.text('Ankara · Yürüyüş'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(GwButton, 'Ligden çıkar'), findsNothing);
  });
}
