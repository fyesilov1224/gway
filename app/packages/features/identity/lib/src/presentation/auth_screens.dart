import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/auth.dart';
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
          tooltip: _obscured ? 'Şifreyi göster' : 'Şifreyi gizle',
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
      decoration: const InputDecoration(labelText: 'E-posta'),
    );
  }
}

const _gap = SizedBox(height: GxSpacing.md);

// ---------------------------------------------------------------------------

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({
    super.key,
    this.title = 'Giriş yap',
    this.subtitle = 'Gruplarına ve arkadaşlarına kaldığın yerden devam et.',
    this.allowSignUp = true,
    this.allowSocial = true,
  });

  final String title;
  final String subtitle;
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
    return AuthLayout(
      title: widget.title,
      subtitle: widget.subtitle,
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
                  label: 'Şifre',
                  validator: validatePasswordPresent,
                  onSubmitted: _signIn,
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: GxButton(
            label: 'Şifremi unuttum',
            variant: GxButtonVariant.text,
            onPressed: loading ? null : () => context.push(IdentityRoutes.forgotPassword),
          ),
        ),
        if (error != null) ...[GxFormMessage(error!), _gap],
        GxButton(label: 'Giriş yap', onPressed: _signIn, isLoading: loading, expand: true),
        if (widget.allowSocial) ...[
          const SizedBox(height: GxSpacing.lg),
          const LabeledDivider('veya'),
          const SizedBox(height: GxSpacing.lg),
          GxButton(
            label: 'Google ile devam et',
            icon: Icons.g_mobiledata,
            variant: GxButtonVariant.secondary,
            expand: true,
            onPressed: loading ? null : () => _social(SocialProvider.google),
          ),
          const SizedBox(height: GxSpacing.sm),
          GxButton(
            label: 'Apple ile devam et',
            icon: Icons.apple,
            variant: GxButtonVariant.secondary,
            expand: true,
            onPressed: loading ? null : () => _social(SocialProvider.apple),
          ),
        ],
        if (widget.allowSignUp) ...[
          const SizedBox(height: GxSpacing.lg),
          GxButton(
            label: 'Hesabın yok mu? Kayıt ol',
            variant: GxButtonVariant.text,
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
      title: 'Kayıt ol',
      subtitle: 'Gruplarını bul, organizasyonlara katıl, yeni insanlarla tanış.',
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
                  label: 'Şifre',
                  validator: validateNewPassword,
                  autofillHints: const [AutofillHints.newPassword],
                ),
                _gap,
                _PasswordField(
                  controller: _confirm,
                  label: 'Şifre (tekrar)',
                  autofillHints: const [AutofillHints.newPassword],
                  validator: (v) => v == _password.text ? null : 'Şifreler eşleşmiyor.',
                  onSubmitted: _signUp,
                ),
              ],
            ),
          ),
        ),
        _gap,
        if (error != null) ...[GxFormMessage(error!), _gap],
        GxButton(label: 'Kayıt ol', onPressed: _signUp, isLoading: loading, expand: true),
        const SizedBox(height: GxSpacing.lg),
        GxButton(
          label: 'Zaten hesabın var mı? Giriş yap',
          variant: GxButtonVariant.text,
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
      title: 'E-postanı kontrol et',
      subtitle: '${widget.email} adresine bir doğrulama bağlantısı gönderdik. '
          'Bağlantıya tıkladıktan sonra giriş yapabilirsin.',
      children: [
        if (_resent) ...[
          const GxFormMessage('Bağlantıyı yeniden gönderdik.', kind: GxFormMessageKind.info),
          _gap,
        ],
        if (error != null) ...[GxFormMessage(error!), _gap],
        GxButton(label: 'Girişe dön', onPressed: () => context.go(IdentityRoutes.signIn), expand: true),
        const SizedBox(height: GxSpacing.sm),
        GxButton(
          label: 'Bağlantıyı tekrar gönder',
          variant: GxButtonVariant.secondary,
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
      title: 'Şifreni sıfırla',
      subtitle: 'E-posta adresini gir, sana şifre sıfırlama bağlantısı gönderelim.',
      children: [
        Form(key: _form, child: _EmailField(controller: _email)),
        _gap,
        if (_sent) ...[
          const GxFormMessage(
            'Bu adrese kayıtlı bir hesap varsa sıfırlama bağlantısını gönderdik.',
            kind: GxFormMessageKind.info,
          ),
          _gap,
        ],
        if (error != null) ...[GxFormMessage(error!), _gap],
        GxButton(label: 'Bağlantı gönder', onPressed: _send, isLoading: loading, expand: true),
        const SizedBox(height: GxSpacing.sm),
        GxButton(
          label: 'Girişe dön',
          variant: GxButtonVariant.text,
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
      title: 'Yeni şifre belirle',
      children: [
        Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PasswordField(
                controller: _password,
                label: 'Yeni şifre',
                validator: validateNewPassword,
                autofillHints: const [AutofillHints.newPassword],
              ),
              _gap,
              _PasswordField(
                controller: _confirm,
                label: 'Yeni şifre (tekrar)',
                autofillHints: const [AutofillHints.newPassword],
                validator: (v) => v == _password.text ? null : 'Şifreler eşleşmiyor.',
                onSubmitted: _save,
              ),
            ],
          ),
        ),
        _gap,
        if (error != null) ...[GxFormMessage(error!), _gap],
        GxButton(label: 'Şifreyi kaydet', onPressed: _save, isLoading: loading, expand: true),
      ],
    );
  }
}
