import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/moderation.dart';
import 'case_sheet.dart';
import 'providers.dart';

/// Moderation screens open profiles and content through the app (features stay independent).
class ModerationLinks {
  const ModerationLinks({required this.openProfile, required this.openPost, required this.openEvent});

  final void Function(BuildContext context, String username) openProfile;
  final void Function(BuildContext context, String postId) openPost;
  final void Function(BuildContext context, String eventId) openEvent;
}

/// "2 gün 4 saat", "3 saat", "birkaç dakika".
String timeLeft(DateTime end, {DateTime? now}) {
  final left = end.difference(now ?? DateTime.now());
  if (left.inHours >= 24) {
    final hours = left.inHours % 24;
    return hours == 0 ? '${left.inDays} gün' : '${left.inDays} gün $hours saat';
  }
  return left.inHours >= 1 ? '${left.inHours} saat' : 'birkaç dakika';
}

void _snack(BuildContext context, String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

/// Asks for a short text (a reason or a note); null when canceled.
Future<String?> askText(
  BuildContext context, {
  required String title,
  required String label,
  required String confirm,
  int minLength = 3,
  int maxLength = 500,
}) => showDialog<String>(
  context: context,
  builder: (_) => _TextDialog(title: title, label: label, confirm: confirm, minLength: minLength, maxLength: maxLength),
);

class _TextDialog extends StatefulWidget {
  const _TextDialog({required this.title, required this.label, required this.confirm, required this.minLength, required this.maxLength});

  final String title;
  final String label;
  final String confirm;
  final int minLength;
  final int maxLength;

  @override
  State<_TextDialog> createState() => _TextDialogState();
}

class _TextDialogState extends State<_TextDialog> {
  final _controller = TextEditingController();
  final _form = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: Form(
      key: _form,
      child: TextFormField(
        controller: _controller,
        autofocus: true,
        maxLength: widget.maxLength,
        minLines: 1,
        maxLines: 4,
        decoration: InputDecoration(labelText: widget.label),
        validator: (v) => (v ?? '').trim().length < widget.minLength ? 'En az ${widget.minLength} karakter yaz.' : null,
      ),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Vazgeç')),
      FilledButton(
        onPressed: () {
          if (_form.currentState!.validate()) Navigator.of(context).pop(_controller.text.trim());
        },
        child: Text(widget.confirm),
      ),
    ],
  );
}

/// The group's moderation desk (docs/ARCHITECTURE.md §3e): reports, cases and sanctions.
class GroupModerationScreen extends ConsumerWidget {
  const GroupModerationScreen({super.key, required this.groupId, required this.groupName, required this.links});

  final String groupId;
  final String groupName;
  final ModerationLinks links;

  Future<void> _pickThreshold(BuildContext context, WidgetRef ref, CaseThreshold current) async {
    final picked = await showDialog<CaseThreshold>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Kurul karar eşiği'),
        children: [
          RadioGroup<CaseThreshold>(
            groupValue: current,
            onChanged: (t) => Navigator.of(context).pop(t),
            child: Column(
              children: [
                for (final t in CaseThreshold.values)
                  RadioListTile<CaseThreshold>(value: t, title: Text(t.label), subtitle: Text(t.description)),
              ],
            ),
          ),
        ],
      ),
    );
    if (picked == null || picked == current || !context.mounted) return;
    final result = await ref.read(moderationRepositoryProvider).setThreshold(groupId, picked);
    if (!context.mounted) return;
    ref.invalidate(groupModerationProvider(groupId));
    _snack(context, switch (result) {
      Ok() => 'Karar eşiği "${picked.label}" oldu. Yeni dosyalarda geçerli.',
      Err(:final failure) => failure.userMessage,
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final desk = ref.watch(groupModerationProvider(groupId));
    final data = desk.value;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Moderasyon · $groupName', overflow: TextOverflow.ellipsis),
          actions: [
            if (data != null && data.isOwner)
              IconButton(
                tooltip: 'Kurul karar eşiği',
                icon: const Icon(Icons.tune),
                onPressed: () => _pickThreshold(context, ref, data.threshold),
              ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: data == null || data.reports.isEmpty ? 'Şikayetler' : 'Şikayetler (${data.reports.length})'),
              Tab(text: data == null || data.awaitingMyVote == 0 ? 'Dosyalar' : 'Dosyalar (${data.awaitingMyVote})'),
              Tab(text: data == null || data.pendingAppeals.isEmpty ? 'Yaptırımlar' : 'Yaptırımlar (${data.pendingAppeals.length})'),
            ],
          ),
        ),
        body: switch (desk) {
          AsyncData(value: null) => GwEmptyState(
            icon: Icons.lock_outline,
            message: 'Bu grubun moderasyonunu yalnızca grup sahibi ve moderasyon ekibi görür.',
            actionLabel: 'Geri dön',
            onAction: () => Navigator.of(context).maybePop(),
          ),
          AsyncData(:final value?) => RefreshIndicator(
            onRefresh: () => ref.refresh(groupModerationProvider(groupId).future),
            child: TabBarView(
              children: [
                _ReportsTab(groupId: groupId, desk: value, links: links),
                _CasesTab(groupId: groupId, desk: value),
                _SanctionsTab(groupId: groupId, desk: value),
              ],
            ),
          ),
          AsyncError(:final error) => GwErrorState(
            message: userMessageOf(error),
            onRetry: () => ref.invalidate(groupModerationProvider(groupId)),
          ),
          _ => const _Loading(),
        },
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(GwSpacing.page),
    children: const [
      GwSkeleton(height: GwSpacing.xxl * 3),
      SizedBox(height: GwSpacing.md),
      GwSkeleton(height: GwSpacing.xxl * 3),
    ],
  );
}

/// A list that still pulls to refresh when it holds only the empty state.
class _TabList extends StatelessWidget {
  const _TabList({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.all(GwSpacing.page),
    children: [
      for (final (i, child) in children.indexed) ...[if (i > 0) const SizedBox(height: GwSpacing.sm), child],
    ],
  );
}

class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: GwColors.background,
      borderRadius: GwRadius.lgAll,
      border: Border.all(color: GwColors.border),
    ),
    child: Padding(
      padding: const EdgeInsets.all(GwSpacing.md),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    ),
  );
}

class _PersonRow extends StatelessWidget {
  const _PersonRow({required this.person, this.trailing, this.onTap});

  final ModerationPerson person;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: person.username.isEmpty ? null : onTap,
      borderRadius: GwRadius.smAll,
      child: Row(
        children: [
          GwAvatar(name: person.displayName, imageUrl: person.avatarUrl, shape: GwAvatarShape.user, size: GwAvatarSize.sm),
          const SizedBox(width: GwSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(person.displayName, style: textTheme.labelLarge, overflow: TextOverflow.ellipsis),
                if (person.username.isNotEmpty)
                  Text('@${person.username}', style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class _Quote extends StatelessWidget {
  const _Quote(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(GwSpacing.sm),
    decoration: const BoxDecoration(color: GwColors.surfaceMuted, borderRadius: GwRadius.mdAll),
    child: Text(text, maxLines: 6, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium),
  );
}

// Reports ------------------------------------------------------------------------------------

class _ReportsTab extends ConsumerWidget {
  const _ReportsTab({required this.groupId, required this.desk, required this.links});

  final String groupId;
  final GroupModeration desk;
  final ModerationLinks links;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (desk.reports.isEmpty) {
      return _TabList(
        children: [
          GwEmptyState(
            icon: Icons.verified_user_outlined,
            message: 'Açık şikayet yok. Üyelerin şikayetleri burada toplanır.',
            actionLabel: 'Yenile',
            onAction: () => ref.invalidate(groupModerationProvider(groupId)),
          ),
        ],
      );
    }
    return _TabList(
      children: [for (final r in desk.reports) _ReportCard(groupId: groupId, report: r, desk: desk, links: links)],
    );
  }
}

class _ReportCard extends ConsumerStatefulWidget {
  const _ReportCard({required this.groupId, required this.report, required this.desk, required this.links});

  final String groupId;
  final GroupReport report;
  final GroupModeration desk;
  final ModerationLinks links;

  @override
  ConsumerState<_ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends ConsumerState<_ReportCard> {
  bool _busy = false;

  Future<void> _act(Future<Result<void>> Function() action, String done) async {
    setState(() => _busy = true);
    final result = await action();
    if (!mounted) return;
    setState(() => _busy = false);
    _snack(context, switch (result) {
      Ok() => done,
      Err(:final failure) => failure.userMessage,
    });
    if (result is Ok) ref.invalidate(groupModerationProvider(widget.groupId));
  }

  Future<void> _remove() async {
    final reason = await askText(context, title: 'İçeriği kaldır', label: 'Gerekçe', confirm: 'Kaldır');
    if (reason == null) return;
    await _act(() => ref.read(moderationRepositoryProvider).removeContent(widget.report.id, reason: reason), 'İçerik kaldırıldı.');
  }

  void _open() {
    final r = widget.report;
    switch (r.targetType) {
      case 'post':
        widget.links.openPost(context, r.targetId);
      case 'comment' when r.postId != null:
        widget.links.openPost(context, r.postId!);
      case 'event':
        widget.links.openEvent(context, r.targetId);
      case 'user' when r.subject != null:
        widget.links.openProfile(context, r.subject!.username);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.report;
    final textTheme = Theme.of(context).textTheme;
    final outranks = r.subject != null && widget.desk.rank > r.subject!.rank;
    final canOpen = r.targetType != 'live_comment' && r.targetType != 'message' && (r.targetType != 'comment' || r.postId != null);
    return _Card(
      children: [
        Row(
          children: [
            GwBadge(r.targetLabel, tone: GwBadgeTone.info),
            const SizedBox(width: GwSpacing.xs),
            GwBadge(r.count == 1 ? '1 şikayet' : '${r.count} şikayet', tone: r.count > 2 ? GwBadgeTone.danger : GwBadgeTone.warning),
            const Spacer(),
            Text(formatDateTimeTr(r.lastAt), style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary)),
          ],
        ),
        if (r.subject case final subject?) ...[
          const SizedBox(height: GwSpacing.sm),
          _PersonRow(person: subject, onTap: () => widget.links.openProfile(context, subject.username)),
        ],
        if (r.excerpt.isNotEmpty) ...[const SizedBox(height: GwSpacing.sm), _Quote(r.excerpt)],
        const SizedBox(height: GwSpacing.sm),
        Wrap(spacing: GwSpacing.xs, runSpacing: GwSpacing.xs, children: [for (final reason in r.reasons) GwBadge(reason.label)]),
        for (final note in r.notes.take(3)) ...[
          const SizedBox(height: GwSpacing.xs),
          Text(
            '“$note”',
            style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary, fontStyle: FontStyle.italic),
          ),
        ],
        const SizedBox(height: GwSpacing.sm),
        Wrap(
          spacing: GwSpacing.xs,
          runSpacing: GwSpacing.xs,
          children: [
            if (canOpen) TextButton(onPressed: _open, child: const Text('Görüntüle')),
            TextButton(
              onPressed: _busy ? null : () => _act(() => ref.read(moderationRepositoryProvider).dismiss(r.id), 'Şikayet reddedildi.'),
              child: const Text('Reddet'),
            ),
            if (r.removable && outranks)
              GwButton(
                label: 'İçeriği kaldır',
                icon: Icons.delete_outline,
                variant: GwButtonVariant.secondary,
                onPressed: _busy ? null : _remove,
              ),
            if (outranks)
              GwButton(
                label: 'Dosya aç',
                icon: Icons.gavel_outlined,
                onPressed: _busy
                    ? null
                    : () => showCaseSheet(
                        context,
                        groupId: widget.groupId,
                        subjectId: r.subject!.id,
                        subjectName: r.subject!.displayName,
                        canMute: widget.desk.canMute,
                        canBan: widget.desk.canBan,
                        reportId: r.id,
                      ),
              ),
          ],
        ),
        if (r.subject != null && !outranks)
          Text(
            'Bu kişinin rütbesi seninkinden düşük olmadığı için yalnızca reddedebilirsin.',
            style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary),
          ),
      ],
    );
  }
}

// Cases --------------------------------------------------------------------------------------

class _CasesTab extends ConsumerWidget {
  const _CasesTab({required this.groupId, required this.desk});

  final String groupId;
  final GroupModeration desk;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (desk.cases.isEmpty) {
      return _TabList(
        children: [
          GwEmptyState(
            icon: Icons.gavel_outlined,
            message: 'Henüz disiplin dosyası yok. Dosyalar bir şikayetten ya da üyeler sayfasından açılır.',
            actionLabel: 'Yenile',
            onAction: () => ref.invalidate(groupModerationProvider(groupId)),
          ),
        ],
      );
    }
    return _TabList(
      children: [for (final c in desk.cases) CaseCard(groupId: groupId, item: c)],
    );
  }
}

/// A case with its vote counts; voters vote here while it is open.
class CaseCard extends ConsumerStatefulWidget {
  const CaseCard({super.key, required this.groupId, required this.item});

  final String groupId;
  final ModerationCase item;

  @override
  ConsumerState<CaseCard> createState() => _CaseCardState();
}

class _CaseCardState extends ConsumerState<CaseCard> {
  bool _busy = false;

  Future<void> _vote(bool approve) async {
    setState(() => _busy = true);
    final result = await ref.read(moderationRepositoryProvider).vote(widget.item.id, approve: approve);
    if (!mounted) return;
    setState(() => _busy = false);
    _snack(context, switch (result) {
      Ok(value: CaseStatus.approved) => 'Oyun kaydedildi. Kurul yaptırımı onayladı; yaptırım uygulandı.',
      Ok(value: CaseStatus.rejected) => 'Oyun kaydedildi. Kurul yaptırımı reddetti.',
      Ok() => 'Oyun kaydedildi. Karar çıkana kadar değiştirebilirsin.',
      Err(:final failure) => failure.userMessage,
    });
    ref.invalidate(groupModerationProvider(widget.groupId));
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.item;
    final textTheme = Theme.of(context).textTheme;
    final secondary = textTheme.bodySmall?.copyWith(color: GwColors.textSecondary);
    final (statusLabel, tone) = switch (c.status) {
      CaseStatus.voting => ('Oylamada', GwBadgeTone.info),
      CaseStatus.approved => ('Onaylandı', GwBadgeTone.danger),
      CaseStatus.rejected => ('Reddedildi', GwBadgeTone.neutral),
    };
    return _Card(
      children: [
        _PersonRow(
          person: c.subject,
          trailing: GwBadge(statusLabel, tone: tone, dot: c.isOpen),
        ),
        const SizedBox(height: GwSpacing.sm),
        Text(c.direct ? c.proposal : 'Önerilen: ${c.proposal}', style: textTheme.titleSmall),
        if (c.direct) ...[
          const SizedBox(height: GwSpacing.xxs),
          const GwBadge('Oylamasız ban', tone: GwBadgeTone.warning),
        ],
        if (c.illegalCategory case final illegal?) ...[
          const SizedBox(height: GwSpacing.xxs),
          GwBadge('Yasa dışı faaliyet: ${illegal.label}', tone: GwBadgeTone.danger),
        ],
        const SizedBox(height: GwSpacing.xxs),
        Text(c.reason, style: textTheme.bodyMedium),
        const SizedBox(height: GwSpacing.xs),
        Text(
          [
            if (!c.direct) ...['${c.approvals} onay · ${c.rejections} ret · ${c.voters} oy hakkı', c.threshold.label],
            if (c.isOpen) 'Oylama ${timeLeft(c.votingEndsAt)} sonra biter' else if (c.decidedAt != null) formatDateTimeTr(c.decidedAt!),
          ].join(' · '),
          style: secondary,
        ),
        if (c.openedBy case final opener?) Text('${c.direct ? 'Banlayan' : 'Dosyayı açan'}: ${opener.displayName}', style: secondary),

        if (c.isOpen && c.isVoter) ...[
          const SizedBox(height: GwSpacing.sm),
          if (c.myVote != null) Text(c.myVote! ? 'Oyun: Onay' : 'Oyun: Ret', style: textTheme.labelLarge),
          const SizedBox(height: GwSpacing.xs),
          Row(
            children: [
              Expanded(
                child: GwButton(
                  label: 'Onayla',
                  icon: Icons.check,
                  variant: c.myVote == true ? GwButtonVariant.primary : GwButtonVariant.secondary,
                  onPressed: _busy || c.myVote == true ? null : () => _vote(true),
                ),
              ),
              const SizedBox(width: GwSpacing.xs),
              Expanded(
                child: GwButton(
                  label: 'Reddet',
                  icon: Icons.close,
                  variant: c.myVote == false ? GwButtonVariant.primary : GwButtonVariant.secondary,
                  onPressed: _busy || c.myVote == false ? null : () => _vote(false),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// Sanctions and appeals ---------------------------------------------------------------------

class _SanctionsTab extends ConsumerWidget {
  const _SanctionsTab({required this.groupId, required this.desk});

  final String groupId;
  final GroupModeration desk;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (desk.sanctions.isEmpty) {
      return _TabList(
        children: [
          GwEmptyState(
            icon: Icons.shield_outlined,
            message: 'Henüz yaptırım yok. Kurulun onayladığı yaptırımlar ve itirazlar burada görünür.',
            actionLabel: 'Yenile',
            onAction: () => ref.invalidate(groupModerationProvider(groupId)),
          ),
        ],
      );
    }
    final pending = desk.pendingAppeals;
    return _TabList(
      children: [
        for (final s in [...pending, ...desk.sanctions.where((s) => !pending.contains(s))])
          _SanctionCard(groupId: groupId, sanction: s, desk: desk),
      ],
    );
  }
}

class _SanctionCard extends ConsumerStatefulWidget {
  const _SanctionCard({required this.groupId, required this.sanction, required this.desk});

  final String groupId;
  final GroupSanction sanction;
  final GroupModeration desk;

  @override
  ConsumerState<_SanctionCard> createState() => _SanctionCardState();
}

class _SanctionCardState extends ConsumerState<_SanctionCard> {
  bool _busy = false;

  Future<void> _decide(Appeal appeal, {required bool overturn}) async {
    final note = await askText(
      context,
      title: overturn ? 'Yaptırımı kaldır' : 'Yaptırım sürsün',
      label: 'Kişiye notun (isteğe bağlı)',
      confirm: overturn ? 'Kaldır' : 'Onayla',
      minLength: 0,
    );
    if (note == null || !mounted) return;
    setState(() => _busy = true);
    final result = await ref
        .read(moderationRepositoryProvider)
        .decideAppeal(appeal.id, overturn: overturn, note: note.isEmpty ? null : note);
    if (!mounted) return;
    setState(() => _busy = false);
    _snack(context, switch (result) {
      Ok() => overturn ? 'Yaptırım kaldırıldı; kişiye bildirildi.' : 'İtiraz reddedildi; kişiye bildirildi.',
      Err(:final failure) => failure.userMessage,
    });
    ref.invalidate(groupModerationProvider(widget.groupId));
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.sanction;
    final textTheme = Theme.of(context).textTheme;
    final secondary = textTheme.bodySmall?.copyWith(color: GwColors.textSecondary);
    final appeal = s.appeal;
    final (status, tone) = s.liftedAt != null
        ? ('Kaldırıldı', GwBadgeTone.neutral)
        : s.isRunning
        ? (s.interim ? 'Acil susturma' : 'Sürüyor', GwBadgeTone.danger)
        : ('Uygulandı', GwBadgeTone.neutral);
    return _Card(
      children: [
        _PersonRow(
          person: s.user,
          trailing: GwBadge(status, tone: tone),
        ),
        const SizedBox(height: GwSpacing.sm),
        Text(
          s.interim
              ? 'Acil susturma · kurul kararına kadar'
              : s.type == SanctionType.mute || s.type == SanctionType.ban
              ? '${s.type.label} · ${s.endsAt == null ? 'kalıcı' : '${formatDateTimeTr(s.endsAt!)} tarihine kadar'}'
              : s.type.label,
          style: textTheme.titleSmall,
        ),
        if (s.reason.isNotEmpty) ...[const SizedBox(height: GwSpacing.xxs), Text(s.reason, style: textTheme.bodyMedium)],
        Text(formatDateTimeTr(s.startsAt), style: secondary),
        if (appeal != null) ...[
          const SizedBox(height: GwSpacing.sm),
          Text('İtiraz · ${appeal.status.label}', style: textTheme.labelLarge),
          const SizedBox(height: GwSpacing.xxs),
          _Quote(appeal.body),
          if (appeal.decisionNote case final note?) ...[const SizedBox(height: GwSpacing.xxs), Text('Not: $note', style: secondary)],
          if (appeal.status == AppealStatus.pending && appeal.byPlatform)
            Padding(
              padding: const EdgeInsets.only(top: GwSpacing.xs),
              child: Text('Sahip bu dosyada taraf olduğu için itirazı platform ekibi inceliyor.', style: secondary),
            ),
          if (widget.desk.pendingAppeals.contains(s)) ...[
            const SizedBox(height: GwSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: GwButton(
                    label: 'Yaptırımı kaldır',
                    variant: GwButtonVariant.secondary,
                    onPressed: _busy ? null : () => _decide(appeal, overturn: true),
                  ),
                ),
                const SizedBox(width: GwSpacing.xs),
                Expanded(
                  child: GwButton(label: 'Sürsün', onPressed: _busy ? null : () => _decide(appeal, overturn: false)),
                ),
              ],
            ),
          ],
        ],
      ],
    );
  }
}
