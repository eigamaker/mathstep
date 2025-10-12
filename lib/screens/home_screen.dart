import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../config/api_config.dart';
import '../models/math_expression.dart';
import '../utils/asciimath_converter.dart';
import '../widgets/calculator_keypad.dart';
import '../widgets/latex_preview.dart';
import '../widgets/reward_ad_button.dart';
import '../providers/expression_provider.dart';
import '../providers/service_providers.dart';
import '../providers/solution_storage_provider.dart';
import '../providers/reward_ad_provider.dart';
import '../localization/localization_extensions.dart';
import '../providers/language_provider.dart';
import '../services/chatgpt_service.dart';
import '../models/sample_expression.dart';
import '../constants/app_colors.dart';
import '../widgets/mathstep_logo.dart';
import 'guide_screen.dart';
import 'solution_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode();
  final TextEditingController _conditionController = TextEditingController();
  final FocusNode _conditionFieldFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // キーボードの自動表示を無効化
      // _textFieldFocus.requestFocus();
      // AdMob初期化後に広告を読み込み
      _loadAdAfterDelay();
    });
  }

  Future<void> _loadAdAfterDelay() async {
    // AdMob初期化を待つ（短縮）
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 既に広告が読み込まれている場合は再読み込みしない
    final adState = ref.read(rewardAdStateProvider);
    if (!adState.isAdLoaded && !adState.isLoading) {
      debugPrint('HomeScreen: Starting ad load...');
      ref.read(rewardAdProvider).loadAd();
    } else {
      debugPrint('HomeScreen: Ad already loaded or loading. Skipping...');
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _textFieldFocus.dispose();
    _conditionController.dispose();
    _conditionFieldFocus.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    ref.read(expressionProvider.notifier).updateInput(_textController.text);
  }

  void _focusInput() {
    if (!_textFieldFocus.hasFocus) {
      _textFieldFocus.requestFocus();
    }
  }

  void _insertText(String text) {
    _focusInput();
    final value = _textController.value;
    final selection = value.selection;
    final start = selection.start >= 0 ? selection.start : value.text.length;
    final end = selection.end >= 0 ? selection.end : value.text.length;
    final newText = value.text.replaceRange(start, end, text);
    final position = start + text.length;
    _textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: position),
    );
  }

  void _insertPowFunction() {
    // 他のキーと同様に単純に ^( を挿入
    _insertText('^(');
  }

  void _deleteText() {
    _focusInput();
    final value = _textController.value;
    final selection = value.selection;

    if (selection.start != selection.end && selection.start >= 0) {
      final newText = value.text.replaceRange(
        selection.start,
        selection.end,
        '',
      );
      _textController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start),
      );
      return;
    }

    final cursor = selection.start;
    if (cursor > 0) {
      final newText = value.text.replaceRange(cursor - 1, cursor, '');
      _textController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: cursor - 1),
      );
    }
  }

  void _moveCursor(int direction) {
    _focusInput();
    final value = _textController.value;
    final cursor = value.selection.baseOffset;
    if (cursor < 0) {
      final offset = direction.isNegative ? 0 : value.text.length;
      _textController.selection = TextSelection.collapsed(offset: offset);
      return;
    }
    final newPosition = (cursor + direction).clamp(0, value.text.length);
    _textController.selection = TextSelection.collapsed(offset: newPosition);
  }

  void _loadRandomSample() {
    final sample = SampleExpressions.getRandom();
    final l10n = context.l10n;

    _textController.text = sample.expression;
    _conditionController.text = sample.condition ?? '';

    ref.read(expressionProvider.notifier).updateInput(sample.expression);

    _showSnackBar(l10n.homeSampleLoaded(sample.expression));
  }

  Future<void> _pasteFromClipboard() async {
    final l10n = context.l10n;
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null && clipboardData!.text!.isNotEmpty) {
        _textController.text = clipboardData.text!;
        ref.read(expressionProvider.notifier).updateInput(clipboardData.text!);
        _showSnackBar(l10n.homeClipboardPasteSuccess);
      } else {
        _showSnackBar(l10n.homeClipboardEmpty);
      }
    } catch (e) {
      _showSnackBar(l10n.homeClipboardPasteFailed);
    }
  }

  Future<void> _generateSolution() async {
    final l10n = context.l10n;
    final language = ref.read(appLanguageProvider);
    final input = _textController.text.trim();
    if (input.isEmpty) {
      _showSnackBar(l10n.homeInputRequired);
      return;
    }

    try {
      ref.read(expressionProvider.notifier).updateInput(input);
      ref.read(expressionProvider.notifier).clearError();
      ref.read(expressionProvider.notifier).setLoading(true);
    } catch (e) {
      debugPrint('Provider error: $e');
    }

    try {
      debugPrint('HomeScreen: Checking API configuration...');
      debugPrint('HomeScreen: ApiConfig.isConfigured = ${ApiConfig.isConfigured}');
      debugPrint('HomeScreen: ApiConfig.openaiApiKey length = ${ApiConfig.openaiApiKey.length}');
      
      if (!ApiConfig.isConfigured) {
        debugPrint('HomeScreen: API key not configured, showing error');
        _showSnackBar(l10n.homeApiKeyMissingSnack);
        _showErrorDialog(
          l10n.homeApiKeyMissingDialogMessage,
          title: l10n.homeApiKeyMissingDialogTitle,
        );
        return;
      }

      _showSnackBar(l10n.homeSendingToChatGpt);

      final chatGptService = ref.read(chatGptServiceProvider);
      final asciiMathExpression = AsciiMathConverter.calculatorToAsciiMath(input);
      final conditionRaw = _conditionController.text.trim();
      final condition = conditionRaw.isEmpty ? null : conditionRaw;

      final solution = await chatGptService.generateSolution(
        asciiMathExpression,
        condition: condition,
        language: language,
      );

      if (!mounted) return;

      final mathExpression = MathExpression(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        calculatorSyntax: input,
        latexExpression: AsciiMathConverter.asciiMathToLatex(asciiMathExpression),
        timestamp: DateTime.now(),
      );

      debugPrint('HomeScreen: Saving solution to storage...');
      debugPrint('HomeScreen: MathExpression ID: ${mathExpression.id}');
      debugPrint('HomeScreen: Solution ID: ${solution.id}');
      debugPrint('HomeScreen: Solution steps count: ${solution.steps.length}');

      ref
          .read(solutionStorageProvider.notifier)
          .addSolution(mathExpression, solution);

      debugPrint('HomeScreen: Solution saved successfully, navigating to SolutionScreen');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SolutionScreen(
            mathExpression: mathExpression,
            solution: solution,
          ),
        ),
      );
    } on ChatGptException catch (error) {
      if (!mounted) return;

      String errorTitle;
      String errorMessage;

      switch (error.type) {
        case ChatGptErrorType.apiKeyMissing:
          errorTitle = l10n.homeApiKeyMissingDialogTitle;
          errorMessage = l10n.homeApiKeyMissingDialogMessage;
          break;
        case ChatGptErrorType.emptyResponse:
        case ChatGptErrorType.jsonParse:
          errorTitle = l10n.homeApiResponseErrorTitle;
          errorMessage = l10n.homeApiResponseErrorMessage;
          break;
        case ChatGptErrorType.apiRequestFailed:
          errorTitle = l10n.homeApiConnectionErrorTitle;
          errorMessage = l10n.homeApiConnectionErrorMessage;
          break;
      }

      _showSnackBar(l10n.homeGenericErrorSnack);
      _showErrorDialog(errorMessage, title: errorTitle);
    } catch (error, stackTrace) {
      debugPrint('Error in _generateSolution: $error\n$stackTrace');
      if (!mounted) return;
      _showSnackBar(l10n.homeGenericErrorSnack);
      _showErrorDialog(error.toString(), title: l10n.commonErrorTitle);
    } finally {
      if (mounted) {
        try {
          ref.read(expressionProvider.notifier).setLoading(false);
        } catch (providerError) {
          debugPrint('Provider error in finally: $providerError');
        }
      }
    }
  }

  void _showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), duration: duration));
  }

  /// デバイスサイズに応じてプレビューエリアの高さを計算
  double _calculatePreviewHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // 柔軟な動的サイズ計算
    // 画面の高さに基づいて適切な比率で計算（キーボード表示を考慮して調整）
    double heightRatio;
    if (screenHeight > 900) {
      heightRatio = 0.20; // 大きな画面では20%
    } else if (screenHeight > 700) {
      heightRatio = 0.22; // 中程度の画面では22%
    } else {
      heightRatio = 0.25; // 小さな画面では25%
    }
    
    // 最小・最大値を設定（キーボード表示領域を確保）
    final minHeight = 120.0;
    final maxHeight = 200.0;
    
    double calculatedHeight = screenHeight * heightRatio;
    
    // 最小・最大値でクランプ
    calculatedHeight = calculatedHeight.clamp(minHeight, maxHeight);
    
    // 横画面の場合は少し小さく
    if (screenWidth > screenHeight) {
      calculatedHeight *= 0.8;
    }
    
    // デバッグ用ログ
    debugPrint('Preview height calculation: screenHeight=$screenHeight, calculatedHeight=$calculatedHeight');
    
    return calculatedHeight;
  }

  void _showErrorDialog(String message, {String? title}) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final l10n = dialogContext.l10n;
        return AlertDialog(
          title: Text(title ?? l10n.commonErrorTitle),
          content: SingleChildScrollView(child: Text(message)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.commonOkButton),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final expressionState = ref.watch(expressionProvider);

    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // プレビューエリア（動的高さ）
          LayoutBuilder(
            builder: (context, constraints) {
              final previewHeight = _calculatePreviewHeight(context);
              return Container(
                height: previewHeight,
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 8), // 下部マージンを削減
                child: _buildLatexPreview(expressionState.latex),
              );
            },
          ),
          // 入力フィールドエリア
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildExpressionField(expressionState.input),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildConditionField(),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildGenerateButton(expressionState.isLoading),
          ),
          if (expressionState.errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  expressionState.errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 4),
          // キーパッドエリア（残りのスペースを使用）
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildCalculator(),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.calculate, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: const Text(
              'MathStep',
              style: TextStyle(
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
              AppColors.surface,
              AppColors.surface.withValues(alpha: 0.95),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: AppColors.warningContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.warningLight, width: 1),
          ),
          child: IconButton(
            icon: Icon(Icons.auto_awesome, color: AppColors.warning),
            onPressed: _loadRandomSample,
            tooltip: context.l10n.homeSampleTooltip,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryLight, width: 1),
          ),
          child: IconButton(
            icon: Icon(Icons.help_outline, color: AppColors.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GuideScreen()),
              );
            },
            tooltip: 'Usage guide',
          ),
        ),
      ],
    );
  }

  Widget _buildLatexPreview(String latexExpression) {
    final hasExpression = latexExpression.isNotEmpty;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primaryLight, width: 1),
        ),
        child: hasExpression
            ? LatexPreview(expression: latexExpression)
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.functions, size: 40, color: AppColors.primaryLight),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.homePlaceholderTitle,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.homePlaceholderSubtitle,
            style: TextStyle(color: AppColors.textHint, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExpressionField(String currentExpression) {
    final l10n = context.l10n;
    return SizedBox(
      height: 56, // 適切な高さに調整
      child: TextField(
        controller: _textController,
        focusNode: _textFieldFocus,
        keyboardType: TextInputType.text,
        showCursor: false, // カーソルを非表示にしてキーボードの自動表示を防ぐ
        readOnly: true, // 読み取り専用にしてキーボードの表示を防ぐ
        decoration: InputDecoration(
        labelText: l10n.homeExpressionFieldLabel,
        labelStyle: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.surface,
        hintText: l10n.homeExpressionHint,
        hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14),
        prefixIcon: Icon(Icons.calculate, color: AppColors.primary),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ペーストボタン
              IconButton(
                icon: Icon(Icons.content_paste, color: AppColors.success),
                onPressed: _pasteFromClipboard,
                tooltip: context.l10n.homePasteTooltip,
              ),
              // クリアボタン
              if (currentExpression.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.clear, color: AppColors.error),
                  onPressed: () {
                    _textController.clear();
                  },
                  tooltip: l10n.commonClear,
                ),
            ],
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        onTap: _focusInput,
        onChanged: (value) {
          // テキストが変更されたときにプロバイダーを更新
          ref.read(expressionProvider.notifier).updateInput(value);
        },
      ),
    );
  }

  Widget _buildConditionField() {
    final l10n = context.l10n;
    return SizedBox(
      height: 56, // 適切な高さに調整
      child: TextField(
        controller: _conditionController,
        focusNode: _conditionFieldFocus,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        enableSuggestions: true,
        autocorrect: true,
        showCursor: true, // 条件入力ではカーソルを表示
        maxLines: 2,
        minLines: 1,
        decoration: InputDecoration(
        labelText: l10n.homeConditionFieldLabel,
        labelStyle: TextStyle(
          color: AppColors.secondary,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.secondary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.secondaryContainer,
        hintText: l10n.homeConditionHint,
        hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14),
        prefixIcon: Icon(Icons.help_outline, color: AppColors.secondary),
          suffixIcon: _conditionController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: AppColors.error),
                  onPressed: () {
                    _conditionController.clear();
                  },
                  tooltip: l10n.commonClear,
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        onTap: () {
          _conditionFieldFocus.requestFocus();
        },
      ),
    );
  }

  Widget _buildGenerateButton(bool isLoading) {
    return RewardAdButton(
      onRewardEarned: _generateSolution,
      isLoading: isLoading,
    );
  }

  Widget _buildCalculator() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.surfaceGradient,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: CalculatorKeypad(
          onKeyPressed: (event) {
            switch (event.type) {
              case CalculatorKeyType.delete:
                _deleteText();
                break;
              case CalculatorKeyType.moveLeft:
                _moveCursor(-1);
                break;
              case CalculatorKeyType.moveRight:
                _moveCursor(1);
                break;
              case CalculatorKeyType.input:
                if (event.value == 'pow(') {
                  // pow()キーの場合は特別な処理
                  _insertPowFunction();
                } else {
                  _insertText(event.value);
                }
                break;
            }
          },
        ),
      ),
    );
  }
}
