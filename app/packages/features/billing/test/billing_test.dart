import 'package:billing/billing.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _free = Plan(slug: 'free', name: 'Ücretsiz', tier: 0, maxMembers: 50, monthlyEvents: 2, monthlyLiveMinutes: 60);
const _starter = Plan(slug: 'starter', name: 'Başlangıç', tier: 1, maxMembers: 250, monthlyEvents: 10, monthlyLiveMinutes: 600);
const _pro = Plan(slug: 'pro', name: 'Pro', tier: 2, maxMembers: 1000, monthlyEvents: 40, monthlyLiveMinutes: 3000);

final _now = DateTime.now();

GroupPlan _onStarter({int members = 12, Duration left = const Duration(days: 20)}) => GroupPlan(
      plan: _starter,
      memberCount: members,
      currentPeriodEndsAt: _now.add(left),
      paidUntil: _now.add(left),
    );

PlanOption _option(String plan, PlanPeriod period, int amount, PlanChange change, {Duration credit = Duration.zero}) => PlanOption(
      planSlug: plan,
      period: period,
      amountMinor: amount,
      change: change,
      startsAt: change == PlanChange.upgrade ? _now : _now.add(const Duration(days: 20)),
      endsAt: _now.add(const Duration(days: 50)),
      credit: credit,
    );

final _offer = Offer(
  market: const Market(country: 'TR', provider: PaymentProvider.paytr, currency: 'TRY'),
  purchasesEnabled: true,
  currentPlanSlug: 'starter',
  salesTermsVersion: 1,
  options: [
    _option('starter', PlanPeriod.month, 24900, PlanChange.renewal),
    _option('starter', PlanPeriod.year, 249000, PlanChange.renewal),
    _option('pro', PlanPeriod.month, 69900, PlanChange.upgrade, credit: const Duration(hours: 171)),
    _option('pro', PlanPeriod.year, 699000, PlanChange.upgrade),
  ],
);

const _terms = SalesTerms(version: 1, title: 'Ön Bilgilendirme Formu ve Mesafeli Satış Sözleşmesi', body: 'TASLAK metin.');

class _FakeBilling implements BillingRepository {
  final requests = <CheckoutRequest>[];
  Result<Uri> checkoutResult = Ok(Uri.parse('https://www.paytr.com/odeme/guvenli/tok'));

  @override
  Future<Result<Uri>> checkout(String groupId, CheckoutRequest request) async {
    requests.add(request);
    return checkoutResult;
  }

  @override
  Future<Result<Uri>> personalCheckout(String slug, CheckoutRequest request) async {
    requests.add(request);
    return checkoutResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _premium = PersonalOffer(
  market: const Market(country: 'TR', provider: PaymentProvider.paytr, currency: 'TRY'),
  purchasesEnabled: true,
  planSlug: 'matching_premium',
  planName: 'Hepsi Bir Arada',
  salesTermsVersion: 1,
  options: [
    PersonalOption(period: PlanPeriod.month, amountMinor: 14900, startsAt: _now, endsAt: _now.add(const Duration(days: 30))),
    PersonalOption(period: PlanPeriod.year, amountMinor: 149000, startsAt: _now, endsAt: _now.add(const Duration(days: 365))),
  ],
);

Widget _app(
  Widget child, {
  GroupPlan? plan,
  bool web = true,
  _FakeBilling? billing,
  Order Function()? order,
  double textScale = 1,
}) =>
    ProviderScope(
      overrides: [
        purchasesOnThisPlatformProvider.overrideWithValue(web),
        billingRepositoryProvider.overrideWithValue(billing ?? _FakeBilling()),
        plansProvider.overrideWith((ref) async => const [_free, _starter, _pro]),
        groupPlanProvider.overrideWith((ref, id) async => plan),
        planTimelineProvider.overrideWith((ref, id) async => const []),
        offerProvider.overrideWith((ref, id) async => _offer),
        personalOfferProvider.overrideWith((ref, slug) async => _premium),
        salesTermsProvider.overrideWith((ref) async => _terms),
        lastBillingDetailsProvider.overrideWith((ref) async => null),
        orderProvider.overrideWith((ref, id) async => order!()),
      ],
      child: MaterialApp(
        theme: GxTheme.light(),
        home: MediaQuery.withClampedTextScaling(
          minScaleFactor: textScale,
          maxScaleFactor: textScale,
          child: child,
        ),
      ),
    );

Future<void> _pump(WidgetTester tester, Widget app, {Size size = const Size(1280, 1600)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  // A fresh ProviderScope each time, so overridden data is never reused.
  await tester.pumpWidget(const SizedBox());
  await tester.pumpWidget(app);
  await tester.pumpAndSettle();
}

Finder _price(String amount) => find.textContaining('$amount / ', findRichText: true);

Widget _card({required bool canManage, GroupPlan? plan, bool web = true}) => _app(
      Scaffold(body: GroupPlanCard(groupId: 'g1', canManage: canManage, onManage: () {})),
      plan: plan,
      web: web,
    );

void main() {
  group('personal plan', () {
    testWidgets('mobile shows only the status: no prices, no purchase, no pointer elsewhere (Play rule)', (tester) async {
      await _pump(tester, _app(Scaffold(body: PersonalPlanPurchase(slug: 'matching_premium', onPaid: () {})), web: false));

      expect(find.text('Paket durumu'), findsOneWidget);
      expect(_price('1.490 ₺'), findsNothing);
      expect(find.textContaining('web'), findsNothing);
      expect(find.textContaining('Devam et'), findsNothing);
    });

    testWidgets('checkout sends the chosen period with the details', (tester) async {
      final billing = _FakeBilling();
      await _pump(
        tester,
        _app(PersonalCheckoutScreen(slug: 'matching_premium', period: PlanPeriod.month, openPaymentPage: (_) async => true), billing: billing),
      );

      expect(find.text('Hepsi Bir Arada · Aylık'), findsOneWidget);
      for (final (label, value) in [('Ad', 'Ada'), ('Soyad', 'Yılmaz'), ('Telefon', '+90 555 000 00 00'), ('Adres', 'Moda Cad. 1'), ('Şehir', 'İstanbul'), ('Ülke', 'Türkiye')]) {
        await tester.enterText(find.widgetWithText(TextFormField, label), value);
      }
      await tester.tap(find.byType(Checkbox));
      await tester.tap(find.textContaining('Ödemeye geç'));
      // The button keeps spinning while the payment page opens.
      await tester.pump();
      expect(billing.requests.single.period, PlanPeriod.month);
      expect(billing.requests.single.details.city, 'İstanbul');
    });
  });

  group('group plan card', () {
    testWidgets('owner sees the plan, usage and the way to manage it', (tester) async {
      await _pump(tester, _card(canManage: true, plan: _onStarter()));

      expect(find.textContaining('Başlangıç paketi ·'), findsOneWidget);
      expect(find.text('12 / 250 üye'), findsOneWidget);
      expect(find.text('Paketi yükselt'), findsOneWidget);
    });

    testWidgets('owner of a free group is offered a package on the web, only the status on mobile', (tester) async {
      const free = GroupPlan(plan: _free, memberCount: 12, paidUntil: null);
      await _pump(tester, _card(canManage: true, plan: free));
      expect(find.text('Paket al'), findsOneWidget);

      await _pump(tester, _card(canManage: true, plan: free, web: false));
      expect(find.text('Paket al'), findsNothing);
      expect(find.text('Paket'), findsOneWidget);
    });

    testWidgets('owner is reminded a week before the paid time ends', (tester) async {
      await _pump(tester, _card(canManage: true, plan: _onStarter(left: const Duration(days: 3))));

      expect(find.textContaining('tarihinde bitiyor'), findsOneWidget);
    });

    testWidgets('approvers only see that the group is full', (tester) async {
      await _pump(tester, _card(canManage: false, plan: _onStarter()));
      expect(find.textContaining('limit'), findsNothing);
      expect(find.text('Paket'), findsNothing);
      expect(find.text('Paketi yükselt'), findsNothing);

      await _pump(tester, _card(canManage: false, plan: _onStarter(members: 250)));
      expect(find.textContaining('üye limitine ulaştı'), findsOneWidget);
    });
  });

  group('plan screen', () {
    const screen = PlanScreen(groupId: 'g1', handle: 'doga', groupName: 'Doğa Yürüyüşçüleri', canManage: true);

    testWidgets('owner on the web compares plans in the server market', (tester) async {
      await _pump(tester, _app(screen, plan: _onStarter()));

      expect(tester.takeException(), isNull);
      expect(find.text('Mevcut paket'), findsWidgets);
      expect(_price('249 ₺'), findsOneWidget);
      expect(_price('699 ₺'), findsOneWidget);
      expect(find.text('Süreyi uzat'), findsOneWidget);
      expect(find.text('Yükselt'), findsOneWidget);
      expect(find.textContaining('yaklaşık 7,1 gün eklenir'), findsOneWidget);
      expect(find.textContaining('PayTR ile Türk lirası'), findsOneWidget);

      await tester.tap(find.text('Yıllık · 2 ay bedava'));
      await tester.pumpAndSettle();
      expect(_price('2.490 ₺'), findsOneWidget);
      expect(_price('6.990 ₺'), findsOneWidget);
    });

    testWidgets('mobile apps show the plan status and the other plans\' limits, without prices (Play rule)', (tester) async {
      await _pump(tester, _app(screen, plan: _onStarter(), web: false), size: const Size(390, 844));

      expect(find.text('Mevcut paket'), findsOneWidget);
      expect(find.text('12 / 250'), findsOneWidget);
      expect(find.text('Paketler'), findsOneWidget);
      expect(find.text('Pro'), findsOneWidget);
      expect(find.text('1.000 üye'), findsOneWidget);
      expect(find.textContaining('₺'), findsNothing);
      expect(find.textContaining('web'), findsNothing);
      expect(find.byType(GxButton), findsNothing);
    });

    testWidgets('a new group starts free: the web offers plans, mobile only their limits', (tester) async {
      const free = GroupPlan(plan: _free, memberCount: 1, paidUntil: null);
      var continued = 0;
      final step = PlanScreen(
        groupId: 'g1',
        handle: 'doga',
        groupName: 'Doğa Yürüyüşçüleri',
        canManage: true,
        onContinue: () => continued++,
      );

      await _pump(tester, _app(step, plan: free));
      expect(find.text('Grubun hazır'), findsOneWidget);
      expect(_price('249 ₺'), findsOneWidget);
      await tester.tap(find.text('Ücretsiz ile devam et'));
      expect(continued, 1);

      await _pump(tester, _app(step, plan: free, web: false, textScale: 1.3), size: const Size(390, 844));
      expect(tester.takeException(), isNull);
      expect(find.text('Grubun hazır'), findsOneWidget);
      expect(find.text('Başlangıç'), findsOneWidget);
      expect(find.textContaining('₺'), findsNothing);
      expect(find.textContaining('web'), findsNothing);
      await tester.tap(find.text('Gruba git'));
      expect(continued, 2);
    });

    testWidgets('phone layout survives 130% text', (tester) async {
      await _pump(tester, _app(screen, plan: _onStarter(members: 260), textScale: 1.3), size: const Size(390, 844));

      expect(tester.takeException(), isNull);
      expect(find.textContaining('limitini aşıyor'), findsOneWidget);
    });

    testWidgets('returning from the payment page waits for the verified result', (tester) async {
      var polls = 0;
      Order order() => Order(
            id: 'o1',
            status: ++polls < 3 ? OrderStatus.pending : OrderStatus.paid,
            planSlug: 'pro',
            period: PlanPeriod.month,
          );
      const returning = PlanScreen(groupId: 'g1', handle: 'doga', groupName: 'Doğa', canManage: true, orderId: 'o1');

      await tester.pumpWidget(_app(returning, plan: _onStarter(), order: order));
      await tester.pump();
      expect(find.textContaining('Ödemen onaylanıyor'), findsOneWidget);

      for (var i = 0; i < 3; i++) {
        await tester.pump(const Duration(seconds: 2));
      }
      await tester.pump();
      expect(find.text('Ödeme alındı. Paketin etkin.'), findsOneWidget);
    });
  });

  group('checkout', () {
    Widget checkout(_FakeBilling billing, List<Uri> opened) => _app(
          CheckoutScreen(
            groupId: 'g1',
            groupName: 'Doğa Yürüyüşçüleri',
            planSlug: 'pro',
            period: PlanPeriod.month,
            openPaymentPage: (url) async {
              opened.add(url);
              return true;
            },
          ),
          billing: billing,
        );

    Future<void> fill(WidgetTester tester) async {
      await tester.enterText(find.widgetWithText(TextFormField, 'Ad'), 'Ada');
      await tester.enterText(find.widgetWithText(TextFormField, 'Soyad'), 'Yılmaz');
      await tester.enterText(find.widgetWithText(TextFormField, 'Telefon'), '+90 555 000 00 00');
      await tester.enterText(find.widgetWithText(TextFormField, 'Adres'), 'Moda Cad. 1, Kadıköy');
      await tester.enterText(find.widgetWithText(TextFormField, 'Şehir'), 'İstanbul');
    }

    testWidgets('needs valid details and the accepted contract', (tester) async {
      final billing = _FakeBilling();
      await _pump(tester, checkout(billing, []));

      expect(find.textContaining('Ödeme onaylanınca'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Türkiye'), findsOneWidget);
      await tester.tap(find.text('Ödemeye geç · 699 ₺'));
      await tester.pumpAndSettle();

      expect(find.text('Ad gerekli.'), findsOneWidget);
      expect(find.text('Devam etmek için sözleşmeyi onaylamalısın.'), findsOneWidget);
      expect(billing.requests, isEmpty);
    });

    testWidgets('sends the order and opens the provider page', (tester) async {
      final billing = _FakeBilling();
      final opened = <Uri>[];
      await _pump(tester, checkout(billing, opened));

      await fill(tester);
      await tester.tap(find.byType(Checkbox));
      await tester.tap(find.text('Ödemeye geç · 699 ₺'));
      await tester.pump(const Duration(milliseconds: 100));

      final request = billing.requests.single;
      expect((request.planSlug, request.period, request.currency, request.salesTermsVersion), ('pro', PlanPeriod.month, 'TRY', 1));
      expect(request.details.lastName, 'Yılmaz');
      expect(request.details.country, 'Türkiye');
      expect(opened.single.host, 'www.paytr.com');
    });

    testWidgets('a changed market is explained without raw errors', (tester) async {
      final billing = _FakeBilling()
        ..checkoutResult = const Err(RuleFailure('billing.market_changed', 'Bulunduğun ülkeye göre fiyatlar değişti.'));
      await _pump(tester, checkout(billing, []));

      await fill(tester);
      await tester.tap(find.byType(Checkbox));
      await tester.tap(find.text('Ödemeye geç · 699 ₺'));
      await tester.pumpAndSettle();

      expect(find.text('Bulunduğun ülkeye göre fiyatlar değişti.'), findsOneWidget);
    });

    testWidgets('the contract opens from the checkbox label', (tester) async {
      await _pump(tester, checkout(_FakeBilling(), []));

      final label = find.textContaining("'ni okudum", findRichText: true);
      await tester.tapAt(tester.getTopLeft(label) + const Offset(8, 8));
      await tester.pumpAndSettle();

      expect(find.text('TASLAK metin.'), findsOneWidget);
    });
  });
}
