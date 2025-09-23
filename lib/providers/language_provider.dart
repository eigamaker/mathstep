import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localization/app_language.dart';

class LanguageState {
  const LanguageState({
    required this.language,
    required this.isInitialized,
    required this.hasSavedPreference,
  });

  final AppLanguage language;
  final bool isInitialized;
  final bool hasSavedPreference;

  LanguageState copyWith({
    AppLanguage? language,
    bool? isInitialized,
    bool? hasSavedPreference,
  }) {
    return LanguageState(
      language: language ?? this.language,
      isInitialized: isInitialized ?? this.isInitialized,
      hasSavedPreference: hasSavedPreference ?? this.hasSavedPreference,
    );
  }
}

class LanguageNotifier extends StateNotifier<LanguageState> {
  LanguageNotifier()
    : super(
        LanguageState(
          language: AppLanguage.defaultLanguage,
          isInitialized: false,
          hasSavedPreference: false,
        ),
      ) {
    _load();
  }

  static const _prefsKey = 'settings.languageCode';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code != null) {
      state = state.copyWith(
        language: AppLanguage.fromCode(code),
        isInitialized: true,
        hasSavedPreference: true,
      );
    } else {
      // 初回起動時は英語をデフォルトとして設定
      state = state.copyWith(
        language: AppLanguage.defaultLanguage,
        isInitialized: true,
        hasSavedPreference: false,
      );
    }
  }

  Future<void> loadLanguage() async {
    await _load();
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = state.copyWith(
      language: language,
      isInitialized: true,
      hasSavedPreference: true,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, language.code);
  }
}

final languageStateProvider =
    StateNotifierProvider<LanguageNotifier, LanguageState>((ref) {
      return LanguageNotifier();
    });

final localeProvider = Provider((ref) {
  return ref.watch(languageStateProvider).language.locale;
});

final appLanguageProvider = Provider((ref) {
  return ref.watch(languageStateProvider).language;
});
