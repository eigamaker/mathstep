import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/keypad_layout_mode.dart';

final keypadSettingsProvider =
    StateNotifierProvider<KeypadSettingsNotifier, KeypadLayoutMode>(
      (ref) => KeypadSettingsNotifier(),
    );

class KeypadSettingsNotifier extends StateNotifier<KeypadLayoutMode> {
  KeypadSettingsNotifier() : super(KeypadLayoutMode.flick) {
    _load();
  }

  static const String _storageKey = 'calculator_keypad_layout_mode';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_storageKey);
    final mode = KeypadLayoutModeX.fromName(stored);
    if (mode != null) {
      state = mode;
    }
  }

  Future<void> setMode(KeypadLayoutMode mode) async {
    if (state == mode) {
      return;
    }
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, mode.name);
  }
}
