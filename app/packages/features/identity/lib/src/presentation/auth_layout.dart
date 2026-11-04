import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../l10n.dart';
import 'language_picker.dart';

/// The form on a white card, shared by the auth and account screens. With
/// [showPitch] on wide screens a brand panel tells what GWAY is about.
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.showBrand = true,
    this.showPitch = false,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final bool showBrand;

  /// Sign-in and sign-up of the social app only (not the admin panel).
  final bool showPitch;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final pitch = showPitch && MediaQuery.sizeOf(context).width >= GwLayout.wideBreakpoint;
    final form = SingleChildScrollView(
      padding: const EdgeInsets.all(GwSpacing.page),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: GwLayout.formMaxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Language choice before signing in; the panel (no pitch) stays Turkish.
            if (showPitch) const Align(alignment: AlignmentDirectional.centerEnd, child: LanguageButton()),
            if (showBrand && !pitch) ...[
              const Center(child: GwLogo(size: GwSpacing.xl + GwSpacing.xs, wordmark: true)),
              const SizedBox(height: GwSpacing.lg),
            ],
            GwCard(
              padding: const EdgeInsets.all(GwSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(title, style: textTheme.headlineMedium),
                  if (subtitle != null) ...[
                    const SizedBox(height: GwSpacing.xs),
                    Text(subtitle!, style: textTheme.bodyMedium?.copyWith(color: GwColors.textSecondary)),
                  ],
                  const SizedBox(height: GwSpacing.lg),
                  ...children,
                ],
              ),
            ),
          ],
        ),
      ),
    );
    return Scaffold(
      body: SafeArea(
        child: pitch
            ? Row(
                children: [
                  const Expanded(child: _BrandPanel()),
                  Expanded(child: Center(child: form)),
                ],
              )
            : Center(child: form),
      ),
    );
  }
}

/// What GWAY is for, beside the form on wide screens.
class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    Widget point(IconData icon, String text) => Padding(
          padding: const EdgeInsets.only(bottom: GwSpacing.md),
          child: Row(
            children: [
              Container(
                width: GwAvatarSize.md.dimension,
                height: GwAvatarSize.md.dimension,
                decoration: const BoxDecoration(color: GwColors.primarySoft, borderRadius: GwRadius.mdAll),
                child: Icon(icon, color: GwColors.primary),
              ),
              const SizedBox(width: GwSpacing.sm),
              Expanded(child: Text(text, style: textTheme.bodyLarge)),
            ],
          ),
        );
    return Container(
      margin: const EdgeInsets.all(GwSpacing.md),
      padding: const EdgeInsets.all(GwSpacing.xxl),
      // Frosted white over the backdrop, so the lilac and pink show through.
      decoration: BoxDecoration(
        color: GwColors.background.withValues(alpha: 0.6),
        borderRadius: GwRadius.xlAll,
        border: const Border.fromBorderSide(GwBorders.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const GwLogo(size: GwSpacing.xl + GwSpacing.xs, wordmark: true),
          const Spacer(),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: GwLayout.formMaxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(identityL10n.heroTitle, style: textTheme.displayLarge),
                const SizedBox(height: GwSpacing.sm),
                Text(
                  identityL10n.heroBody,
                  style: textTheme.bodyLarge?.copyWith(color: GwColors.textSecondary),
                ),
                const SizedBox(height: GwSpacing.xl),
                point(Icons.groups_outlined, identityL10n.heroPointGroups),
                point(Icons.event_available_outlined, identityL10n.heroPointEvents),
                point(Icons.graphic_eq_rounded, identityL10n.heroPointLive),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

/// Divider with a centered label, e.g. "veya".
class LabeledDivider extends StatelessWidget {
  const LabeledDivider(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: GwSpacing.sm),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: GwColors.textSecondary,
                ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
