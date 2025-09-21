import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../localization/localization_extensions.dart';
import '../localization/app_language.dart';
import '../providers/language_provider.dart';
import 'settings_screen.dart';
import 'home_screen.dart';
import 'history_screen.dart';

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
  
  bool _showLanguageSelection = false;
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
    final languageState = ref.read(languageStateProvider);
    
    if (!languageState.hasSavedPreference) {
      // 言語設定がない場合は言語選択を表示
      setState(() {
        _showLanguageSelection = true;
        _selectedLanguage = languageState.language;
      });
      
      // 初期選択位置は不要になったので削除
    }
    
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

  Future<void> _navigateToMain() async {
    if (!mounted) return;

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
    setState(() {
      _showLanguageSelection = false;
    });
    _navigateToMain();
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
      backgroundColor: const Color(0xFF2196F3),
      body: _showLanguageSelection ? _buildLanguageSelection() : _buildSplashContent(),
    );
  }

  Widget _buildSplashContent() {
    return GestureDetector(
      onTap: _navigateToMain,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ロゴ部分
            AnimatedBuilder(
              animation: _logoAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _logoAnimation.value,
                  child: Transform.rotate(
                    angle: _logoAnimation.value * 0.1,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(60),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.functions,
                        size: 60,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // アプリ名
            AnimatedBuilder(
              animation: _textAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _textAnimation.value,
                  child: Column(
                    children: [
                      Text(
                        context.l10n.appTitle,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.splashTagline,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.9),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 50),

            // タップを促すテキスト
            AnimatedBuilder(
              animation: _textAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _textAnimation.value,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          context.l10n.splashTapToStart,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ロゴ部分（タップアイコン）
          AnimatedBuilder(
            animation: _logoAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _logoAnimation.value,
                child: Transform.rotate(
                  angle: _logoAnimation.value * 0.1,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.functions,
                      size: 60,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 40),

          // アプリ名
          AnimatedBuilder(
            animation: _textAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _textAnimation.value,
                child: Column(
                  children: [
                    Text(
                      context.l10n.appTitle,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.splashTagline,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

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
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2196F3),
                  ),
                ),
                const SizedBox(height: 20),
                
                // 言語選択ボタン
                GestureDetector(
                  onTap: _toggleLanguageDropdown,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF2196F3).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_selectedLanguage.nativeName} (${_selectedLanguage.englishName})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2196F3),
                          ),
                        ),
                        Icon(
                          _showLanguageDropdown ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: const Color(0xFF2196F3),
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
                                              color: isSelected ? const Color(0xFF2196F3).withValues(alpha: 0.1) : Colors.transparent,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                if (isSelected)
                                                  const Icon(
                                                    Icons.check,
                                                    color: Color(0xFF2196F3),
                                                    size: 20,
                                                  )
                                                else
                                                  const SizedBox(width: 20),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    '${language.nativeName} (${language.englishName})',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                      color: isSelected ? const Color(0xFF2196F3) : Colors.black87,
                                                    ),
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
                      backgroundColor: const Color(0xFF2196F3),
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
}

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    const HomeScreen(),
    const HistoryScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.calculate),
            label: l10n.navigationHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history),
            label: l10n.navigationHistory,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.navigationSettings,
          ),
        ],
      ),
    );
  }
}
