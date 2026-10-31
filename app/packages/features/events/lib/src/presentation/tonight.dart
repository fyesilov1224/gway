import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/events.dart';
import '../domain/tonight.dart';
import 'providers.dart';
import 'routes.dart';

/// Opens a conversation (the messaging feature lives in the app).
typedef OpenTonightChat = void Function(BuildContext context, String conversationId);

/// "Bu akşam" on Bugün: say you are free, see how many are, set up or answer a small table
/// (docs/ARCHITECTURE.md §3d, Bu akşam boşum ve küçük masa).
class TonightCard extends ConsumerStatefulWidget {
  const TonightCard({super.key, required this.openChat, this.showPeopleLink = true});

  final OpenTonightChat openChat;

  /// Off on the "Bu akşam" page itself, which lists the people below.
  final bool showPeopleLink;

  @override
  ConsumerState<TonightCard> createState() => _TonightCardState();
}

class _TonightCardState extends ConsumerState<TonightCard> {
  bool _busy = false;

  Future<void> _run(Future<Result<Object?>> Function(EventsRepository repo) action, String Function(Object? value) done) async {
    setState(() => _busy = true);
    final result = await action(ref.read(eventsRepositoryProvider));
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(switch (result) {
        Ok(:final value) => done(value),
        Err(:final failure) => failure.userMessage,
      }),
    ));
    ref
      ..invalidate(tonightProvider)
      ..invalidate(tonightPeopleProvider);
  }

  Future<void> _setFree() async {
    final note = await showDialog<String>(context: context, builder: (_) => const _FreeDialog());
    if (note == null) return;
    await _run((r) => r.setFree(note), (_) => 'Bu akşam boş olduğunu ortak gruplarındakiler görecek. 04:00\'te kendiliğinden kapanır.');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tonight = ref.watch(tonightProvider);
    final t = tonight.value;
    if (t == null) {
      return tonight.isLoading
          ? const Padding(
              padding: EdgeInsets.symmetric(horizontal: GwSpacing.page, vertical: GwSpacing.sm),
              child: GwSkeleton(height: GwSpacing.xxl * 2, borderRadius: GwRadius.lgAll),
            )
          : const SizedBox.shrink();
    }
    final secondary = textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GwSpacing.page, vertical: GwSpacing.sm),
      child: GwCard(
        radius: GwRadius.lgAll,
        padding: const EdgeInsets.all(GwSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.nights_stay_outlined, color: GwColors.primary),
                const SizedBox(width: GwSpacing.xs),
                Expanded(child: Text('Bu akşam', style: textTheme.titleMedium)),
                if (t.isFree && t.table == null)
                  TextButton(
                    onPressed: _busy ? null : () => _run((r) => r.clearFree(), (_) => 'Artık boş görünmüyorsun.'),
                    child: const Text('Kapat'),
                  ),
              ],
            ),
            const SizedBox(height: GwSpacing.xs),
            if (!t.isFree) ...[
              Text('Boşsan ortak gruplarındakiler görsün; birlikte küçük bir masa kurabilirsiniz.', style: secondary),
              const SizedBox(height: GwSpacing.sm),
              GwButton(label: 'Bu akşam boşum', icon: Icons.local_cafe_outlined, isLoading: _busy, expand: true, onPressed: _setFree),
            ] else
              Text(
                t.note == null || t.note!.isEmpty ? 'Boşsun; 04:00\'e kadar görünürsün.' : '"${t.note}" · 04:00\'e kadar görünürsün.',
                style: secondary,
              ),
            _FreePeople(showLink: widget.showPeopleLink),
            if (t.table case final table?)
              _TableBlock(
                table: table,
                busy: _busy,
                onOpenChat: (id) => widget.openChat(context, id),
                onLeave: () => _run((r) => r.leaveTable(table.id), (_) => 'Masadan ayrıldın.'),
              )
            else if (t.canSetTable) ...[
              const SizedBox(height: GwSpacing.sm),
              GwButton(
                label: 'Küçük masa kur',
                icon: Icons.table_restaurant_outlined,
                variant: GwButtonVariant.secondary,
                isLoading: _busy,
                expand: true,
                onPressed: () => _run(
                  (r) => r.createTable(),
                  (n) => '$n kişiye davet gönderildi. Üç kişi olunca masanın sohbeti açılır.',
                ),
              ),
            ] else if (t.isFree) ...[
              const SizedBox(height: GwSpacing.sm),
              Text(
                'Küçük masa için ortak gruplarından en az ${Tonight.minCandidates} kişinin daha boş olması gerekiyor '
                '(şu an ${t.candidates}). Biri boş olduğunu söyleyince burada masa kurabilirsin.',
                style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary),
              ),
            ],
            for (final invite in t.invites)
              _InviteBlock(
                invite: invite,
                busy: _busy,
                onAnswer: (accept) => _run(
                  (r) => r.answerTable(invite.id, accept: accept),
                  (_) => accept ? 'Masaya katıldın.' : 'Daveti geri çevirdin.',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Who else is free tonight among the people sharing a group: faces and a count, a link to the list.
class _FreePeople extends ConsumerWidget {
  const _FreePeople({required this.showLink});

  static const _faces = 5;

  final bool showLink;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final people = ref.watch(tonightPeopleProvider).value;
    if (people == null || people.isEmpty) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: GwSpacing.sm),
      child: InkWell(
        borderRadius: GwRadius.mdAll,
        onTap: showLink ? () => context.push(EventRoutes.tonight) : null,
        child: Row(
          children: [
            _Faces(people: people.take(_faces).toList()),
            const SizedBox(width: GwSpacing.sm),
            Expanded(
              child: Text(
                'Ortak gruplarından ${formatCount(people.length)} kişi bu akşam boş',
                style: textTheme.labelLarge?.copyWith(color: GwColors.primary),
              ),
            ),
            if (showLink) const Icon(Icons.chevron_right, color: GwColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

/// The note when saying "boşum"; null when cancelled.
class _FreeDialog extends StatefulWidget {
  const _FreeDialog();

  @override
  State<_FreeDialog> createState() => _FreeDialogState();
}

class _FreeDialogState extends State<_FreeDialog> {
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: GwRadius.xlAll),
        title: const Text('Bu akşam boşum'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Yalnızca ortak gruplarındaki kişiler görür. Durumun 04:00\'te kendiliğinden kapanır.'),
            const SizedBox(height: GwSpacing.sm),
            TextField(
              controller: _note,
              maxLength: 80,
              decoration: const InputDecoration(labelText: 'Ne yapmak istersin? (isteğe bağlı)', hintText: 'ör. kahve, kısa yürüyüş'),
            ),
          ],
        ),
        actions: [
          GwButton(label: 'Vazgeç', variant: GwButtonVariant.text, onPressed: () => Navigator.of(context).pop()),
          GwButton(label: 'Boşum', onPressed: () => Navigator.of(context).pop(_note.text.trim())),
        ],
      );
}

class _Faces extends StatelessWidget {
  const _Faces({required this.people});

  final List<TonightPerson> people;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: GwSpacing.xs,
        runSpacing: GwSpacing.xs,
        children: [
          for (final p in people)
            Tooltip(
              message: p.displayName,
              child: GwAvatar(name: p.displayName, imageUrl: p.avatarUrl, shape: GwAvatarShape.user, size: GwAvatarSize.sm),
            ),
        ],
      );
}

class _TableBlock extends StatelessWidget {
  const _TableBlock({required this.table, required this.busy, required this.onOpenChat, required this.onLeave});

  final TonightTable table;
  final bool busy;
  final ValueChanged<String> onOpenChat;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final chat = table.conversationId;
    return Padding(
      padding: const EdgeInsets.only(top: GwSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Masan', style: textTheme.titleSmall),
          const SizedBox(height: GwSpacing.xs),
          _Faces(people: table.joined),
          const SizedBox(height: GwSpacing.xs),
          Text(
            [
              '${table.joined.length} kişi katıldı',
              if (table.pending > 0) '${table.pending} kişi bekleniyor',
            ].join(' · '),
            style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary),
          ),
          const SizedBox(height: GwSpacing.sm),
          if (chat != null)
            GwButton(label: 'Masanın sohbeti', icon: Icons.forum_outlined, expand: true, onPressed: () => onOpenChat(chat))
          else
            Text('Sohbet, ${table.missing} kişi daha katılınca açılır. Yeri ve saati orada birlikte seçersiniz.',
                style: textTheme.bodyMedium),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(onPressed: busy ? null : onLeave, child: const Text('Masadan ayrıl')),
          ),
        ],
      ),
    );
  }
}

class _InviteBlock extends StatelessWidget {
  const _InviteBlock({required this.invite, required this.busy, required this.onAnswer});

  final TonightTable invite;
  final bool busy;
  final ValueChanged<bool> onAnswer;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(top: GwSpacing.sm),
      padding: const EdgeInsets.all(GwSpacing.sm),
      decoration: const BoxDecoration(color: GwColors.primarySoft, borderRadius: GwRadius.mdAll),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${invite.founder.displayName} küçük bir masa kurdu ve seni de çağırıyor.', style: textTheme.bodyLarge),
          const SizedBox(height: GwSpacing.xxs),
          Text(
            '${invite.joined.length} kişi katıldı · ${invite.pending} kişi bekleniyor. Üç kişi olunca sohbet açılır.',
            style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary),
          ),
          const SizedBox(height: GwSpacing.sm),
          Wrap(
            spacing: GwSpacing.xs,
            runSpacing: GwSpacing.xs,
            children: [
              GwButton(label: 'Katıl', icon: Icons.check, isLoading: busy, onPressed: () => onAnswer(true)),
              GwButton(label: 'Bu akşam olmaz', variant: GwButtonVariant.secondary, onPressed: busy ? null : () => onAnswer(false)),
            ],
          ),
        ],
      ),
    );
  }
}

/// "Bu akşam": the card and the people free tonight who share a group with the user.
class TonightScreen extends ConsumerWidget {
  const TonightScreen({super.key, required this.openChat, required this.openProfile});

  final OpenTonightChat openChat;
  final void Function(BuildContext context, String username) openProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final people = ref.watch(tonightPeopleProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bu akşam')),
      body: GwReadingColumn(
        child: RefreshIndicator(
          onRefresh: () async => ref
            ..invalidate(tonightProvider)
            ..invalidate(tonightPeopleProvider),
          child: ListView(
            padding: const EdgeInsets.only(bottom: GwSpacing.xl),
            children: [
              TonightCard(openChat: openChat, showPeopleLink: false),
              const GwSectionHeader(title: 'Bu akşam boş olanlar', subtitle: 'Yalnızca ortak gruplarındaki kişiler'),
              switch (people) {
                AsyncData(:final value) when value.isEmpty => Padding(
                    padding: const EdgeInsets.all(GwSpacing.page),
                    child: GwEmptyState(
                      icon: Icons.nights_stay_outlined,
                      message: 'Ortak gruplarından şu an boş olan yok.',
                      actionLabel: 'Yenile',
                      onAction: () => ref.invalidate(tonightPeopleProvider),
                    ),
                  ),
                AsyncData(:final value) => Column(
                    children: [
                      for (final p in value)
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: GwSpacing.page),
                          leading: GwAvatar(name: p.displayName, imageUrl: p.avatarUrl, shape: GwAvatarShape.user),
                          title: Text(p.displayName, style: textTheme.titleSmall),
                          subtitle: Text(
                            [if (p.note.isNotEmpty) '"${p.note}"', p.groups.join(', ')].join(' · '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => openProfile(context, p.username),
                        ),
                    ],
                  ),
                AsyncError(:final error) => Padding(
                    padding: const EdgeInsets.all(GwSpacing.page),
                    child: GwErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(tonightPeopleProvider)),
                  ),
                _ => const Padding(
                    padding: EdgeInsets.all(GwSpacing.page),
                    child: GwSkeleton(height: GwSpacing.xxl * 3, borderRadius: GwRadius.lgAll),
                  ),
              },
            ],
          ),
        ),
      ),
    );
  }
}
