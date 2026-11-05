import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/auth.dart';
import '../l10n.dart';
import 'auth_layout.dart';
import 'providers.dart';
import 'routes.dart';
import 'validators.dart';

/// Runs a repository call with loading and error state for a form screen.
mixin _Submitting<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  bool loading = false;
  String? error;

  Future<bool> submit(Future<Result<void>> Function() action) async {
    setState(() {
      loading = true;
      error = null;
    });
    final result = await action();
    if (!mounted) return false;
    setState(() {
      loading = false;
      error = switch (result) {
        Ok() => null,
        Err(:final failure) => failure.userMessage,
      };
    });
    return result is Ok;
  }
}

class _PasswordField extends StatefulWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.validator,
    this.autofillHints = const [AutofillHints.password],
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final FormFieldValidator<String> validator;
  final Iterable<String> autofillHints;
  final VoidCallback? onSubmitted;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscured,
      autofillHints: widget.autofillHints,
      validator: widget.validator,
      onFieldSubmitted: (_) => widget.onSubmitted?.call(),
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: IconButton(
          tooltip: _obscured ? identityL10n.showPassword : identityL10n.hidePassword,
          icon: Icon(_obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          onPressed: () => setState(() => _obscured = !_obscured),
        ),
      ),
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      autofillHints: const [AutofillHints.email],
      autocorrect: false,
      validator: validateEmail,
      decoration: InputDecoration(labelText: identityL10n.email),
    );
  }
}

const _gap = SizedBox(height: GwSpacing.md);

// ---------------------------------------------------------------------------

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({
    super.key,
    this.title,
    this.subtitle,
    this.allowSignUp = true,
    this.allowSocial = true,
  });

  /// Defaults to the localized "Giriş yap" and its subtitle.
  final String? title;
  final String? subtitle;
  final bool allowSignUp;
  final bool allowSocial;

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> with _Submitting {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_form.currentState!.validate()) return;
    await submit(
      () => ref.read(authRepositoryProvider).signIn(email: _email.text, password: _password.text),
    );
  }

  Future<void> _social(SocialProvider provider) =>
      submit(() => ref.read(authRepositoryProvider).signInWith(provider));

  @override
  Widget build(BuildContext context) {
    // No button until the server says which providers it serves (a button that cannot work is worse than none).
    final social = widget.allowSocial ? ref.watch(socialProvidersProvider).value ?? const <SocialProvider>{} : const <SocialProvider>{};
    return AuthLayout(
      title: widget.title ?? identityL10n.signIn,
      subtitle: widget.subtitle ?? identityL10n.signInSubtitle,
      showPitch: widget.allowSignUp,
      children: [
        Form(
          key: _form,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _EmailField(controller: _email),
                _gap,
                _PasswordField(
                  controller: _password,
                  label: identityL10n.password,
                  validator: validatePasswordPresent,
                  onSubmitted: _signIn,
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: GwButton(
            label: identityL10n.forgotPassword,
            variant: GwButtonVariant.text,
            onPressed: loading ? null : () => context.push(IdentityRoutes.forgotPassword),
          ),
        ),
        if (error != null) ...[GwFormMessage(error!), _gap],
        GwButton(label: identityL10n.signIn, onPressed: _signIn, isLoading: loading, expand: true),
        if (widget.allowSocial && social.isNotEmpty) ...[
          const SizedBox(height: GwSpacing.lg),
          LabeledDivider(identityL10n.or),
          const SizedBox(height: GwSpacing.lg),
          if (social.contains(SocialProvider.google))
            GwButton(
              label: identityL10n.continueWithGoogle,
              icon: Icons.g_mobiledata,
              variant: GwButtonVariant.secondary,
              expand: true,
              onPressed: loading ? null : () => _social(SocialProvider.google),
            ),
          if (social.length == 2) const SizedBox(height: GwSpacing.sm),
          if (social.contains(SocialProvider.apple))
            GwButton(
              label: identityL10n.continueWithApple,
              icon: Icons.apple,
              variant: GwButtonVariant.secondary,
              expand: true,
              onPressed: loading ? null : () => _social(SocialProvider.apple),
            ),
        ],
        if (widget.allowSignUp) ...[
          const SizedBox(height: GwSpacing.lg),
          GwButton(
            label: identityL10n.noAccountSignUp,
            variant: GwButtonVariant.text,
            onPressed: loading ? null : () => context.go(IdentityRoutes.signUp),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> with _Submitting {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_form.currentState!.validate()) return;
    final ok = await submit(
      () => ref.read(authRepositoryProvider).signUp(email: _email.text, password: _password.text),
    );
    if (ok && mounted) {
      context.go(
        Uri(path: IdentityRoutes.checkEmail, queryParameters: {'email': _email.text.trim()}).toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: identityL10n.signUp,
      subtitle: identityL10n.signUpSubtitle,
      showPitch: true,
      children: [
        Form(
          key: _form,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _EmailField(controller: _email),
                _gap,
                _PasswordField(
                  controller: _password,
                  label: identityL10n.password,
                  validator: validateNewPassword,
                  autofillHints: const [AutofillHints.newPassword],
                ),
                _gap,
                _PasswordField(
                  controller: _confirm,
                  label: identityL10n.passwordRepeat,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: (v) => v == _password.text ? null : identityL10n.passwordsDontMatch,
                  onSubmitted: _signUp,
                ),
              ],
            ),
          ),
        ),
        _gap,
        if (error != null) ...[GwFormMessage(error!), _gap],
        GwButton(label: identityL10n.signUp, onPressed: _signUp, isLoading: loading, expand: true),
        const SizedBox(height: GwSpacing.lg),
        GwButton(
          label: identityL10n.haveAccountSignIn,
          variant: GwButtonVariant.text,
          onPressed: loading ? null : () => context.go(IdentityRoutes.signIn),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class CheckEmailScreen extends ConsumerStatefulWidget {
  const CheckEmailScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<CheckEmailScreen> createState() => _CheckEmailScreenState();
}

class _CheckEmailScreenState extends ConsumerState<CheckEmailScreen> with _Submitting {
  bool _resent = false;

  Future<void> _resend() async {
    final ok = await submit(() => ref.read(authRepositoryProvider).resendVerification(widget.email));
    if (ok && mounted) setState(() => _resent = true);
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: identityL10n.checkEmailTitle,
      subtitle: identityL10n.checkEmailBody(widget.email),
      children: [
        if (_resent) ...[
          GwFormMessage(identityL10n.linkResent, kind: GwFormMessageKind.info),
          _gap,
        ],
        if (error != null) ...[GwFormMessage(error!), _gap],
        GwButton(label: identityL10n.backToSignIn, onPressed: () => context.go(IdentityRoutes.signIn), expand: true),
        const SizedBox(height: GwSpacing.sm),
        GwButton(
          label: identityL10n.resendLink,
          variant: GwButtonVariant.secondary,
          onPressed: _resend,
          isLoading: loading,
          expand: true,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> with _Submitting {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_form.currentState!.validate()) return;
    final ok = await submit(() => ref.read(authRepositoryProvider).sendPasswordReset(_email.text));
    if (ok && mounted) setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: identityL10n.resetPasswordTitle,
      subtitle: identityL10n.resetPasswordSubtitle,
      children: [
        Form(key: _form, child: _EmailField(controller: _email)),
        _gap,
        if (_sent) ...[
          GwFormMessage(
            identityL10n.resetLinkSent,
            kind: GwFormMessageKind.info,
          ),
          _gap,
        ],
        if (error != null) ...[GwFormMessage(error!), _gap],
        GwButton(label: identityL10n.sendLink, onPressed: _send, isLoading: loading, expand: true),
        const SizedBox(height: GwSpacing.sm),
        GwButton(
          label: identityL10n.backToSignIn,
          variant: GwButtonVariant.text,
          onPressed: () => context.go(IdentityRoutes.signIn),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

/// Shown after the user opens a password reset link.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> with _Submitting {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final ok = await submit(() => ref.read(authRepositoryProvider).updatePassword(_password.text));
    if (ok) ref.read(passwordRecoveryProvider.notifier).complete();
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: identityL10n.newPasswordTitle,
      children: [
        Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PasswordField(
                controller: _password,
                label: identityL10n.newPassword,
                validator: validateNewPassword,
                autofillHints: const [AutofillHints.newPassword],
              ),
              _gap,
              _PasswordField(
                controller: _confirm,
                label: identityL10n.newPasswordRepeat,
                autofillHints: const [AutofillHints.newPassword],
                validator: (v) => v == _password.text ? null : identityL10n.passwordsDontMatch,
                onSubmitted: _save,
              ),
            ],
          ),
        ),
        _gap,
        if (error != null) ...[GwFormMessage(error!), _gap],
        GwButton(label: identityL10n.savePassword, onPressed: _save, isLoading: loading, expand: true),
      ],
    );
  }
}
