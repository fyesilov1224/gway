import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/group.dart';
import 'providers.dart';
import 'routes.dart';

IconData joinPolicyIcon(JoinPolicy policy) => switch (policy) {
      JoinPolicy.open => Icons.public,
      JoinPolicy.request => Icons.how_to_reg_outlined,
      JoinPolicy.invite => Icons.mail_outline,
    };

String memberCountLabel(int count) => '$count üye';

/// Category names by slug, empty until loaded.
Map<String, String> categoryNames(WidgetRef ref) =>
    {for (final c in ref.watch(categoriesProvider).value ?? const <Category>[]) c.slug: c.name};

class GroupRoleBadge extends StatelessWidget {
  const GroupRoleBadge(this.role, {super.key});

  final GroupRole role;

  @override
  Widget build(BuildContext context) => GxBadge(
        role.label,
        tone: switch (role) {
          GroupRole.owner => GxBadgeTone.primary,
          GroupRole.admin => GxBadgeTone.info,
          _ => GxBadgeTone.neutral,
        },
      );
}

/// Small icon + text pair used in group meta rows.
class GroupMeta extends StatelessWidget {
  const GroupMeta({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: GxSpacing.md + GxSpacing.xxs, color: GxColors.textSecondary),
        const SizedBox(width: GxSpacing.xxs + 2),
        Flexible(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary)),
        ),
      ],
    );
  }
}

/// One group in a list: logo, name and a summary line. Opens the group page.
class GroupTile extends ConsumerWidget {
  const GroupTile({super.key, required this.group, this.trailing});

  final Group group;
  final Widget? trailing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final category = categoryNames(ref)[group.categorySlug];
    return InkWell(
      onTap: () => context.push(GroupRoutes.group(group.handle)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: GxSpacing.md, vertical: GxSpacing.sm),
        child: Row(
          children: [
            GxAvatar(name: group.name, shape: GxAvatarShape.group, imageUrl: group.logoUrl, size: GxAvatarSize.lg),
            const SizedBox(width: GxSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.titleMedium),
                  Text(
                    [?category, memberCountLabel(group.memberCount)].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary),
                  ),
                  if (group.joinPolicy != JoinPolicy.open || group.isSuspended) ...[
                    const SizedBox(height: GxSpacing.xxs),
                    group.isSuspended
                        ? const GxBadge('Askıda', tone: GxBadgeTone.danger, dot: true)
                        : GroupMeta(icon: joinPolicyIcon(group.joinPolicy), text: group.joinPolicy.label),
                  ],
                ],
              ),
            ),
            trailing ?? const Icon(Icons.chevron_right, color: GxColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class GroupListSkeleton extends StatelessWidget {
  const GroupListSkeleton({super.key, this.count = 4});

  final int count;

  @override
  Widget build(BuildContext context) {
    final logo = GxAvatarSize.lg.dimension;
    return Column(
      children: [
        for (var i = 0; i < count; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: GxSpacing.md, vertical: GxSpacing.sm),
            child: Row(
              children: [
                GxSkeleton(width: logo, height: logo, borderRadius: GxRadius.lgAll),
                const SizedBox(width: GxSpacing.sm),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GxSkeleton(width: GxSpacing.xxl * 3, height: GxSpacing.md),
                      SizedBox(height: GxSpacing.xs),
                      GxSkeleton(width: GxSpacing.xxl * 2, height: GxSpacing.sm),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// "Gruplar" section of a profile page.
class UserGroupsSection extends ConsumerWidget {
  const UserGroupsSection({super.key, required this.userId, required this.isOwn});

  final String userId;
  final bool isOwn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final groups = ref.watch(userGroupsProvider(userId));
    final secondary = textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(GxSpacing.md, GxSpacing.md, GxSpacing.md, GxSpacing.xs),
          child: Text('Gruplar', style: textTheme.titleMedium),
        ),
        switch (groups) {
          AsyncData(:final value) when value.isEmpty => Padding(
              padding: const EdgeInsets.fromLTRB(GxSpacing.md, 0, GxSpacing.md, GxSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isOwn ? 'Henüz bir gruba katılmadın.' : 'Henüz bir gruba katılmamış.', style: secondary),
                  if (isOwn)
                    TextButton(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      onPressed: () => context.go(GroupRoutes.discover),
                      child: const Text('Grupları keşfet'),
                    ),
                ],
              ),
            ),
          AsyncData(:final value) => Column(children: [for (final g in value) GroupTile(group: g)]),
          AsyncError(:final error) => Padding(
              padding: const EdgeInsets.fromLTRB(GxSpacing.md, 0, GxSpacing.md, GxSpacing.md),
              child: GxFormMessage(userMessageOf(error)),
            ),
          _ => const GroupListSkeleton(count: 2),
        },
        const SizedBox(height: GxSpacing.xs),
      ],
    );
  }
}

/// Group address field that checks availability on the server while typing.
class HandleField extends ConsumerStatefulWidget {
  const HandleField({super.key, required this.controller, required this.onAvailabilityChanged, this.onEdited});

  final TextEditingController controller;

  /// Called with true/false once checked, null while unknown.
  final ValueChanged<bool?> onAvailabilityChanged;

  /// The user typed in the field (stops suggestions from the name).
  final VoidCallback? onEdited;

  @override
  ConsumerState<HandleField> createState() => HandleFieldState();
}

class HandleFieldState extends ConsumerState<HandleField> {
  Timer? _debounce;
  bool? _available;
  bool _checking = false;
  int _requestId = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  /// Re-checks after the text was set programmatically.
  void recheck() => _onChanged(widget.controller.text);

  void _onChanged(String value) {
    _debounce?.cancel();
    final handle = GroupRules.normalizeHandle(value);
    _setAvailability(null);
    if (GroupRules.validateHandle(handle) != null) return;
    _debounce = Timer(const Duration(milliseconds: 400), () => _check(handle));
  }

  Future<void> _check(String handle) async {
    final id = ++_requestId;
    setState(() => _checking = true);
    final result = await ref.read(groupsRepositoryProvider).isHandleAvailable(handle);
    if (!mounted || id != _requestId) return;
    setState(() => _checking = false);
    _setAvailability(switch (result) {
      Ok(:final value) => value,
      Err() => null,
    });
  }

  void _setAvailability(bool? value) {
    if (_available == value) return;
    setState(() => _available = value);
    widget.onAvailabilityChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      autocorrect: false,
      maxLength: GroupRules.handleMaxLength,
      onChanged: (v) {
        widget.onEdited?.call();
        _onChanged(v);
      },
      validator: (v) =>
          GroupRules.validateHandle(v) ?? (_available == false ? 'Bu grup adresi alınmış. Başka bir tane dene.' : null),
      decoration: InputDecoration(
        labelText: 'Grup adresi',
        prefixText: 'grupx.app/g/',
        helperText: 'Grup sayfanın adresi. Sonradan değiştirilemez.',
        helperMaxLines: 2,
        counterText: '',
        suffixIcon: _checking
            ? const Padding(
                padding: EdgeInsets.all(GxSpacing.sm),
                child: SizedBox.square(dimension: GxSpacing.md, child: CircularProgressIndicator(strokeWidth: 2)),
              )
            : switch (_available) {
                true => const Icon(Icons.check_circle, color: GxColors.primary, semanticLabel: 'Kullanılabilir'),
                false => const Icon(Icons.cancel, color: GxColors.error, semanticLabel: 'Alınmış'),
                null => null,
              },
      ),
    );
  }
}

/// Category dropdown fed by the shared categories.
/// Optional province; only its center is used, on the map.
class ProvinceField extends StatelessWidget {
  const ProvinceField({super.key, required this.value, required this.onChanged});

  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<int?>(
        initialValue: value,
        isExpanded: true,
        items: [
          const DropdownMenuItem<int?>(child: Text('Belirtilmedi')),
          for (var i = 0; i < turkishProvinces.length; i++) DropdownMenuItem<int?>(value: i + 1, child: Text(turkishProvinces[i])),
        ],
        onChanged: onChanged,
        decoration: const InputDecoration(
          labelText: 'İl (isteğe bağlı)',
          helperText: 'Grup haritada bu ilde görünür.',
        ),
      );
}

class CategoryField extends ConsumerWidget {
  const CategoryField({super.key, required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider).value ?? const <Category>[];
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      items: [
        for (final c in categories)
          DropdownMenuItem(
            value: c.slug,
            child: Row(
              children: [
                Icon(categoryIcon(c.slug), size: GxSpacing.md + GxSpacing.xxs, color: GxColors.textSecondary),
                const SizedBox(width: GxSpacing.xs),
                Text(c.name),
              ],
            ),
          ),
      ],
      onChanged: onChanged,
      validator: (v) => v == null ? 'Bir kategori seç.' : null,
      decoration: const InputDecoration(labelText: 'Kategori'),
    );
  }
}

/// The three join policies as selectable rows with a short explanation.
class JoinPolicyPicker extends StatelessWidget {
  const JoinPolicyPicker({super.key, required this.value, required this.onChanged});

  final JoinPolicy value;
  final ValueChanged<JoinPolicy> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        for (final p in JoinPolicy.values) ...[
          Semantics(
            selected: p == value,
            button: true,
            child: Material(
              color: p == value ? GxColors.primarySoft : GxColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: GxRadius.mdAll,
                side: p == value ? const BorderSide(color: GxColors.primary) : GxBorders.hairline,
              ),
              child: InkWell(
                borderRadius: GxRadius.mdAll,
                onTap: () => onChanged(p),
                child: Padding(
                  padding: const EdgeInsets.all(GxSpacing.sm),
                  child: Row(
                    children: [
                      Icon(joinPolicyIcon(p), color: p == value ? GxColors.primary : GxColors.textSecondary),
                      const SizedBox(width: GxSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.label, style: textTheme.labelLarge),
                            Text(p.description, style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary)),
                          ],
                        ),
                      ),
                      if (p == value) const Icon(Icons.check_circle, color: GxColors.primary),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (p != JoinPolicy.values.last) const SizedBox(height: GxSpacing.xs),
        ],
      ],
    );
  }
}

/// Asks for confirmation; true when confirmed.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: GxRadius.xlAll),
        title: Text(title),
        content: Text(message),
        actions: [
          GxButton(label: 'Vazgeç', variant: GxButtonVariant.text, onPressed: () => Navigator.of(context).pop(false)),
          GxButton(label: confirmLabel, onPressed: () => Navigator.of(context).pop(true)),
        ],
      ),
    ) ??
    false;

/// Shows a short result message at the bottom of the screen.
void showGroupMessage(BuildContext context, String message) =>
    ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(message)));
