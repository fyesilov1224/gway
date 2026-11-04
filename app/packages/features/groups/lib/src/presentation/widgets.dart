import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/group.dart';
import '../l10n.dart';
import 'providers.dart';
import 'routes.dart';

IconData joinPolicyIcon(JoinPolicy policy) => switch (policy) {
      JoinPolicy.open => Icons.public,
      JoinPolicy.request => Icons.how_to_reg_outlined,
      JoinPolicy.invite => Icons.mail_outline,
    };

String memberCountLabel(int count) => groupsL10n.memberCount(count);

/// Category names by slug, empty until loaded.
Map<String, String> categoryNames(WidgetRef ref) =>
    {for (final c in ref.watch(categoriesProvider).value ?? const <Category>[]) c.slug: c.name};

class GroupRoleBadge extends StatelessWidget {
  const GroupRoleBadge(this.role, {super.key});

  final GroupRole role;

  @override
  Widget build(BuildContext context) => GwBadge(
        role.label,
        tone: switch (role) {
          GroupRole.owner => GwBadgeTone.primary,
          GroupRole.admin => GwBadgeTone.info,
          _ => GwBadgeTone.neutral,
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
        Icon(icon, size: GwSpacing.md + GwSpacing.xxs, color: GwColors.textSecondary),
        const SizedBox(width: GwSpacing.xxs + 2),
        Flexible(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
        ),
      ],
    );
  }
}

/// One group in a list, as a card: logo, name and a summary line. Opens the group page.
class GroupTile extends ConsumerWidget {
  const GroupTile({super.key, required this.group, this.trailing});

  final Group group;
  final Widget? trailing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final category = categoryNames(ref)[group.categorySlug];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GwSpacing.page, vertical: GwSpacing.xxs),
      child: GwCard(
        radius: GwRadius.lgAll,
        padding: const EdgeInsets.all(GwSpacing.sm),
        onTap: () => context.push(GroupRoutes.group(group.handle)),
        child: Row(
          children: [
            GwAvatar(name: group.name, shape: GwAvatarShape.group, imageUrl: group.logoUrl, size: GwAvatarSize.lg),
            const SizedBox(width: GwSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.titleMedium),
                  Text(
                    [?category, memberCountLabel(group.memberCount)].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary),
                  ),
                  if (group.joinPolicy != JoinPolicy.open || group.isSuspended) ...[
                    const SizedBox(height: GwSpacing.xxs),
                    group.isSuspended
                        ? GwBadge(groupsL10n.suspended, tone: GwBadgeTone.danger, dot: true)
                        : GroupMeta(icon: joinPolicyIcon(group.joinPolicy), text: group.joinPolicy.label),
                  ],
                ],
              ),
            ),
            trailing ?? const Icon(Icons.chevron_right, color: GwColors.textSecondary),
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
    final logo = GwAvatarSize.lg.dimension;
    return Column(
      children: [
        for (var i = 0; i < count; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: GwSpacing.md, vertical: GwSpacing.sm),
            child: Row(
              children: [
                GwSkeleton(width: logo, height: logo, borderRadius: GwRadius.lgAll),
                const SizedBox(width: GwSpacing.sm),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GwSkeleton(width: GwSpacing.xxl * 3, height: GwSpacing.md),
                      SizedBox(height: GwSpacing.xs),
                      GwSkeleton(width: GwSpacing.xxl * 2, height: GwSpacing.sm),
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

/// groupsL10n.groups section of a profile page.
class UserGroupsSection extends ConsumerWidget {
  const UserGroupsSection({super.key, required this.userId, required this.isOwn, this.groupsPublic = false});

  final String userId;
  final bool isOwn;

  /// Visitors see every group; otherwise only shared ones and the person's teams (docs/ARCHITECTURE.md §3b).
  final bool groupsPublic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final groups = ref.watch(userGroupsProvider(userId));
    final secondary = textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(GwSpacing.md, GwSpacing.md, GwSpacing.md, GwSpacing.xs),
          child: Text(groupsL10n.groups, style: textTheme.titleLarge),
        ),
        if (!groupsPublic)
          Padding(
            padding: const EdgeInsets.fromLTRB(GwSpacing.md, 0, GwSpacing.md, GwSpacing.xs),
            child: Text(
              isOwn
                  ? groupsL10n.groupsOwnHint
                  : groupsL10n.groupsOtherHint,
              style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary),
            ),
          ),
        switch (groups) {
          AsyncData(:final value) when value.isEmpty => Padding(
              padding: const EdgeInsets.fromLTRB(GwSpacing.md, 0, GwSpacing.md, GwSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isOwn ? groupsL10n.notJoinedYet : groupsL10n.noGroupsToShow, style: secondary),
                  if (isOwn)
                    TextButton(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      onPressed: () => context.go(GroupRoutes.discover),
                      child: Text(groupsL10n.discoverGroups),
                    ),
                ],
              ),
            ),
          AsyncData(:final value) => Column(children: [for (final g in value) GroupTile(group: g)]),
          AsyncError(:final error) => Padding(
              padding: const EdgeInsets.fromLTRB(GwSpacing.md, 0, GwSpacing.md, GwSpacing.md),
              child: GwFormMessage(userMessageOf(error)),
            ),
          _ => const GroupListSkeleton(count: 2),
        },
        const SizedBox(height: GwSpacing.xs),
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
          GroupRules.validateHandle(v) ?? (_available == false ? groupsL10n.handleTaken : null),
      decoration: InputDecoration(
        labelText: groupsL10n.groupAddress,
        prefixText: 'gway.app/g/',
        helperText: groupsL10n.groupAddressHint,
        helperMaxLines: 2,
        counterText: '',
        suffixIcon: _checking
            ? const Padding(
                padding: EdgeInsets.all(GwSpacing.sm),
                child: SizedBox.square(dimension: GwSpacing.md, child: CircularProgressIndicator(strokeWidth: 2)),
              )
            : switch (_available) {
                true => Icon(Icons.check_circle, color: GwColors.primary, semanticLabel: groupsL10n.available),
                false => Icon(Icons.cancel, color: GwColors.error, semanticLabel: groupsL10n.taken),
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
          DropdownMenuItem<int?>(child: Text(groupsL10n.notSpecified)),
          for (var i = 0; i < turkishProvinces.length; i++) DropdownMenuItem<int?>(value: i + 1, child: Text(turkishProvinces[i])),
        ],
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: groupsL10n.provinceOptional,
          helperText: groupsL10n.provinceHint,
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
                Icon(categoryIcon(c.slug), size: GwSpacing.md + GwSpacing.xxs, color: GwColors.textSecondary),
                const SizedBox(width: GwSpacing.xs),
                Text(c.name),
              ],
            ),
          ),
      ],
      onChanged: onChanged,
      validator: (v) => v == null ? groupsL10n.chooseCategory : null,
      decoration: InputDecoration(labelText: groupsL10n.category),
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
              color: p == value ? GwColors.primarySoft : GwColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: GwRadius.mdAll,
                side: p == value ? const BorderSide(color: GwColors.primary) : GwBorders.hairline,
              ),
              child: InkWell(
                borderRadius: GwRadius.mdAll,
                onTap: () => onChanged(p),
                child: Padding(
                  padding: const EdgeInsets.all(GwSpacing.sm),
                  child: Row(
                    children: [
                      Icon(joinPolicyIcon(p), color: p == value ? GwColors.primary : GwColors.textSecondary),
                      const SizedBox(width: GwSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.label, style: textTheme.labelLarge),
                            Text(p.description, style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
                          ],
                        ),
                      ),
                      if (p == value) const Icon(Icons.check_circle, color: GwColors.primary),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (p != JoinPolicy.values.last) const SizedBox(height: GwSpacing.xs),
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
        shape: const RoundedRectangleBorder(borderRadius: GwRadius.xlAll),
        title: Text(title),
        content: Text(message),
        actions: [
          GwButton(label: groupsL10n.cancel, variant: GwButtonVariant.text, onPressed: () => Navigator.of(context).pop(false)),
          GwButton(label: confirmLabel, onPressed: () => Navigator.of(context).pop(true)),
        ],
      ),
    ) ??
    false;

/// Shows a short result message at the bottom of the screen.
void showGroupMessage(BuildContext context, String message) =>
    ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(message)));
