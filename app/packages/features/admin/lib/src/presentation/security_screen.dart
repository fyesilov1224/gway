import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/admin_security.dart';
import '../domain/admin_user.dart';
import 'admin_shell.dart';
import 'providers.dart';
import 'routes.dart';
import 'suspend_dialog.dart';
import 'widgets.dart';

/// Security verification (docs/ARCHITECTURE.md §3h): the enforcement switch (admin) and the reviews of
/// restricted accounts (admin, moderator).
class AdminSecurityScreen extends ConsumerStatefulWidget {
  const AdminSecurityScreen({super.key});

  @override
  ConsumerState<AdminSecurityScreen> createState() => _AdminSecurityScreenState();
}

class _AdminSecurityScreenState extends ConsumerState<AdminSecurityScreen> {
  AdminReviewStatus? _status = AdminReviewStatus.open;

  void _refresh() => ref
    ..invalidate(securityReviewsProvider)
    ..invalidate(securitySettingsProvider);

  void _done(Result<void> result, String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(switch (result) { Ok() => message, Err(:final failure) => failure.userMessage }),
    ));
    ref.invalidate(securityReviewsProvider);
  }

  Future<void> _approve(AdminSecurityReview r) async {
    final request = await showDialog<({int days, String note})>(context: context, builder: (_) => const _ApproveDialog());
    if (request == null || !mounted) return;
    final result = await ref
        .read(adminSecurityRepositoryProvider)
        .approve(r.id, exemptDays: request.days, note: request.note.isEmpty ? null : request.note);
    _done(result, 'Kısıtlama kaldırıldı.');
  }

  Future<void> _ban(AdminSecurityReview r) async {
    final request = await showSuspendDialog(
      context,
      title: 'Hesabı banla',
      description: 'Hesap kalıcı olarak kapanır ve doğrulanmış numarası bir daha kullanılamaz. Gerekçe kayda geçer.',
      withDuration: false,
      confirmLabel: 'Banla',
    );
    if (request == null || !mounted) return;
    final result = await ref.read(adminSecurityRepositoryProvider).ban(r.id, note: request.reason);
    _done(result, 'Hesap banlandı.');
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(myStaffRoleProvider).value;
    final reviews = ref.watch(securityReviewsProvider(_status));
    return AdminPage(
      title: 'Güvenlik',
      subtitle: 'Konum, telefon ve iki adımlı doğrulama. Kesin sinyaller (sahte konum, başka ülkenin numarası) hesabı '
          'otomatik kapatır; belirsiz sinyaller (VPN, ülke uyuşmazlığı) hesabı kısıtlar ve buraya düşer.',
      actions: [GxButton(label: 'Yenile', icon: Icons.refresh, variant: GxButtonVariant.secondary, onPressed: _refresh)],
      children: [
        if (role == StaffRole.admin) ...[const _SettingsPanel(), const SizedBox(height: GxSpacing.lg)],
        Wrap(
          spacing: GxSpacing.xs,
          runSpacing: GxSpacing.xs,
          children: [
            ChoiceChip(label: const Text('Tümü'), selected: _status == null, onSelected: (_) => setState(() => _status = null)),
            for (final s in AdminReviewStatus.values)
              ChoiceChip(label: Text(s.label), selected: _status == s, onSelected: (_) => setState(() => _status = s)),
          ],
        ),
        const SizedBox(height: GxSpacing.md),
        switch (reviews) {
          AsyncData(value: []) => GxPanel(
              child: GxEmptyState(
                icon: Icons.verified_user_outlined,
                message: 'Bu durumda inceleme yok.',
                actionLabel: 'Tüm incelemeleri göster',
                onAction: () => setState(() => _status = null),
              ),
            ),
          AsyncData(:final value) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final r in value) ...[
                  _ReviewCard(
                    review: r,
                    canAct: role?.canSuspend ?? false,
                    onApprove: () => _approve(r),
                    onBan: () => _ban(r),
                  ),
                  const SizedBox(height: GxSpacing.md),
                ],
              ],
            ),
          AsyncError(:final error) => GxPanel(child: GxErrorState(message: userMessageOf(error), onRetry: _refresh)),
          _ => const GxSkeleton(height: GxSpacing.xxl * 3, borderRadius: GxRadius.lgAll),
        },
      ],
    );
  }
}

class _SettingsPanel extends ConsumerStatefulWidget {
  const _SettingsPanel();

  @override
  ConsumerState<_SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends ConsumerState<_SettingsPanel> {
  bool _saving = false;

  Future<void> _toggle(bool enforce) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: GxRadius.xlAll),
        title: Text(enforce ? 'Doğrulamayı zorunlu yap' : 'Doğrulamayı kapat'),
        content: Text(enforce
            ? 'Herkes (platform ekibi dahil) en geç bir saat içinde konum, telefon ve giriş doğrulamasından geçmeden '
                'uygulamayı kullanamaz.'
            : 'Konum ve telefon doğrulaması istenmez; kısıtlı hesaplar da uygulamaya girebilir.'),
        actions: [
          GxButton(label: 'Vazgeç', variant: GxButtonVariant.text, onPressed: () => Navigator.of(dialog).pop(false)),
          GxButton(label: enforce ? 'Zorunlu yap' : 'Kapat', onPressed: () => Navigator.of(dialog).pop(true)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _saving = true);
    await _save(() => ref.read(adminSecurityRepositoryProvider).updateSettings(enforce: enforce));
  }

  Future<void> _save(Future<Result<AdminSecuritySettings>> Function() update) async {
    setState(() => _saving = true);
    final result = await update();
    if (!mounted) return;
    setState(() => _saving = false);
    if (result case Err(:final failure)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.userMessage)));
    }
    ref.invalidate(securitySettingsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(securitySettingsProvider);
    return GxPanel(
      title: 'Doğrulama zorunluluğu',
      child: switch (settings) {
        AsyncData(:final value) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: value.enforce,
                title: const Text('Konum, telefon ve giriş doğrulaması zorunlu'),
                subtitle: Text('Son değişiklik: ${formatDateTimeTr(value.updatedAt)}'),
                onChanged: _saving ? null : _toggle,
              ),
              const Divider(),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: value.detectVpn,
                title: const Text('VPN tespiti'),
                subtitle: const Text('Çalışan VPN ya da konum ve IP ülkesi uyuşmazlığı hesabı kısıtlar.'),
                onChanged: _saving
                    ? null
                    : (v) => _save(() => ref.read(adminSecurityRepositoryProvider).updateSettings(detectVpn: v)),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: value.warnInstalledVpn,
                title: const Text('Yüklü VPN uygulaması uyarısı'),
                subtitle: const Text('Telefonda (Android) yüklü bir VPN uygulaması varsa kullanıcı uyarı mesajı görür.'),
                onChanged: _saving
                    ? null
                    : (v) => _save(() => ref.read(adminSecurityRepositoryProvider).updateSettings(warnInstalledVpn: v)),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: value.detectPhoneMismatch,
                title: const Text('Farklı numara ve SIM tespiti'),
                subtitle: const Text('Başka ülkenin SIM kartı ya da kayıtlı numaranın ülkesi uyuşmazsa hesap kısıtlanır.'),
                onChanged: _saving
                    ? null
                    : (v) => _save(() => ref.read(adminSecurityRepositoryProvider).updateSettings(detectPhoneMismatch: v)),
              ),
              Text(
                'Bilgisayarda (web) tarayıcı yüklü uygulamaları göstermez; orada yalnızca konum ve IP ülkesi karşılaştırılır.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: GxColors.textSecondary),
              ),
              const SizedBox(height: GxSpacing.xs),
              Wrap(
                spacing: GxSpacing.xs,
                runSpacing: GxSpacing.xs,
                children: [
                  value.smsConfigured
                      ? const GxBadge('SMS sağlayıcısı hazır', tone: GxBadgeTone.success, dot: true)
                      : const GxBadge('SMS sağlayıcısı yapılandırılmadı', tone: GxBadgeTone.warning, dot: true),
                  GxBadge(
                    value.lookupEnabled ? 'Sanal numara kontrolü açık' : 'Sanal numara kontrolü kapalı',
                    tone: value.lookupEnabled ? GxBadgeTone.success : GxBadgeTone.neutral,
                    dot: true,
                  ),
                ],
              ),
            ],
          ),
        AsyncError(:final error) =>
          GxErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(securitySettingsProvider)),
        _ => const GxSkeleton(height: GxSpacing.xxl, borderRadius: GxRadius.mdAll),
      },
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review, required this.canAct, required this.onApprove, required this.onBan});

  final AdminSecurityReview review;
  final bool canAct;
  final VoidCallback onApprove;
  final VoidCallback onBan;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final r = review;
    return GxPanel(
      title: r.title,
      subtitle: 'Açıldı: ${formatDateTimeTr(r.openedAt)}',
      trailing: GxBadge(
        r.status.label,
        tone: switch (r.status) {
          AdminReviewStatus.open => GxBadgeTone.warning,
          AdminReviewStatus.approved => GxBadgeTone.success,
          AdminReviewStatus.banned => GxBadgeTone.danger,
        },
        dot: true,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: GxSpacing.xs,
            runSpacing: GxSpacing.xs,
            children: [
              for (final s in r.signals)
                GxBadge(securitySignalLabel(s), tone: isCertainSignal(s) ? GxBadgeTone.danger : GxBadgeTone.info),
            ],
          ),
          if (r.check case final check?) ...[
            const SizedBox(height: GxSpacing.sm),
            Text(check.summary, style: textTheme.bodySmall?.copyWith(color: GxColors.textSecondary)),
          ],
          if (r.note case final note? when note.isNotEmpty) ...[
            const SizedBox(height: GxSpacing.sm),
            Text('Not: $note', style: textTheme.bodyMedium),
          ],
          const SizedBox(height: GxSpacing.md),
          Wrap(
            spacing: GxSpacing.xs,
            runSpacing: GxSpacing.xs,
            children: [
              GxButton(
                label: 'Kullanıcıyı aç',
                icon: Icons.person_outline,
                variant: GxButtonVariant.text,
                onPressed: () => context.go(AdminRoutes.user(r.userId)),
              ),
              if (canAct && r.status == AdminReviewStatus.open) ...[
                GxButton(label: 'Onayla', icon: Icons.check, variant: GxButtonVariant.secondary, onPressed: onApprove),
                GxButton(label: 'Banla', icon: Icons.block, onPressed: onBan),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Lifts the restriction; optionally exempts the account from uncertain signals for a while (e.g. lives abroad).
class _ApproveDialog extends StatefulWidget {
  const _ApproveDialog();

  @override
  State<_ApproveDialog> createState() => _ApproveDialogState();
}

class _ApproveDialogState extends State<_ApproveDialog> {
  final _note = TextEditingController();
  int _days = 0;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: GxRadius.xlAll),
      title: const Text('Kısıtlamayı kaldır'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: GxLayout.formMaxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Muafiyet süresince VPN ve ülke uyuşmazlığı hesabı yeniden kısıtlamaz. Kesin sinyaller her zaman '
                'geçerlidir.'),
            const SizedBox(height: GxSpacing.sm),
            Wrap(
              spacing: GxSpacing.xs,
              runSpacing: GxSpacing.xs,
              children: [
                for (final (days, label) in const [(0, 'Muafiyet yok'), (30, '30 gün'), (90, '90 gün')])
                  ChoiceChip(label: Text(label), selected: _days == days, onSelected: (_) => setState(() => _days = days)),
              ],
            ),
            const SizedBox(height: GxSpacing.md),
            TextField(
              controller: _note,
              maxLength: 1000,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Not (isteğe bağlı)', hintText: 'ör. Almanya\'da yaşıyor'),
            ),
          ],
        ),
      ),
      actions: [
        GxButton(label: 'Vazgeç', variant: GxButtonVariant.text, onPressed: () => Navigator.of(context).pop()),
        GxButton(label: 'Onayla', onPressed: () => Navigator.of(context).pop((days: _days, note: _note.text.trim()))),
      ],
    );
  }
}

/// The user detail page's security summary (docs/ARCHITECTURE.md §3h).
class UserSecurityPanel extends ConsumerWidget {
  const UserSecurityPanel({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final security = ref.watch(userSecurityProvider(userId));
    final admin = ref.watch(myStaffRoleProvider).value == StaffRole.admin;
    String date(DateTime? d) => d == null ? '—' : formatDateTimeTr(d);
    return switch (security) {
      AsyncData(:final value) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (value.reviewExempt) ...[
              const DetailBanner(
                tone: GxBadgeTone.warning,
                icon: Icons.verified_outlined,
                title: 'Mağaza inceleme hesabı',
                body: 'Konum, telefon ve giriş doğrulaması istenmez; konum sinyalleri ban ya da kısıtlama üretmez.',
              ),
              const SizedBox(height: GxSpacing.md),
            ],
            if (admin) ...[
              _ReviewExemptSwitch(userId: userId, exempt: value.reviewExempt),
              const SizedBox(height: GxSpacing.md),
            ],
            InfoPanel(title: 'Güvenlik', rows: [
              ('Durum', value.state == 'restricted' ? 'Kısıtlı (inceleme)' : 'Normal'),
              ('Telefon', value.phoneMasked == null ? 'Doğrulanmadı' : '${value.phoneMasked} (${value.phoneCountry})'),
              ('Telefon doğrulama', date(value.phoneVerifiedAt)),
              ('Doğrulama uygulaması', value.totpEnabled ? 'Açık' : 'Kapalı'),
              ('Parmak izi (passkey)', value.passkeyCount == 0 ? 'Yok' : '${value.passkeyCount} cihaz'),
              ('İzinli ülke', value.allowedCountry ?? '—'),
              ('Son konum kontrolü', date(value.locationCheckedAt)),
              if (value.exemptUntil case final until? when until.isAfter(DateTime.now()))
                ('Muafiyet', '${formatDateTimeTr(until)} tarihine kadar'),
            ]),
            if (value.checks.isNotEmpty) ...[
              const SizedBox(height: GxSpacing.lg),
              GxPanel(
                title: 'Son konum kontrolleri',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final c in value.checks.take(10))
                      Padding(
                        padding: const EdgeInsets.only(bottom: GxSpacing.sm),
                        child: _CheckRow(check: c),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      AsyncError(:final error) =>
        GxPanel(child: GxErrorState(message: userMessageOf(error), onRetry: () => ref.invalidate(userSecurityProvider(userId)))),
      _ => const GxSkeleton(height: GxSpacing.xxl * 3, borderRadius: GxRadius.lgAll),
    };
  }
}

/// Admin only: marks a store review account (docs/ARCHITECTURE.md §3h, İnceleme hesabı muafiyeti).
class _ReviewExemptSwitch extends ConsumerStatefulWidget {
  const _ReviewExemptSwitch({required this.userId, required this.exempt});

  final String userId;
  final bool exempt;

  @override
  ConsumerState<_ReviewExemptSwitch> createState() => _ReviewExemptSwitchState();
}

class _ReviewExemptSwitchState extends ConsumerState<_ReviewExemptSwitch> {
  bool _saving = false;

  Future<void> _toggle(bool exempt) async {
    final request = await showSuspendDialog(
      context,
      title: exempt ? 'Mağaza inceleme hesabı yap' : 'İnceleme muafiyetini kaldır',
      description: exempt
          ? 'Bu hesap konum, telefon ve giriş doğrulamasından kalıcı olarak muaf olur. Yalnızca mağaza incelemesi için '
              'açılmış, gerçek bir kişiye ait olmayan hesaplara ver. Gerekçe kayda geçer.'
          : 'Hesap bir sonraki girişte yeniden güvenlik doğrulamasından geçer. Gerekçe kayda geçer.',
      withDuration: false,
      confirmLabel: exempt ? 'Muaf tut' : 'Kaldır',
    );
    if (request == null || !mounted) return;
    setState(() => _saving = true);
    final result = await ref
        .read(adminSecurityRepositoryProvider)
        .setReviewExempt(widget.userId, exempt: exempt, note: request.reason);
    if (!mounted) return;
    setState(() => _saving = false);
    if (result case Err(:final failure)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.userMessage)));
    }
    ref.invalidate(userSecurityProvider(widget.userId));
  }

  @override
  Widget build(BuildContext context) => GxPanel(
        child: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: widget.exempt,
          title: const Text('Mağaza inceleme hesabı'),
          subtitle: const Text('Google Play inceleme ekibinin Türkiye konumu ve numarası olmadan girebilmesi için.'),
          onChanged: _saving ? null : _toggle,
        ),
      );
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.check});

  final AdminLocationCheck check;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: GxSpacing.xs,
          runSpacing: GxSpacing.xxs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(formatDateTimeTr(check.checkedAt), style: textTheme.labelLarge),
            switch (check.verdict) {
              'banned' => const GxBadge('Ban', tone: GxBadgeTone.danger),
              'restricted' => const GxBadge('Kısıtlandı', tone: GxBadgeTone.warning),
              _ => const GxBadge('Temiz', tone: GxBadgeTone.success),
            },
            for (final s in check.signals) GxBadge(securitySignalLabel(s), tone: GxBadgeTone.neutral),
          ],
        ),
        Text(check.summary, style: textTheme.bodySmall?.copyWith(color: GxColors.textSecondary)),
      ],
    );
  }
}
