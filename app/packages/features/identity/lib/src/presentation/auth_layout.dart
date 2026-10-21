import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Centered, width-limited layout shared by the auth and account screens.
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.showBrand = true,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final bool showBrand;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(GxSpacing.page),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: GxLayout.formMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showBrand) ...[
                    const Center(child: GxLogo(size: GxSpacing.xl + GxSpacing.xs, wordmark: true)),
                    const SizedBox(height: GxSpacing.xl),
                  ],
                  Text(title, style: textTheme.titleLarge),
                  if (subtitle != null) ...[
                    const SizedBox(height: GxSpacing.xs),
                    Text(
                      subtitle!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: GxColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: GxSpacing.lg),
                  ...children,
                ],
              ),
            ),
          ),
        ),
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
