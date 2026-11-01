import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/billing_repository_impl.dart';
import '../domain/billing.dart';

final billingRepositoryProvider = Provider<BillingRepository>(
  (ref) => BillingRepositoryImpl(ref.watch(supabaseClientProvider), ref.watch(apiClientProvider)),
);

/// Plans are bought on the web only; the mobile apps show the plan status
/// (App Store and Google Play payment rules, docs/ARCHITECTURE.md §7).
final purchasesOnThisPlatformProvider = Provider<bool>((ref) => kIsWeb);

final plansProvider = FutureProvider.autoDispose<List<Plan>>(
  (ref) async {
    ref.cacheFor();
    return (await ref.watch(billingRepositoryProvider).plans()).getOrThrow();
  },
);

final groupPlanProvider = FutureProvider.autoDispose.family<GroupPlan?, String>(
  (ref, groupId) async {
    ref.cacheFor();
    return (await ref.watch(billingRepositoryProvider).groupPlan(groupId)).getOrThrow();
  },
);

final planTimelineProvider = FutureProvider.autoDispose.family<List<PlanSlice>, String>(
  (ref, groupId) async {
    ref.cacheFor();
    return (await ref.watch(billingRepositoryProvider).timeline(groupId)).getOrThrow();
  },
);

final offerProvider = FutureProvider.autoDispose.family<Offer, String>(
  (ref, groupId) async => (await ref.watch(billingRepositoryProvider).offer(groupId)).getOrThrow(),
);

final salesTermsProvider = FutureProvider.autoDispose<SalesTerms>(
  (ref) async {
    ref.cacheFor();
    return (await ref.watch(billingRepositoryProvider).salesTerms()).getOrThrow();
  },
);

final lastBillingDetailsProvider = FutureProvider.autoDispose<BillingDetails?>(
  (ref) async => (await ref.watch(billingRepositoryProvider).lastBillingDetails()).getOrThrow(),
);

final personalOfferProvider = FutureProvider.autoDispose.family<PersonalOffer, String>(
  (ref, slug) async => (await ref.watch(billingRepositoryProvider).personalOffer(slug)).getOrThrow(),
);

final orderProvider = FutureProvider.autoDispose.family<Order, String>(
  (ref, orderId) async => (await ref.watch(billingRepositoryProvider).order(orderId)).getOrThrow(),
);

/// Reloads everything that shows the group's plan, e.g. after a payment settled.
void refreshGroupPlan(WidgetRef ref, String groupId) {
  ref
    ..invalidate(groupPlanProvider(groupId))
    ..invalidate(planTimelineProvider(groupId))
    ..invalidate(offerProvider(groupId));
}
