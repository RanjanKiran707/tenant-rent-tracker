import 'package:flutter/foundation.dart';

/// The three welcome pages. [onFinish] runs when the user taps "Let's start"
/// or "Skip" (it marks the guide as seen, or just closes it when it was
/// opened again from Settings).
class WelcomeViewModel {
  static const int pageCount = 3;

  final Future<void> Function() _onFinish;

  /// 0-based page.
  final ValueNotifier<int> page = ValueNotifier(0);

  WelcomeViewModel({required Future<void> Function() onFinish})
      : _onFinish = onFinish;

  bool get isLast => page.value == pageCount - 1;

  void next() {
    if (!isLast) page.value = page.value + 1;
  }

  Future<void> finish() => _onFinish();

  void dispose() => page.dispose();
}
