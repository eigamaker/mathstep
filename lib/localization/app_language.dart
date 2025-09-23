import 'package:flutter/material.dart';

class AppLanguage {
  const AppLanguage({
    required this.code,
    required this.locale,
    required this.nativeName,
    required this.englishName,
    required this.chatGptLanguageName,
  });

  final String code;
  final Locale locale;
  final String nativeName;
  final String englishName;
  final String chatGptLanguageName;

  static const List<AppLanguage> supportedLanguages = [
    AppLanguage(
      code: 'ja',
      locale: Locale('ja'),
      nativeName: '日本語',
      englishName: 'Japanese',
      chatGptLanguageName: 'Japanese',
    ),
    AppLanguage(
      code: 'en',
      locale: Locale('en'),
      nativeName: 'English',
      englishName: 'English',
      chatGptLanguageName: 'English',
    ),
    AppLanguage(
      code: 'ko',
      locale: Locale('ko'),
      nativeName: '한국어',
      englishName: 'Korean',
      chatGptLanguageName: 'Korean',
    ),
    AppLanguage(
      code: 'zh_CN',
      locale: Locale('zh', 'CN'),
      nativeName: '简体中文',
      englishName: 'Simplified Chinese',
      chatGptLanguageName: 'Simplified Chinese',
    ),
    AppLanguage(
      code: 'zh_TW',
      locale: Locale('zh', 'TW'),
      nativeName: '繁體中文',
      englishName: 'Traditional Chinese',
      chatGptLanguageName: 'Traditional Chinese',
    ),
  ];

  static AppLanguage get defaultLanguage =>
      supportedLanguages.firstWhere((language) => language.code == 'en');

  static AppLanguage fromCode(String code) {
    return supportedLanguages.firstWhere(
      (language) => language.code == code,
      orElse: () => defaultLanguage,
    );
  }
}
