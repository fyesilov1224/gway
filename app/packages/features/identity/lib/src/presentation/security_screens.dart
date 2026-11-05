import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/legal.dart';
import '../domain/security.dart';
import '../l10n.dart';
import 'auth_layout.dart';
import 'providers.dart';

/// The security steps before the app opens (docs/ARCHITECTURE.md §3h): location, phone, second factor, or the
/// restricted notice. The server says which one; this screen only follows it.
class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(securityStatusProvider).value;
    return switch (status?.step) {
      SecurityStep.location => const _LocationStep(),
      SecurityStep.phone => _PhoneStep(status: status!),
      SecurityStep.secondFactor => _SecondFactorStep(status: status!),
      SecurityStep.restricted => const _RestrictedStep(),
      // Still loading, or the status could not be read: never a blank page.
      _ => switch (ref.watch(securityStatusProvider)) {
          AsyncError(:final error) => AuthLayout(
              title: identityL10n.securityTitle,
              children: [
                GwErrorState(message: userMessageOf(error), onRetry: () => _reload(ref)),
                const _SignOutButton(),
              ],
            ),
          _ => GwSplash(caption: identityL10n.securityChecking),
        },
    };
  }
}

/// Shown when a location check is refused or the account is under review (user decision, 2026-10-27).
/// In the app language; kept as a getter so it follows a language change.
String get securityWarning => identityL10n.securityWarning;

/// The warning for an installed (not running) VPN app (user decision, 2026-10-27).
String get vpnInstalledWarning => identityL10n.vpnInstalledWarning;

/// Shows the warnings of a location check's answer, as a dialog.
Future<void> showSecurityWarnings(BuildContext context, List<String> warnings) async {
  if (!warnings.contains('vpn_installed')) return;
  await showDialog<void>(
    context: context,
    builder: (dialog) => AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: GwRadius.xlAll),
      icon: const Icon(Icons.vpn_lock_outlined),
      title: Text(identityL10n.securityWarningTitle),
      content: Text(vpnInstalledWarning),
      actions: [GwButton(label: identityL10n.understood, onPressed: () => Navigator.of(dialog).pop())],
    ),
  );
}

/// Adds a passkey on this device. Null on success, otherwise a message for the user. [refreshStatus] false while
/// another flow still owns the screen (the offer after phone verification).
Future<String?> addPasskey(WidgetRef ref, {bool refreshStatus = true}) async {
  final repo = ref.read(securityRepositoryProvider);
  final options = await repo.passkeyRegistrationOptions();
  final String json;
  switch (options) {
    case Ok(:final value):
      json = value;
    case Err(:final failure):
      return failure.userMessage;
  }
  final response = await ref.read(passkeyAuthenticatorProvider).create(json);
  if (response == null) return identityL10n.passkeyNotAdded;
  final saved = await repo.registerPasskey(identityL10n.passkeyDefaultName(formatDate(DateTime.now())), response);
  ref.invalidate(passkeysProvider);
  if (refreshStatus) ref.invalidate(securityStatusProvider);
  return switch (saved) { Ok() => null, Err(:final failure) => failure.userMessage };
}

/// After any step: the server's answer decides what comes next. A failure may mean the account was restricted
/// or banned, so the account state is reloaded too.
void _reload(WidgetRef ref) => ref
  ..invalidate(securityStatusProvider)
  ..invalidate(accountStateProvider);

const _gap = SizedBox(height: GwSpacing.md);

class _SignOutButton extends ConsumerWidget {
  const _SignOutButton({this.enabled = true});

  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) => GwButton(
        label: identityL10n.signOut,
        variant: GwButtonVariant.text,
        onPressed: enabled ? () => ref.read(authRepositoryProvider).signOut() : null,
      );
}

// ---------------------------------------------------------------------------

class _LocationStep extends ConsumerStatefulWidget {
  const _LocationStep();

  @override
  ConsumerState<_LocationStep> createState() => _LocationStepState();
}

class _LocationStepState extends ConsumerState<_LocationStep> {
  bool _busy = false;
  bool _permanentlyDenied = false;
  String? _error;

  Future<void> _check() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final reading = await ref.read(deviceSignalSourceProvider).read();
    if (!mounted) return;
    switch (reading) {
      case LocationRead(:final signals):
        final result = await ref.read(securityRepositoryProvider).sendLocation(signals);
        if (!mounted) return;
        switch (result) {
          case Ok(:final value):
            await showSecurityWarnings(context, value.warnings);
            if (!mounted) return;
          // A refusal means the check restricted or banned the account: say so instead of a raw error.
          case Err(:final failure):
            setState(() => _error = failure is ForbiddenFailure ? securityWarning : failure.userMessage);
        }
        _reload(ref);
      case LocationDenied(:final permanently):
        _permanentlyDenied = permanently;
        _error = permanently
            ? identityL10n.locationDeniedForever
            : identityL10n.locationRequired;
      case LocationServiceOff():
        _error = identityL10n.locationServiceOff;
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: identityL10n.locationTitle,
      subtitle: identityL10n.locationBody,
      children: [
        if (_error != null) ...[GwFormMessage(_error!), _gap],
        if (_permanentlyDenied) ...[
          GwButton(
            label: identityL10n.openSettings,
            icon: Icons.settings_outlined,
            onPressed: _busy ? null : () => ref.read(deviceSignalSourceProvider).openSettings(),
            expand: true,
          ),
          const SizedBox(height: GwSpacing.sm),
          GwButton(label: identityL10n.retry, variant: GwButtonVariant.secondary, onPressed: _check, isLoading: _busy, expand: true),
        ] else
          GwButton(label: identityL10n.grantLocation, icon: Icons.my_location, onPressed: _check, isLoading: _busy, expand: true),
        const SizedBox(height: GwSpacing.sm),
        GwButton(
          label: identityL10n.readPrivacyNotice,
          variant: GwButtonVariant.text,
          onPressed: () => _showPrivacyNotice(context),
        ),
        _SignOutButton(enabled: !_busy),
      ],
    );
  }

  /// KVKK: the notice is readable before any location is collected.
  void _showPrivacyNotice(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => Consumer(
          builder: (context, ref, _) {
            final docs = ref.watch(latestLegalDocumentsProvider);
            final textTheme = Theme.of(context).textTheme;
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(GwSpacing.page, 0, GwSpacing.page, GwSpacing.page),
                child: switch (docs) {
                  AsyncData(:final value) => switch (value.where((d) => d.kind == LegalKind.privacyNotice).firstOrNull) {
                      final doc? => SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(doc.title, style: textTheme.titleLarge),
                              const SizedBox(height: GwSpacing.sm),
                              Text(doc.body, style: textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      null => Text(identityL10n.privacyNoticeUnavailable),
                    },
                  AsyncError(:final error) => GwErrorState(
                      message: userMessageOf(error),
                      onRetry: () => ref.invalidate(latestLegalDocumentsProvider),
                    ),
                  _ => const Center(child: CircularProgressIndicator()),
                },
              ),
            );
          },
        ),
      );
}

// ---------------------------------------------------------------------------

/// Six digits; the platform offers the SMS code where it can.
class _CodeField extends StatelessWidget {
  const _CodeField({required this.controller, required this.onSubmitted});

  final TextEditingController controller;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        autofillHints: const [AutofillHints.oneTimeCode],
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
        onSubmitted: (_) => onSubmitted(),
        decoration: InputDecoration(labelText: identityL10n.codeHint),
      );
}

/// Seconds until another SMS may be asked for, ticking down.
mixin _ResendCooldown<T extends StatefulWidget> on State<T> {
  static const cooldown = Duration(seconds: 60);

  Timer? _timer;
  int resendIn = 0;

  void startCooldown() {
    _timer?.cancel();
    setState(() => resendIn = cooldown.inSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => resendIn--);
      if (resendIn <= 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class _PhoneStep extends ConsumerStatefulWidget {
  const _PhoneStep({required this.status});

  final SecurityStatus status;

  @override
  ConsumerState<_PhoneStep> createState() => _PhoneStepState();
}

class _PhoneStepState extends ConsumerState<_PhoneStep> with _ResendCooldown {
  final _number = TextEditingController();
  final _code = TextEditingController();
  bool _sent = false;
  bool _busy = false;
  String? _error;

  /// The dialling code is fixed by the server; the user types only the national number.
  String get _phone => '+${widget.status.callingCode}${_number.text.replaceFirst(RegExp('^0+'), '')}';

  @override
  void dispose() {
    _number.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_number.text.length < 6) {
      setState(() => _error = identityL10n.enterMobileNumber);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref.read(securityRepositoryProvider).startPhone(_phone);
    if (!mounted) return;
    switch (result) {
      case Ok():
        setState(() => _sent = true);
        startCooldown();
      case Err(:final failure):
        setState(() => _error = failure.userMessage);
        _reload(ref);
    }
    setState(() => _busy = false);
  }

  Future<void> _verify() async {
    if (_code.text.length != 6) {
      setState(() => _error = identityL10n.enterSmsCode);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref.read(securityRepositoryProvider).verifyPhone(_phone, _code.text);
    if (!mounted) return;
    if (result case Err(:final failure)) {
      setState(() {
        _busy = false;
        _error = failure.userMessage;
      });
      return;
    }
    await _offerFasterSignIn();
    if (mounted) _reload(ref);
  }

  /// The phone is verified: suggest a passkey or an authenticator app for the next sign-ins (§3h, 15.8d).
  Future<void> _offerFasterSignIn() async {
    final passkeys = ref.read(passkeyAuthenticatorProvider).isSupported;
    final choice = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialog) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: GwRadius.xlAll),
        icon: const Icon(Icons.verified_user_outlined),
        title: Text(identityL10n.speedUpTitle),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: GwLayout.formMaxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(passkeys
                  ? identityL10n.speedUpBodyPasskey
                  : identityL10n.speedUpBodyTotp),
              _gap,
              if (passkeys) ...[
                GwButton(
                  label: identityL10n.addFingerprint,
                  icon: Icons.fingerprint,
                  onPressed: () => Navigator.of(dialog).pop('passkey'),
                  expand: true,
                ),
                const SizedBox(height: GwSpacing.sm),
              ],
              GwButton(
                label: identityL10n.addAuthenticator,
                icon: Icons.phonelink_lock_outlined,
                variant: passkeys ? GwButtonVariant.secondary : GwButtonVariant.primary,
                onPressed: () => Navigator.of(dialog).pop('totp'),
                expand: true,
              ),
              GwButton(label: identityL10n.notNow, variant: GwButtonVariant.text, onPressed: () => Navigator.of(dialog).pop()),
            ],
          ),
        ),
      ),
    );
    if (!mounted) return;
    switch (choice) {
      case 'passkey':
        final error = await addPasskey(ref, refreshStatus: false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? identityL10n.fingerprintAdded)));
      case 'totp':
        await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const TotpSetupScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: identityL10n.verifyPhoneTitle,
      subtitle: identityL10n.verifyPhoneBody,
      children: [
        TextField(
          controller: _number,
          enabled: !_sent && !_busy,
          keyboardType: TextInputType.phone,
          autofillHints: const [AutofillHints.telephoneNumberNational],
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(14)],
          onSubmitted: (_) => _send(),
          decoration: InputDecoration(labelText: identityL10n.mobilePhone, prefixText: '+${widget.status.callingCode} '),
        ),
        _gap,
        if (_sent) ...[
          _CodeField(controller: _code, onSubmitted: _verify),
          _gap,
        ],
        if (_error != null) ...[GwFormMessage(_error!), _gap],
        if (!_sent)
          GwButton(label: identityL10n.sendCode, onPressed: _send, isLoading: _busy, expand: true)
        else ...[
          GwButton(label: identityL10n.verify, onPressed: _verify, isLoading: _busy, expand: true),
          const SizedBox(height: GwSpacing.sm),
          GwButton(
            label: resendIn > 0 ? identityL10n.resendCodeIn(resendIn) : identityL10n.resendCode,
            variant: GwButtonVariant.secondary,
            onPressed: resendIn > 0 || _busy ? null : _send,
            expand: true,
          ),
          GwButton(
            label: identityL10n.changeNumber,
            variant: GwButtonVariant.text,
            onPressed: _busy ? null : () => setState(() => _sent = false),
          ),
        ],
        _SignOutButton(enabled: !_busy),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _SecondFactorStep extends ConsumerStatefulWidget {
  const _SecondFactorStep({required this.status});

  final SecurityStatus status;

  @override
  ConsumerState<_SecondFactorStep> createState() => _SecondFactorStepState();
}

class _SecondFactorStepState extends ConsumerState<_SecondFactorStep> with _ResendCooldown {
  final _code = TextEditingController();

  /// Preference order: passkey, authenticator app, SMS (§3h, 15.8d).
  late final List<String> _methods = [
    if (widget.status.passkeyCount > 0 && ref.read(passkeyAuthenticatorProvider).isSupported) 'passkey',
    if (widget.status.totpEnabled) 'totp',
    'sms',
  ];
  late String _method = _methods.first;
  bool _sent = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref.read(securityRepositoryProvider).startSecondFactor();
    if (!mounted) return;
    switch (result) {
      case Ok():
        setState(() => _sent = true);
        startCooldown();
      case Err(:final failure):
        setState(() => _error = failure.userMessage);
        _reload(ref);
    }
    setState(() => _busy = false);
  }

  Future<void> _verifyPasskey() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final repo = ref.read(securityRepositoryProvider);
    final options = await repo.passkeyAssertionOptions();
    if (!mounted) return;
    final Result<SecurityStatus> result;
    switch (options) {
      case Ok(:final value):
        final response = await ref.read(passkeyAuthenticatorProvider).get(value);
        if (!mounted) return;
        if (response == null) {
          setState(() {
            _busy = false;
            _error = identityL10n.passkeyFailed;
          });
          return;
        }
        result = await repo.verifyPasskey(response);
      case Err(:final failure):
        result = Err(failure);
    }
    if (!mounted) return;
    if (result case Err(:final failure)) {
      setState(() {
        _busy = false;
        _error = failure.userMessage;
      });
      return;
    }
    _reload(ref);
  }

  Future<void> _verify() async {
    if (_code.text.length != 6) {
      setState(() => _error = identityL10n.enterCode);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref.read(securityRepositoryProvider).verifySecondFactor(_method, _code.text);
    if (!mounted) return;
    if (result case Err(:final failure)) {
      setState(() {
        _busy = false;
        _error = failure.userMessage;
      });
      return;
    }
    _reload(ref);
  }

  @override
  Widget build(BuildContext context) {
    final sms = _method == 'sms';
    final passkey = _method == 'passkey';
    return AuthLayout(
      title: identityL10n.verifySignInTitle,
      subtitle: switch (_method) {
        'passkey' => identityL10n.verifyWithPasskey,
        'totp' => identityL10n.verifyWithTotp,
        _ => (widget.status.phoneMasked == null ? identityL10n.smsWillSendSaved : identityL10n.smsWillSendTo(widget.status.phoneMasked!)),
      },
      children: [
        if (_methods.length > 1) ...[
          SegmentedButton<String>(
            segments: [
              for (final m in _methods)
                switch (m) {
                  'passkey' => ButtonSegment(value: 'passkey', label: Text(identityL10n.methodFingerprint), icon: const Icon(Icons.fingerprint)),
                  'totp' => ButtonSegment(value: 'totp', label: Text(identityL10n.methodApp), icon: const Icon(Icons.phonelink_lock_outlined)),
                  _ => const ButtonSegment(value: 'sms', label: Text('SMS'), icon: Icon(Icons.sms_outlined)),
                },
            ],
            selected: {_method},
            onSelectionChanged: _busy
                ? null
                : (v) => setState(() {
                      _method = v.single;
                      _error = null;
                      _code.clear();
                    }),
          ),
          _gap,
        ],
        if (!passkey && (!sms || _sent)) ...[
          _CodeField(controller: _code, onSubmitted: _verify),
          _gap,
        ],
        if (_error != null) ...[GwFormMessage(_error!), _gap],
        if (passkey)
          GwButton(
            label: identityL10n.verifyWithFingerprint,
            icon: Icons.fingerprint,
            onPressed: _verifyPasskey,
            isLoading: _busy,
            expand: true,
          )
        else if (sms && !_sent)
          GwButton(label: identityL10n.sendCode, onPressed: _send, isLoading: _busy, expand: true)
        else ...[
          GwButton(label: identityL10n.verify, onPressed: _verify, isLoading: _busy, expand: true),
          if (sms) ...[
            const SizedBox(height: GwSpacing.sm),
            GwButton(
              label: resendIn > 0 ? identityL10n.resendCodeIn(resendIn) : identityL10n.resendCode,
              variant: GwButtonVariant.secondary,
              onPressed: resendIn > 0 || _busy ? null : _send,
              expand: true,
            ),
          ],
        ],
        _SignOutButton(enabled: !_busy),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

/// The warning, without naming the exact signal (§3h, Kısıtlama).
class _RestrictedStep extends ConsumerWidget {
  const _RestrictedStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refreshing = ref.watch(securityStatusProvider).isLoading;
    return AuthLayout(
      title: identityL10n.reviewTitle,
      subtitle: identityL10n.reviewBody,
      children: [
        GwFormMessage(securityWarning),
        const SizedBox(height: GwSpacing.md),
        GwButton(
          label: identityL10n.refreshStatus,
          icon: Icons.refresh,
          isLoading: refreshing,
          onPressed: () => _reload(ref),
          expand: true,
        ),
        const SizedBox(height: GwSpacing.sm),
        const _SignOutButton(),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

/// Settings: the verified phone and the optional authenticator app.
class TwoFactorSettingsScreen extends ConsumerWidget {
  const TwoFactorSettingsScreen({super.key});

  Future<void> _remove(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: GwRadius.xlAll),
        title: Text(identityL10n.removeTotpTitle),
        content: Text(identityL10n.removeTotpBody),
        actions: [
          GwButton(label: identityL10n.cancel, variant: GwButtonVariant.text, onPressed: () => Navigator.of(dialog).pop(false)),
          GwButton(label: identityL10n.remove, onPressed: () => Navigator.of(dialog).pop(true)),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final result = await ref.read(securityRepositoryProvider).deleteTotp();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(switch (result) {
        Ok() => identityL10n.totpRemoved,
        Err(:final failure) => failure.userMessage,
      }),
    ));
    ref.invalidate(securityStatusProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(securityStatusProvider);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(identityL10n.twoFactorTitle)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(GwSpacing.page),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: GwLayout.formMaxWidth),
              child: switch (status) {
                AsyncData(value: final s?) => GwCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.sms_outlined),
                          title: Text(identityL10n.phoneNumber),
                          subtitle: Text(s.phoneMasked ?? identityL10n.notVerifiedYet),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.phonelink_lock_outlined),
                          title: Text(identityL10n.authenticatorApp),
                          subtitle: Text(s.totpEnabled
                              ? identityL10n.totpOn
                              : identityL10n.totpOff),
                        ),
                        const Divider(height: 1),
                        const _PasskeysSection(),
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(GwSpacing.md, GwSpacing.md, GwSpacing.md, GwSpacing.md),
                          child: s.totpEnabled
                              ? GwButton(
                                  label: identityL10n.remove,
                                  variant: GwButtonVariant.secondary,
                                  onPressed: () => _remove(context, ref),
                                  expand: true,
                                )
                              : GwButton(
                                  label: identityL10n.addTotp,
                                  icon: Icons.add,
                                  onPressed: () => Navigator.of(context)
                                      .push(MaterialPageRoute<void>(builder: (_) => const TotpSetupScreen())),
                                  expand: true,
                                ),
                        ),
                      ],
                    ),
                  ),
                AsyncError(:final error) => GwErrorState(
                    message: userMessageOf(error),
                    onRetry: () => ref.invalidate(securityStatusProvider),
                  ),
                AsyncData() => Text(identityL10n.signInRequired, style: textTheme.bodyMedium),
                _ => const GwSkeleton(height: GwSpacing.xxl * 3, borderRadius: GwRadius.lgAll),
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Settings: passkeys on this account, adding one on this device, removing one.
class _PasskeysSection extends ConsumerStatefulWidget {
  const _PasskeysSection();

  @override
  ConsumerState<_PasskeysSection> createState() => _PasskeysSectionState();
}

class _PasskeysSectionState extends ConsumerState<_PasskeysSection> {
  bool _busy = false;

  void _say(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _add() async {
    setState(() => _busy = true);
    final error = await addPasskey(ref);
    if (!mounted) return;
    setState(() => _busy = false);
    _say(error ?? identityL10n.fingerprintAdded);
  }

  Future<void> _remove(PasskeyView p) async {
    final result = await ref.read(securityRepositoryProvider).deletePasskey(p.id);
    if (!mounted) return;
    _say(switch (result) { Ok() => identityL10n.passkeyRemoved(p.name), Err(:final failure) => failure.userMessage });
    ref
      ..invalidate(passkeysProvider)
      ..invalidate(securityStatusProvider);
  }

  @override
  Widget build(BuildContext context) {
    final supported = ref.watch(passkeyAuthenticatorProvider).isSupported;
    final passkeys = ref.watch(passkeysProvider).value ?? const <PasskeyView>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          leading: const Icon(Icons.fingerprint),
          title: Text(identityL10n.passkeysTitle),
          subtitle: Text(passkeys.isEmpty
              ? identityL10n.passkeysOff
              : identityL10n.passkeysOn(passkeys.length)),
        ),
        for (final p in passkeys)
          ListTile(
            contentPadding: const EdgeInsetsDirectional.only(start: GwSpacing.xxl + GwSpacing.md, end: GwSpacing.xs),
            title: Text(p.name),
            subtitle: Text(p.lastUsedAt == null ? identityL10n.notUsedYet : identityL10n.lastUsed(formatDateTime(p.lastUsedAt!))),
            trailing: IconButton(
              tooltip: identityL10n.remove,
              icon: const Icon(Icons.delete_outline),
              onPressed: _busy ? null : () => _remove(p),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(GwSpacing.md, 0, GwSpacing.md, GwSpacing.md),
          child: supported
              ? GwButton(
                  label: identityL10n.addFingerprintHere,
                  icon: Icons.add,
                  variant: GwButtonVariant.secondary,
                  isLoading: _busy,
                  onPressed: _add,
                  expand: true,
                )
              : Text(
                  identityL10n.passkeyUnsupported,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: GwColors.textSecondary),
                ),
        ),
      ],
    );
  }
}

class TotpSetupScreen extends ConsumerStatefulWidget {
  const TotpSetupScreen({super.key});

  @override
  ConsumerState<TotpSetupScreen> createState() => _TotpSetupScreenState();
}

class _TotpSetupScreenState extends ConsumerState<TotpSetupScreen> {
  final _code = TextEditingController();
  late Future<Result<TotpSetup>> _setup = ref.read(securityRepositoryProvider).beginTotp();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_code.text.length != 6) {
      setState(() => _error = identityL10n.enterAppCode);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref.read(securityRepositoryProvider).confirmTotp(_code.text);
    if (!mounted) return;
    switch (result) {
      case Ok():
        ref.invalidate(securityStatusProvider);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(identityL10n.totpAdded)));
      case Err(:final failure):
        setState(() {
          _busy = false;
          _error = failure.userMessage;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(identityL10n.authenticatorApp)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(GwSpacing.page),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: GwLayout.formMaxWidth),
              child: FutureBuilder(
                future: _setup,
                builder: (context, snapshot) => switch (snapshot.data) {
                  null => const Center(child: CircularProgressIndicator()),
                  Err(:final failure) => GwErrorState(
                      message: failure.userMessage,
                      onRetry: () => setState(() => _setup = ref.read(securityRepositoryProvider).beginTotp()),
                    ),
                  Ok(value: final setup) => GwCard(
                      padding: const EdgeInsets.all(GwSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            identityL10n.totpStep1,
                            style: textTheme.bodyMedium,
                          ),
                          _gap,
                          Center(
                            child: QrImageView(
                              data: setup.uri,
                              size: GwSpacing.xxl * 4,
                              backgroundColor: GwColors.surface,
                            ),
                          ),
                          _gap,
                          SelectableText(
                            setup.secret.replaceAllMapped(RegExp('.{4}'), (m) => '${m[0]} ').trim(),
                            textAlign: TextAlign.center,
                            style: textTheme.titleMedium,
                          ),
                          const SizedBox(height: GwSpacing.sm),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: GwSpacing.xs,
                            children: [
                              GwButton(
                                label: identityL10n.copyKey,
                                icon: Icons.copy,
                                variant: GwButtonVariant.text,
                                onPressed: () => Clipboard.setData(ClipboardData(text: setup.secret)),
                              ),
                              if (!kIsWeb)
                                GwButton(
                                  label: identityL10n.openInApp,
                                  icon: Icons.open_in_new,
                                  variant: GwButtonVariant.text,
                                  onPressed: () => launchUrl(Uri.parse(setup.uri)),
                                ),
                            ],
                          ),
                          _gap,
                          Text(identityL10n.totpStep2, style: textTheme.bodyMedium),
                          const SizedBox(height: GwSpacing.sm),
                          _CodeField(controller: _code, onSubmitted: _confirm),
                          _gap,
                          if (_error != null) ...[GwFormMessage(_error!), _gap],
                          GwButton(label: identityL10n.activate, onPressed: _confirm, isLoading: _busy, expand: true),
                        ],
                      ),
                    ),
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

/// Sends a fresh location check when the app opens and whenever it comes back after 30 minutes
/// (docs/ARCHITECTURE.md §3h, Akış 6). Silent: a refused permission or a failed read only reloads the status,
/// and the server asks again once the last check is a day old.
class SecurityHeartbeat extends ConsumerStatefulWidget {
  const SecurityHeartbeat({super.key, required this.child, this.navigatorContext});

  final Widget child;

  /// The heartbeat sits above the app's navigator; warnings are shown in the context this returns.
  final BuildContext? Function()? navigatorContext;

  @override
  ConsumerState<SecurityHeartbeat> createState() => _SecurityHeartbeatState();
}

class _SecurityHeartbeatState extends ConsumerState<SecurityHeartbeat> with WidgetsBindingObserver {
  static const _interval = Duration(minutes: 30);

  DateTime? _lastSent;
  Timer? _timer;
  bool _running = false;

  /// Each warning once per app run, not every half hour.
  final _warned = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // On the first status of a launch or sign-in; not after the location step, which just sent one.
    ref.listenManual(securityStatusProvider, (previous, _) {
      if (previous?.value == null) _beat();
    });
    _timer = Timer.periodic(_interval, (_) => _beat());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _beat();
  }

  Future<void> _beat() async {
    final status = ref.read(securityStatusProvider).value;
    // Only sessions past the location step: the location screen does its own check.
    if (_running || status == null || !status.enforced) return;
    if (status.step == SecurityStep.location || status.step == SecurityStep.restricted) return;
    if (_lastSent case final last? when DateTime.now().difference(last) < _interval) return;

    _running = true;
    try {
      final source = ref.read(deviceSignalSourceProvider);
      if (!await source.hasPermission()) return;
      if (await source.read() case LocationRead(:final signals)) {
        _lastSent = DateTime.now();
        final result = await ref.read(securityRepositoryProvider).sendLocation(signals);
        if (!mounted) return;
        if (result case Ok(:final value)) {
          final fresh = value.warnings.where(_warned.add).toList();
          final context = widget.navigatorContext?.call();
          if (fresh.isNotEmpty && context != null && context.mounted) unawaited(showSecurityWarnings(context, fresh));
          if (value.step == status.step) return;
        }
        _reload(ref);
      }
    } finally {
      _running = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
