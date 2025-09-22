import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ナビゲーション状態を管理するプロバイダー
class NavigationNotifier extends StateNotifier<int> {
  NavigationNotifier() : super(0);

  void setIndex(int index) {
    state = index;
  }

  void goToHome() {
    state = 0;
  }

  void goToHistory() {
    state = 1;
  }

  void goToSettings() {
    state = 2;
  }
}

final navigationProvider = StateNotifierProvider<NavigationNotifier, int>((ref) {
  return NavigationNotifier();
});
