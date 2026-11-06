import 'package:cloudflare_turnstile/cloudflare_turnstile.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cloudflare Turnstile's site key (docs/ARCHITECTURE.md §3k); empty turns the bot check off. Replaced in tests.
final humanCheckSiteKeyProvider = Provider<String>((ref) => ref.watch(appConfigProvider).turnstileSiteKey);

/// The page Turnstile runs under on phones: one of the widget's allowed domains (the web app's own address).
final humanCheckBaseUrlProvider = Provider<String>((ref) => ref.watch(appConfigProvider).shareUrl);

/// The bot check's state for one form: the one-time token Turnstile gave, spent by each attempt.
class HumanCheckController extends ChangeNotifier {
  String? _token;
  bool _enabled = false;
  Future<void> Function()? _refresh;

  /// Null while the check runs, has failed, or is off.
  String? get token => _token;

  /// Whether the form may be sent: the check is off, or it gave a token.
  bool get ready => !_enabled || _token != null;

  void _setEnabled(bool enabled) => _enabled = enabled;

  /// What the Turnstile widget reports: on, and a token (null while running, expired or failed).
  @visibleForTesting
  void report({required bool enabled, String? token}) {
    _setEnabled(enabled);
    _setToken(token);
  }

  void _setToken(String? token) {
    if (token == _token) return;
    _token = token;
    notifyListeners();
  }

  /// A token works once: after each attempt a new check runs.
  void spend() {
    if (!_enabled) return;
    _setToken(null);
    _refresh?.call().ignore();
  }
}

/// The bot check under a sign-up, sign-in or password reset form (docs/ARCHITECTURE.md §3k). Most people pass it
/// without doing anything; Cloudflare asks for one tap when in doubt. Shows nothing without a site key.
class HumanCheck extends ConsumerStatefulWidget {
  const HumanCheck({super.key, required this.controller});

  final HumanCheckController controller;

  @override
  ConsumerState<HumanCheck> createState() => _HumanCheckState();
}

class _HumanCheckState extends ConsumerState<HumanCheck> {
  final _turnstile = TurnstileController();

  @override
  void initState() {
    super.initState();
    widget.controller._refresh = _turnstile.refreshToken;
  }

  @override
  void dispose() {
    widget.controller._refresh = null;
    _turnstile.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final siteKey = ref.watch(humanCheckSiteKeyProvider);
    widget.controller._setEnabled(siteKey.isNotEmpty);
    if (siteKey.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: GwSpacing.md),
      child: Center(
        child: CloudflareTurnstile(
          siteKey: siteKey,
          baseUrl: ref.watch(humanCheckBaseUrlProvider),
          controller: _turnstile,
          options: TurnstileOptions(
            size: TurnstileSize.flexible,
            theme: TurnstileTheme.light,
            language: currentAppLanguage.code,
          ),
          onTokenReceived: widget.controller._setToken,
          onTokenExpired: () => widget.controller._setToken(null),
          onError: (_) => widget.controller._setToken(null),
        ),
      ),
    );
  }
}
