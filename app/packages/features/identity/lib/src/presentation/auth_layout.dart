import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// The form on a white card, shared by the auth and account screens. With
/// [showPitch] on wide screens a brand panel tells what GrupX is about.
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
    final pitch = showPitch && MediaQuery.sizeOf(context).width >= GxLayout.wideBreakpoint;
    final form = SingleChildScrollView(
      padding: const EdgeInsets.all(GxSpacing.page),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: GxLayout.formMaxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showBrand && !pitch) ...[
              const Center(child: GxLogo(size: GxSpacing.xl + GxSpacing.xs, wordmark: true)),
              const SizedBox(height: GxSpacing.lg),
            ],
            GxCard(
              padding: const EdgeInsets.all(GxSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(title, style: textTheme.headlineMedium),
                  if (subtitle != null) ...[
                    const SizedBox(height: GxSpacing.xs),
                    Text(subtitle!, style: textTheme.bodyMedium?.copyWith(color: GxColors.textSecondary)),
                  ],
                  const SizedBox(height: GxSpacing.lg),
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

/// What GrupX is for, beside the form on wide screens.
class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    Widget point(IconData icon, String text) => Padding(
          padding: const EdgeInsets.only(bottom: GxSpacing.md),
          child: Row(
            children: [
              Container(
                width: GxAvatarSize.md.dimension,
                height: GxAvatarSize.md.dimension,
                decoration: const BoxDecoration(color: GxColors.background, borderRadius: GxRadius.mdAll),
                child: Icon(icon, color: GxColors.primary),
              ),
              const SizedBox(width: GxSpacing.sm),
              Expanded(child: Text(text, style: textTheme.bodyLarge)),
            ],
          ),
        );
    return Container(
      margin: const EdgeInsets.all(GxSpacing.md),
      padding: const EdgeInsets.all(GxSpacing.xxl),
      decoration: const BoxDecoration(color: GxColors.primarySoft, borderRadius: GxRadius.xlAll),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const GxLogo(size: GxSpacing.xl + GxSpacing.xs, wordmark: true),
          const Spacer(),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: GxLayout.formMaxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Topluluğun seni bekliyor.', style: textTheme.displayLarge),
                const SizedBox(height: GxSpacing.sm),
                Text(
                  'Yürüyüşten müziğe, koşudan sanata; grubunu bul, birlikte plan yap, aynı anda orada ol.',
                  style: textTheme.bodyLarge?.copyWith(color: GxColors.textSecondary),
                ),
                const SizedBox(height: GxSpacing.xl),
                point(Icons.groups_outlined, 'Gruplara katıl ya da kendi topluluğunu kur'),
                point(Icons.event_available_outlined, 'Organizasyonları takvimine ekle, ekip arkadaşı bul'),
                point(Icons.graphic_eq_rounded, 'Grubunla canlı sesli sohbetlerde buluş'),
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
          padding: const EdgeInsets.symmetric(horizontal: GxSpacing.sm),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: GxColors.textSecondary,
                ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
