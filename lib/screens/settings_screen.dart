import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_colors.dart';
import '../localization/localization_extensions.dart';
import '../localization/app_language.dart';
import '../models/keypad_layout_mode.dart';
import '../providers/keypad_settings_provider.dart';
import '../providers/language_provider.dart';

enum _LegalDocument { privacyPolicy, termsOfService }

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with TickerProviderStateMixin {
  static const Map<String, String> _privacyPolicyUrls = {
    'en': 'https://mathstep.profilecode.codes/privacy-en.html',
    'ja': 'https://mathstep.profilecode.codes/privacy-ja.html',
    'ko': 'https://mathstep.profilecode.codes/privacy-ko.html',
    'zh_CN': 'https://mathstep.profilecode.codes/privacy-zh-cn.html',
    'zh_TW': 'https://mathstep.profilecode.codes/privacy-zh-tw.html',
  };

  static const Map<String, String> _termsOfServiceUrls = {
    'en': 'https://mathstep.profilecode.codes/eula-en.html',
    'ja': 'https://mathstep.profilecode.codes/eula-ja.html',
    'ko': 'https://mathstep.profilecode.codes/eula-ko.html',
    'zh_CN': 'https://mathstep.profilecode.codes/eula-zh-cn.html',
    'zh_TW': 'https://mathstep.profilecode.codes/eula-zh-tw.html',
  };

  bool _isLanguageDropdownOpen = false;
  late AnimationController _dropdownController;
  late Animation<double> _dropdownAnimation;

  @override
  void initState() {
    super.initState();
    _dropdownController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _dropdownAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _dropdownController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _dropdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final languageState = ref.watch(languageStateProvider);

    return Scaffold(
      appBar: _buildAppBar(context, l10n),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 言語設定セクション
            _buildLanguageSection(context, ref, languageState),

            const SizedBox(height: 24),

            // 法的文書セクション
            _buildLegalDocumentsSection(context, languageState.language),

            const SizedBox(height: 24),

            // その他の設定セクション
            _buildOtherSettingsSection(context, ref),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, dynamic l10n) {
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.settings, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              l10n.settingsTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSection(
    BuildContext context,
    WidgetRef ref,
    LanguageState languageState,
  ) {
    final l10n = context.l10n;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [AppColors.primarySurface, AppColors.primaryContainer],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.language,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.settingsLanguageLabel,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                l10n.languageSelectionDescription,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              _buildLanguageSelector(context, ref, languageState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(
    BuildContext context,
    WidgetRef ref,
    LanguageState languageState,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          // 現在選択中の言語を表示するボタン
          InkWell(
            onTap: _toggleLanguageDropdown,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
          Icon(Icons.language, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          languageState.language.nativeName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        Text(
                          languageState.language.englishName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      languageState.language.code.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _isLanguageDropdownOpen ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ドロップダウン選択肢（アニメーション付き）
          AnimatedBuilder(
            animation: _dropdownAnimation,
            builder: (context, child) {
              return SizeTransition(
                sizeFactor: _dropdownAnimation,
                child: FadeTransition(
                  opacity: _dropdownAnimation,
                  child: _isLanguageDropdownOpen
                      ? Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                            border: const Border(
                              top: BorderSide(
                                color: AppColors.border,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Column(
                            children: AppLanguage.supportedLanguages
                                .where(
                                  (language) =>
                                      language.code !=
                                      languageState.language.code,
                                )
                                .map((language) {
                                  return InkWell(
                                    onTap: () => _onLanguageSelected(
                                      context,
                                      ref,
                                      language,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.radio_button_unchecked,
                                            color: AppColors.border,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  language.nativeName,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500,
                                                    color:
                                                        AppColors.textPrimary,
                                                  ),
                                                ),
                                                Text(
                                                  language.englishName,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.primarySurface,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              language.code.toUpperCase(),
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _toggleLanguageDropdown() {
    setState(() {
      _isLanguageDropdownOpen = !_isLanguageDropdownOpen;
    });

    if (_isLanguageDropdownOpen) {
      _dropdownController.forward();
    } else {
      _dropdownController.reverse();
    }
  }

  Widget _buildLegalDocumentsSection(
    BuildContext context,
    AppLanguage language,
  ) {
    final l10n = context.l10n;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: AppColors.primaryGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.gavel,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.settingsLegalDocumentsTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                l10n.settingsLegalDocumentsDescription,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              _buildLegalDocumentItem(
                context,
                l10n.privacyPolicyTitle,
                Icons.privacy_tip,
                AppColors.primary,
                () => _openLegalDocument(
                  context,
                  language,
                  _LegalDocument.privacyPolicy,
                ),
              ),
              const SizedBox(height: 12),
              _buildLegalDocumentItem(
                context,
                l10n.termsOfServiceTitle,
                Icons.description,
                AppColors.secondary,
                () => _openLegalDocument(
                  context,
                  language,
                  _LegalDocument.termsOfService,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openLegalDocument(
    BuildContext context,
    AppLanguage language,
    _LegalDocument document,
  ) async {
    final uri = _resolveLegalDocumentUrl(language, document);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        _showLegalDocumentError(context);
      }
    } catch (_) {
      if (mounted) {
        _showLegalDocumentError(context);
      }
    }
  }

  Uri _resolveLegalDocumentUrl(
    AppLanguage language,
    _LegalDocument document,
  ) {
    final urls = document == _LegalDocument.privacyPolicy
        ? _privacyPolicyUrls
        : _termsOfServiceUrls;
    final url = urls[language.code] ?? urls['en']!;
    return Uri.parse(url);
  }

  void _showLegalDocumentError(BuildContext context) {
    final l10n = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.commonErrorTitle)),
    );
  }

  Widget _buildLegalDocumentItem(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherSettingsSection(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final keypadMode = ref.watch(keypadSettingsProvider);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [AppColors.surface, AppColors.primarySurface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.settings,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.settingsOtherSettingsTitle,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Keyboard layout',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              _buildKeyboardModeOption(
                context: context,
                ref: ref,
                mode: KeypadLayoutMode.flick,
                currentMode: keypadMode,
                icon: Icons.touch_app_rounded,
                title: 'Flick keyboard',
                description:
                    'Category buttons expand into radial pads for quick flick input.',
              ),
              const SizedBox(height: 12),
              _buildKeyboardModeOption(
                context: context,
                ref: ref,
                mode: KeypadLayoutMode.scroll,
                currentMode: keypadMode,
                icon: Icons.grid_view_rounded,
                title: 'Scrollable keyboard',
                description:
                    'Shows every key in a compact 6-column grid that you can scroll vertically.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyboardModeOption({
    required BuildContext context,
    required WidgetRef ref,
    required KeypadLayoutMode mode,
    required KeypadLayoutMode currentMode,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final bool isSelected = mode == currentMode;
    final theme = Theme.of(context);
    final borderColor = isSelected
        ? theme.colorScheme.primary.withValues(alpha: 0.35)
        : AppColors.border;
    final backgroundColor = isSelected
        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
        : AppColors.background;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => ref.read(keypadSettingsProvider.notifier).setMode(mode),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Radio<KeypadLayoutMode>(
                        value: mode,
                        groupValue: currentMode,
                        onChanged: (_) => ref
                            .read(keypadSettingsProvider.notifier)
                            .setMode(mode),
                        activeColor: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onLanguageSelected(
    BuildContext context,
    WidgetRef ref,
    AppLanguage language,
  ) {
    ref.read(languageStateProvider.notifier).setLanguage(language);

    // ドロップダウンを閉じる
    _toggleLanguageDropdown();

    // 言語変更後にSnackBarを表示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final l10n = context.l10n;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.settingsLanguageChanged(language.nativeName)),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }
}
