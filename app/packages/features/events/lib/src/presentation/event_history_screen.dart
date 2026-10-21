import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/events.dart';
import 'event_screens.dart';
import 'providers.dart';

/// A group's past events with their summaries, newest first (docs/ARCHITECTURE.md §3d, Organizasyon sonrası).
class EventHistoryScreen extends ConsumerStatefulWidget {
  const EventHistoryScreen({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<EventHistoryScreen> createState() => _EventHistoryScreenState();
}

class _EventHistoryScreenState extends ConsumerState<EventHistoryScreen> {
  final _events = <GroupEvent>[];
  bool _loading = true;
  bool _hasMore = true;
  Failure? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool refresh = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final before = refresh || _events.isEmpty ? null : _events.last.startsAt;
    final result = await ref.read(eventsRepositoryProvider).history(widget.groupId, before: before);
    if (!mounted) return;
    setState(() {
      _loading = false;
      switch (result) {
        case Ok(:final value):
          if (refresh) _events.clear();
          _events.addAll(value);
          _hasMore = value.length >= 20;
        case Err(:final failure):
          _error = failure;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Geçmiş organizasyonlar')),
      body: GxReadingColumn(
        child: switch ((_events.isEmpty, _loading, _error)) {
          (true, true, _) => const Padding(
              padding: EdgeInsets.all(GxSpacing.page),
              child: Column(children: [
                GxSkeleton(height: GxSpacing.xxl * 2, borderRadius: GxRadius.lgAll),
                SizedBox(height: GxSpacing.sm),
                GxSkeleton(height: GxSpacing.xxl * 2, borderRadius: GxRadius.lgAll),
              ]),
            ),
          (true, false, final Failure failure) => GxErrorState(message: failure.userMessage, onRetry: () => _load(refresh: true)),
          (true, false, null) => GxEmptyState(
              icon: Icons.history,
              message: 'Bu grubun henüz geçmiş bir organizasyonu yok.',
              actionLabel: 'Yenile',
              onAction: () => _load(refresh: true),
            ),
          _ => RefreshIndicator(
              onRefresh: () => _load(refresh: true),
              child: ListView(
                padding: const EdgeInsets.all(GxSpacing.page),
                children: [
                  for (final e in _events) ...[
                    EventCard(event: e),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(GxSpacing.sm, GxSpacing.xxs, GxSpacing.sm, GxSpacing.sm),
                      child: Text(e.isCanceled ? 'İptal edildi' : eventSummary(e),
                          style: textTheme.bodySmall?.copyWith(color: GxColors.textSecondary)),
                    ),
                  ],
                  if (_hasMore)
                    Center(
                      child: _loading
                          ? const Padding(padding: EdgeInsets.all(GxSpacing.md), child: CircularProgressIndicator())
                          : TextButton(onPressed: _load, child: const Text('Daha eski organizasyonlar')),
                    ),
                ],
              ),
            ),
        },
      ),
    );
  }
}
