import 'package:flutter/foundation.dart';

/// One call screen per call (docs/ARCHITECTURE.md §8c, Gelen arama). The ringing push, the in-app listener and the
/// phone's own call screen can all ask to open it, a fraction of a second apart; the router only learns about a new
/// screen after a frame, so it cannot tell. An answer for a call whose screen is open or opening goes to that screen
/// instead of a second one.
class CallScreens {
  final _slots = <String, _Slot>{};

  /// A screen asked for that never came up (e.g. the router sent the person elsewhere) stops blocking after this.
  static const _openingFor = Duration(seconds: 5);

  /// True when a screen for [callId] should be opened now. False when one is open or opening; [answer] then reaches it.
  bool claim(String callId, {bool answer = false}) {
    final slot = _slots[callId];
    if (slot != null && (slot.onAnswer != null || DateTime.now().difference(slot.claimedAt) < _openingFor)) {
      if (answer) slot.answer();
      return false;
    }
    _slots[callId] = _Slot()..answerWanted = answer;
    return true;
  }

  /// The screen for [callId] is up; [onAnswer] runs when an answer comes in for it. Returns whether one is waiting.
  bool attach(String callId, VoidCallback onAnswer) {
    final slot = _slots.putIfAbsent(callId, _Slot.new)..onAnswer = onAnswer;
    return slot.answerWanted;
  }

  void detach(String callId, VoidCallback onAnswer) {
    if (_slots[callId]?.onAnswer == onAnswer) _slots.remove(callId);
  }
}

class _Slot {
  final claimedAt = DateTime.now();
  bool answerWanted = false;
  VoidCallback? onAnswer;

  void answer() {
    answerWanted = true;
    onAnswer?.call();
  }
}
