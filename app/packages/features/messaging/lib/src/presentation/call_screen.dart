import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/call_keep_alive.dart';
import '../domain/calls.dart';
import '../l10n.dart';
import 'call_providers.dart';
import 'call_screens.dart';
import 'call_session.dart';

/// A one-to-one voice call (docs/ARCHITECTURE.md §8c): ringing out, ringing in, talking, ended.
/// The call row decides the state; [join] is the caller's room access from starting the call.
class CallScreen extends ConsumerStatefulWidget {
  const CallScreen({super.key, required this.callId, this.join, this.answer = false});

  final String callId;
  final CallJoin? join;

  /// Answered on the phone's own call screen: answer as soon as the call is seen ringing.
  final bool answer;

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  late final CallSession _session = ref.read(callSessionFactoryProvider)();
  late final CallRinger _ringer = ref.read(callRingerProvider);
  late final CallKeepAlive _keepAlive = ref.read(callKeepAliveProvider);
  late final CallScreens _screens = ref.read(callScreensProvider);
  bool _keptAlive = false;
  StreamSubscription<CallInfo?>? _subscription;
  Timer? _ticker;
  Timer? _closer;
  CallInfo? _call;
  bool _loaded = false;
  bool _busy = false;
  CallTone? _tone;
  bool _answered = false;

  /// The person answered somewhere else first: on the phone's own call screen, before or after this screen opened.
  late bool _answerWanted = widget.answer;
  String? _error;

  CallsRepository get _repo => ref.read(callsRepositoryProvider);

  String? get _me => ref.read(currentUserIdProvider);

  bool get _open => _call?.status.isOpen ?? false;

  @override
  void initState() {
    super.initState();
    _session.addListener(_rebuild);
    if (_screens.attach(widget.callId, _answerRequested)) _answerWanted = true;
    unawaited(_takeOverFromPhone());
    if (widget.join case final join?) unawaited(_session.connect(join));
    _subscription = _repo.watch(widget.callId).listen(_onCall, onError: (Object _) {
      if (mounted) setState(() => _error = messagingL10n.callInfoFailed);
    });
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_call?.status == CallStatus.active) _rebuild();
    });
  }

  /// This screen rings and shows the call now; the phone's own screen or ongoing notice closes. An answer given there
  /// first is kept, so the person is not asked to answer again.
  Future<void> _takeOverFromPhone() async {
    final native = ref.read(nativeCallsProvider);
    try {
      if (await native.answered(widget.callId)) _answerRequested();
    } on Object catch (_) {
      // Unknown: the screen asks as usual.
    }
    await native.end(widget.callId).catchError((Object _) {});
  }

  /// Answered on the phone's own call screen while this screen was already open or opening.
  void _answerRequested() {
    _answerWanted = true;
    if (_call case final call?) _onCall(call);
  }

  void _rebuild() {
    _syncKeepAlive();
    if (mounted) setState(() {});
  }

  /// While the audio is connected the call goes on in the background too (docs/ARCHITECTURE.md §8c, Arka planda
  /// görüşme). Started only here, with the screen in front, as Android requires.
  void _syncKeepAlive() {
    final want = _open && _session.connection == CallConnection.connected;
    if (want == _keptAlive) return;
    _keptAlive = want;
    unawaited((want ? _keepAlive.start() : _keepAlive.stop()).catchError((Object e) {
      debugPrint('Call keep-alive failed: $e');
    }));
  }

  /// The back button leaves the call running: the app goes to the background, or the person is told how to end it.
  Future<void> _leaveScreen() async {
    final moved = await _keepAlive.toBackground().catchError((Object _) => false);
    if (moved || !mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(messagingL10n.tapEndToHangUp)));
  }

  void _onCall(CallInfo? call) {
    if (!mounted) return;
    setState(() {
      _call = call;
      _loaded = true;
    });
    _syncKeepAlive();
    final me = _me;
    if (call == null || !call.status.isOpen) {
      _setTone(null);
      unawaited(_session.leave());
      _closer ??= Timer(const Duration(seconds: 3), () {
        if (mounted) unawaited(Navigator.of(context).maybePop());
      });
      return;
    }
    if (_answerWanted && !_answered && call.status == CallStatus.ringing && call.calleeId == me) {
      _answered = true;
      unawaited(_accept());
      return;
    }
    _setTone(switch (call.status) {
      CallStatus.ringing when call.calleeId == me => CallTone.incoming,
      CallStatus.ringing when call.callerId == me => CallTone.outgoing,
      _ => null,
    });
    // Back on a call this device is not connected to: the caller while ringing, either person while talking.
    final mayJoin = call.callerId == me || call.status == CallStatus.active;
    if (mayJoin && _session.connection == CallConnection.idle && !_busy) unawaited(_rejoin());
  }

  void _setTone(CallTone? tone) {
    if (tone == _tone) return;
    final wasPlaying = _tone != null;
    _tone = tone;
    // A tone that cannot play must not stop the call.
    unawaited(() async {
      if (wasPlaying) await _ringer.stop();
      if (tone != null) await _ringer.start(tone);
    }().catchError((Object _) {}));
  }

  Future<void> _run(Future<Result<CallJoin?>> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await action();
    if (!mounted) return;
    setState(() => _busy = false);
    switch (result) {
      case Ok(:final value?):
        await _session.connect(value);
      case Ok():
        break;
      case Err(:final failure):
        setState(() => _error = failure.userMessage);
    }
  }

  Future<void> _rejoin() => _run(() => _repo.rejoin(widget.callId));

  Future<void> _accept() {
    _answered = true;
    _setTone(null);
    return _run(() => _repo.accept(widget.callId));
  }

  Future<void> _decline() => _run(() async => (await _repo.decline(widget.callId)).map((_) => null));

  Future<void> _hangUp() => _run(() async => (await _repo.end(widget.callId)).map((_) => null));

  Future<void> _toggleMic() async {
    final message = await _session.setMicrophone(!_session.micOn);
    if (message != null && mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _screens.detach(widget.callId, _answerRequested);
    unawaited(_subscription?.cancel());
    _ticker?.cancel();
    _closer?.cancel();
    if (_tone != null) unawaited(_ringer.stop().catchError((Object _) {}));
    if (_keptAlive) unawaited(_keepAlive.stop().catchError((Object _) {}));
    _session
      ..removeListener(_rebuild)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final call = _call;
    final me = _me;
    return PopScope(
      // Back never ends an open call: only Bitir and Reddet do (docs/ARCHITECTURE.md §8c).
      canPop: !_open,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_leaveScreen());
      },
      child: Scaffold(
        appBar: AppBar(automaticallyImplyLeading: !_open),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: GwLayout.formMaxWidth),
              child: Padding(
                padding: const EdgeInsets.all(GwSpacing.lg),
                child: switch (call) {
                  null when !_loaded => const Center(child: CircularProgressIndicator()),
                  null => GwEmptyState(
                      icon: Icons.call_end_outlined,
                      message: _error ?? messagingL10n.callNotFound,
                      actionLabel: messagingL10n.close,
                      onAction: () => Navigator.of(context).maybePop(),
                    ),
                  // Scrolls on a small screen or with large text; the spacers fill a tall one.
                  _ => LayoutBuilder(
                      builder: (context, constraints) => SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: constraints.maxHeight),
                          child: IntrinsicHeight(child: _content(call, me ?? '')),
                        ),
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

  Widget _content(CallInfo call, String me) {
    final textTheme = Theme.of(context).textTheme;
    final secondary = textTheme.bodyLarge?.copyWith(color: GwColors.textSecondary);
    final incoming = call.calleeId == me;
    final peer = ref.watch(callPeerProvider(call.peerOf(me))).value;
    return Column(
      children: [
        const Spacer(),
        GwAvatar(
          name: peer?.displayName ?? '',
          shape: GwAvatarShape.user,
          imageUrl: peer?.avatarUrl,
          size: GwAvatarSize.xxl,
        ),
        const SizedBox(height: GwSpacing.lg),
        Text(peer?.displayName ?? '', style: textTheme.headlineSmall, textAlign: TextAlign.center),
        if (peer != null) Text(atName(peer.username), style: secondary, textAlign: TextAlign.center),
        const SizedBox(height: GwSpacing.md),
        Text(_statusText(call, me), style: textTheme.titleMedium, textAlign: TextAlign.center),
        if (call.status == CallStatus.active)
          Padding(
            padding: const EdgeInsets.only(top: GwSpacing.xxs),
            child: Text(messagingL10n.callLimitNote(CallRules.maxLength.inMinutes),
                style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary), textAlign: TextAlign.center),
          ),
        if (call.status == CallStatus.active && _session.connection == CallConnection.connected) ...[
          const SizedBox(height: GwSpacing.md),
          _EncryptionNote(session: _session),
        ],
        if (_error != null || _session.connection == CallConnection.failed) ...[
          const SizedBox(height: GwSpacing.md),
          GwFormMessage(_error ?? messagingL10n.audioFailed),
          if (_session.connection == CallConnection.failed && call.status.isOpen)
            GwButton(label: messagingL10n.reconnect, variant: GwButtonVariant.text, onPressed: _busy ? null : _rejoin),
        ],
        const Spacer(),
        _actions(call, incoming),
        const SizedBox(height: GwSpacing.xl),
      ],
    );
  }

  String _statusText(CallInfo call, String me) => switch (call.status) {
        CallStatus.ringing when call.calleeId == me => messagingL10n.incoming,
        CallStatus.ringing => messagingL10n.calling,
        CallStatus.active when _session.connection != CallConnection.connected => messagingL10n.connecting,
        CallStatus.active => _clock(DateTime.now().difference(call.answeredAt ?? call.createdAt)),
        _ => call.endedText(me),
      };

  static String _clock(Duration d) {
    final s = d.isNegative ? Duration.zero : d;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(s.inMinutes)}:${two(s.inSeconds % 60)}';
  }

  Widget _actions(CallInfo call, bool incoming) {
    if (!call.status.isOpen) {
      return GwButton(label: messagingL10n.close, variant: GwButtonVariant.secondary, onPressed: () => Navigator.of(context).maybePop());
    }
    if (incoming && call.status == CallStatus.ringing) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _RoundAction(icon: Icons.call_end, label: messagingL10n.decline, color: GwColors.error, onPressed: _busy ? null : _decline),
          _RoundAction(icon: Icons.call, label: messagingL10n.answer, color: GwColors.success, onPressed: _busy ? null : _accept),
        ],
      );
    }
    final talking = call.status == CallStatus.active;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (talking)
          _RoundAction(
            icon: _session.micOn ? Icons.mic : Icons.mic_off,
            label: _session.micOn ? messagingL10n.mute : messagingL10n.unmute,
            color: _session.micOn ? GwColors.surfaceMuted : GwColors.textPrimary,
            foreground: _session.micOn ? GwColors.textPrimary : GwColors.onPrimary,
            onPressed: _toggleMic,
          ),
        _RoundAction(icon: Icons.call_end, label: messagingL10n.end, color: GwColors.error, onPressed: _busy ? null : _hangUp),
        if (talking)
          _RoundAction(
            icon: _session.speakerOn ? Icons.volume_up : Icons.volume_down_outlined,
            label: messagingL10n.speaker,
            color: _session.speakerOn ? GwColors.textPrimary : GwColors.surfaceMuted,
            foreground: _session.speakerOn ? GwColors.onPrimary : GwColors.textPrimary,
            onPressed: () => _session.setSpeaker(!_session.speakerOn),
          ),
      ],
    );
  }
}

/// Whether the sound is end-to-end encrypted and the two phones checked each other's keys (docs/ARCHITECTURE.md §8c,
/// Güvenlik kodu). The phones compare the safety code themselves; the code stays hidden unless asked for.
class _EncryptionNote extends StatefulWidget {
  const _EncryptionNote({required this.session});

  final CallSession session;

  @override
  State<_EncryptionNote> createState() => _EncryptionNoteState();
}

class _EncryptionNoteState extends State<_EncryptionNote> {
  bool _showCode = false;

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final textTheme = Theme.of(context).textTheme;
    final secondary = textTheme.bodySmall?.copyWith(color: GwColors.textSecondary);
    if (session.peerUnencrypted) return GwFormMessage(messagingL10n.peerUnencrypted);
    final code = session.safetyCode;
    if (!session.secure || code == null) {
      return Text(messagingL10n.encrypting, style: secondary, textAlign: TextAlign.center);
    }
    return switch (session.check) {
      CallCheck.waiting => Text(messagingL10n.callVerifying, style: secondary, textAlign: TextAlign.center),
      CallCheck.mismatch => GwFormMessage(messagingL10n.callCheckFailed),
      CallCheck.verified => _verified(textTheme, code),
      CallCheck.unconfirmed => _unconfirmed(textTheme, code),
    };
  }

  /// Green: both phones hold the same keys.
  Widget _verified(TextTheme textTheme, String code) => Semantics(
        container: true,
        label: messagingL10n.callSecure,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: GwColors.successSoft,
            borderRadius: GwRadius.lgAll,
            border: Border.all(color: GwColors.success.withValues(alpha: 0.24)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: GwSpacing.md, vertical: GwSpacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_user, size: GwSpacing.lg, color: GwColors.success),
                    const SizedBox(width: GwSpacing.xs),
                    Flexible(
                      child: Text(
                        messagingL10n.callSecure,
                        style: textTheme.titleSmall?.copyWith(color: GwColors.success, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: GwSpacing.xxs),
                Text(
                  messagingL10n.callSecureDetail,
                  style: textTheme.bodySmall?.copyWith(color: GwColors.textPrimary),
                  textAlign: TextAlign.center,
                ),
                _codeToggle(textTheme, code),
              ],
            ),
          ),
        ),
      );

  /// The other phone cannot confirm (an older version): encrypted, and the code can be compared by eye.
  Widget _unconfirmed(TextTheme textTheme, String code) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: GwSpacing.md, color: GwColors.success),
              const SizedBox(width: GwSpacing.xxs),
              Text(messagingL10n.e2ee, style: textTheme.labelLarge?.copyWith(color: GwColors.success)),
            ],
          ),
          _codeToggle(textTheme, code),
        ],
      );

  Widget _codeToggle(TextTheme textTheme, String code) {
    if (!_showCode) {
      return TextButton(
        onPressed: () => setState(() => _showCode = true),
        child: Text(messagingL10n.showSecurityCode),
      );
    }
    return Semantics(
      label: messagingL10n.e2eeCode(code),
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.only(top: GwSpacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(code, style: textTheme.titleMedium, textAlign: TextAlign.center),
            Text(
              messagingL10n.codeMatchHint,
              style: textTheme.bodySmall?.copyWith(color: GwColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
    this.foreground = GwColors.onPrimary,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color foreground;
  final VoidCallback? onPressed;

  static const double _size = GwSpacing.xxl + GwSpacing.md;

  /// The circle and its label are one touch target.
  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        enabled: onPressed != null,
        label: label,
        excludeSemantics: true,
        child: InkWell(
          onTap: onPressed,
          borderRadius: GwRadius.lgAll,
          child: Padding(
            padding: const EdgeInsets.all(GwSpacing.xxs),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DecoratedBox(
                  decoration: ShapeDecoration(
                    color: onPressed == null ? color.withValues(alpha: 0.5) : color,
                    shape: const CircleBorder(),
                  ),
                  child: SizedBox.square(dimension: _size, child: Icon(icon, color: foreground)),
                ),
                const SizedBox(height: GwSpacing.xs),
                Text(label, style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
          ),
        ),
      );
}
