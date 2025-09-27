import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../config/api_config.dart';
import '../models/math_expression.dart';
import '../utils/syntax_converter.dart';
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
      _textFieldFocus.requestFocus();
      // AdMob初期化後に広告を読み込み
      _loadAdAfterDelay();
    });
  }

  Future<void> _loadAdAfterDelay() async {
    // AdMob初期化を待つ
    await Future.delayed(const Duration(seconds: 2));
    ref.read(rewardAdProvider).loadAd();
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
      if (!ApiConfig.isConfigured) {
        _showSnackBar(l10n.homeApiKeyMissingSnack);
        _showErrorDialog(
          l10n.homeApiKeyMissingDialogMessage,
          title: l10n.homeApiKeyMissingDialogTitle,
        );
        return;
      }

      _showSnackBar(l10n.homeSendingToChatGpt);

      final chatGptService = ref.read(chatGptServiceProvider);
      final latexExpression = SyntaxConverter.calculatorToLatex(input);
      final conditionRaw = _conditionController.text.trim();
      final condition = conditionRaw.isEmpty ? null : conditionRaw;

      final solution = await chatGptService.generateSolution(
        latexExpression,
        condition: condition,
        language: language,
      );

      if (!mounted) return;

      final mathExpression = MathExpression(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        calculatorSyntax: input,
        latexExpression: latexExpression,
        timestamp: DateTime.now(),
      );

      ref
          .read(solutionStorageProvider.notifier)
          .addSolution(mathExpression, solution);

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
    
    // 画面の高さに基づいて動的に計算
    // 最小150px、最大300px、画面高さの25-35%の範囲で調整
    final minHeight = 150.0;
    final maxHeight = 300.0;
    final heightRatio = screenHeight > 800 ? 0.25 : 0.35; // 大きな画面では小さめに
    
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
                margin: const EdgeInsets.all(16),
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
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildGenerateButton(expressionState.isLoading),
          ),
          if (expressionState.errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          const SizedBox(height: 8),
          // キーパッドエリア（残りのスペースを使用）
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildCalculator(),
            ),
          ),
          const SizedBox(height: 8),
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
            child: const Icon(Icons.functions, color: Colors.white, size: 20),
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
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
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
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade200, width: 1),
          ),
          child: IconButton(
            icon: Icon(Icons.auto_awesome, color: Colors.amber.shade700),
            onPressed: _loadRandomSample,
            tooltip: context.l10n.homeSampleTooltip,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200, width: 1),
          ),
          child: IconButton(
            icon: Icon(Icons.help_outline, color: Colors.blue.shade700),
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
          colors: [Colors.blue.shade50, Colors.purple.shade50],
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.blue.shade100, width: 1),
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
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.functions, size: 48, color: Colors.blue.shade300),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.homePlaceholderTitle,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.homePlaceholderSubtitle,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExpressionField(String currentExpression) {
    final l10n = context.l10n;
    return TextField(
      controller: _textController,
      focusNode: _textFieldFocus,
      keyboardType: TextInputType.text,
      showCursor: true,
      decoration: InputDecoration(
        labelText: l10n.homeExpressionFieldLabel,
        labelStyle: TextStyle(
          color: Colors.blue.shade600,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        hintText: l10n.homeExpressionHint,
        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        prefixIcon: Icon(Icons.calculate, color: Colors.blue.shade600),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ペーストボタン
            IconButton(
              icon: Icon(Icons.content_paste, color: Colors.green.shade600),
              onPressed: _pasteFromClipboard,
              tooltip: context.l10n.homePasteTooltip,
            ),
            // クリアボタン
            if (currentExpression.isNotEmpty)
              IconButton(
                icon: Icon(Icons.clear, color: Colors.red.shade600),
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
    );
  }

  Widget _buildConditionField() {
    final l10n = context.l10n;
    return TextField(
      controller: _conditionController,
      focusNode: _conditionFieldFocus,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      enableSuggestions: true,
      autocorrect: true,
      maxLines: 2,
      minLines: 1,
      decoration: InputDecoration(
        labelText: l10n.homeConditionFieldLabel,
        labelStyle: TextStyle(
          color: Colors.green.shade600,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.green.shade400, width: 2),
        ),
        filled: true,
        fillColor: Colors.green.shade50,
        hintText: l10n.homeConditionHint,
        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        prefixIcon: Icon(Icons.help_outline, color: Colors.green.shade600),
        suffixIcon: _conditionController.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, color: Colors.red.shade600),
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
          colors: [Colors.grey.shade50, Colors.grey.shade100],
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
          color: Colors.white,
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
