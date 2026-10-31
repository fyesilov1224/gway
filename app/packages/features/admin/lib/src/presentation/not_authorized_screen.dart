import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Signed in, but not a member of the platform team.
class NotAuthorizedScreen extends StatelessWidget {
  const NotAuthorizedScreen({super.key, required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GwEmptyState(
        icon: Icons.lock_outline,
        message: 'Bu panel yalnızca GWAY platform ekibi içindir. Hesabının yetkisi yok.',
        actionLabel: 'Çıkış yap',
        onAction: onSignOut,
      ),
    );
  }
}
