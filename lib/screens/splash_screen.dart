import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../localization/localization_extensions.dart';
import '../localization/app_language.dart';
import '../providers/language_provider.dart';
import '../widgets/mathstep_logo.dart';
import '../constants/app_colors.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;
  
  AppLanguage _selectedLanguage = AppLanguage.defaultLanguage;
  bool _showLanguageDropdown = false;
  late AnimationController _dropdownController;
  late Animation<double> _dropdownAnimation;

  @override
  void initState() {
    super.initState();

    // アニメーションコントローラーの初期化
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // ロゴアニメーション（スケール + 回転）
    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    // テキストアニメーション（フェードイン）
    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );

    // ドロップダウンアニメーション
    _dropdownController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _dropdownAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _dropdownController, curve: Curves.easeInOut),
    );

    // 言語設定の確認とアニメーション開始
    _checkLanguageAndStartAnimations();
  }

  void _checkLanguageAndStartAnimations() async {
    // 言語設定の初期化が完了するまで待機
    await ref.read(languageStateProvider.notifier).loadLanguage();
    final languageState = ref.read(languageStateProvider);
    
    // 常に言語選択を表示し、現在の言語設定をデフォルトとして設定
    setState(() {
      _selectedLanguage = languageState.language;
    });
    
    // アニメーション開始
    _startAnimations();
  }

  void _startAnimations() async {
    // ロゴアニメーション開始
    _logoController.forward();

    // 少し遅れてテキストアニメーション開始
    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();
  }

  void _onLanguageSelected(AppLanguage language) {
    setState(() {
      _selectedLanguage = language;
      _showLanguageDropdown = false;
    });
    ref.read(languageStateProvider.notifier).setLanguage(language);
  }

  void _toggleLanguageDropdown() {
    setState(() {
      _showLanguageDropdown = !_showLanguageDropdown;
    });
    
    if (_showLanguageDropdown) {
      _dropdownController.forward();
    } else {
      _dropdownController.reverse();
    }
  }

  Future<void> _confirmLanguageSelection() async {
    await ref.read(languageStateProvider.notifier).setLanguage(_selectedLanguage);
    // 言語選択完了後、直接メイン画面に遷移（中間状態を表示しない）
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MainNavigationScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _dropdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: _buildLanguageSelection(),
    );
  }

  Widget _buildLanguageSelection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 共通のロゴとアプリ名部分
          _buildLogoAndTitle(),
          const SizedBox(height: 50),

          // 言語選択ドロップダウン
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  context.l10n.languageSelectionTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 20),
                
                // 言語選択ボタン
                GestureDetector(
                  onTap: _toggleLanguageDropdown,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${_selectedLanguage.nativeName} (${_selectedLanguage.englishName})',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _showLanguageDropdown ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: AppColors.primary,
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
                        child: _showLanguageDropdown
                            ? Column(
                                children: [
                                  const SizedBox(height: 12),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: AppLanguage.supportedLanguages.map((language) {
                                        final isSelected = language.code == _selectedLanguage.code;
                                        return GestureDetector(
                                          onTap: () => _onLanguageSelected(language),
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                            decoration: BoxDecoration(
                                              color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                if (isSelected)
                                                  Icon(
                                                    Icons.check,
                                                    color: AppColors.primary,
                                                    size: 20,
                                                  )
                                                else
                                                  const SizedBox(width: 20),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    '${language.nativeName} (${language.englishName})',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                      color: isSelected ? AppColors.primary : Colors.black87,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 20),
                
                // 続行ボタン
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _confirmLanguageSelection,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      context.l10n.languageSelectionContinue,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoAndTitle() {
    return Column(
      children: [
        // ロゴ部分（画像を使用）
        AnimatedBuilder(
          animation: _logoAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _logoAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1), // 半透明の白背景
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/mathstep.png',
                  width: 200, // 横長ロゴに適した幅
                  height: 50, // 比率を維持した高さ (1600:400 = 4:1)
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // 画像が見つからない場合はテキストロゴを表示
                    return const MathstepLogo(
                      fontSize: 32,
                      textColor: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    );
                  },
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 30),

        // タグラインのみ
        AnimatedBuilder(
          animation: _textAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _textAnimation.value,
              child: Text(
                context.l10n.splashTagline,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.9),
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            );
          },
        ),
      ],
    );
  }
}
