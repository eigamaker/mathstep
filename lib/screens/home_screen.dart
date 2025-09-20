import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/api_config.dart';
import '../models/math_expression.dart';
import '../utils/syntax_converter.dart';
import '../widgets/calculator_keypad.dart';
import '../widgets/latex_preview_scroll.dart';
import '../providers/expression_provider.dart';
import '../providers/service_providers.dart';
import 'formula_editor_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _textFieldFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _textFieldFocus.dispose();
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

  Future<void> _openFormulaEditor() async {
    final edited = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            FormulaEditorScreen(initialCalculatorSyntax: _textController.text),
      ),
    );
    if (edited != null) {
      _textController.value = TextEditingValue(
        text: edited,
        selection: TextSelection.collapsed(offset: edited.length),
      );
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

  Future<void> _generateSolution() async {
    // テキストコントローラーから直接入力を取得
    final input = _textController.text.trim();
    if (input.isEmpty) {
      _showSnackBar('数式を入力してください');
      return;
    }

    // プロバイダーの状態を安全に更新
    try {
      ref.read(expressionProvider.notifier).updateInput(input);
      ref.read(expressionProvider.notifier).clearError();
      ref.read(expressionProvider.notifier).setLoading(true);
    } catch (e) {
      debugPrint('Provider error: $e');
      // プロバイダーエラーの場合は続行
    }

    try {
      if (!ApiConfig.isConfigured) {
        _showSnackBar('APIキーが設定されていません。');
        _showErrorDialog(
          'OpenAI APIキーが設定されていません。\n\n'
          '設定方法：\n'
          '1. プロジェクトルートに.envファイルを作成\n'
          '2. 以下の内容を記述：\n'
          '   OPENAI_API_KEY=your_api_key_here\n'
          '3. アプリを再起動\n\n'
          'APIキーはOpenAIの公式サイトで取得できます。',
          title: 'APIキー設定が必要です',
        );
        return;
      }
      
      _showSnackBar('ChatGPTに送信中...');
      debugPrint('Using model: ${ApiConfig.model}');
      debugPrint('API URL: ${ApiConfig.openaiApiUrl}');

      final chatGptService = ref.read(chatGptServiceProvider);
      final latexExpression = SyntaxConverter.calculatorToLatex(input);
      final solution = await chatGptService.generateSolution(latexExpression);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SolutionScreen(
            mathExpression: MathExpression(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              calculatorSyntax: input,
              latexExpression: latexExpression,
              timestamp: DateTime.now(),
            ),
            solution: solution,
          ),
        ),
      );
    } catch (e, stackTrace) {
      try {
        ref.read(expressionProvider.notifier).setError(e.toString());
      } catch (providerError) {
        debugPrint('Provider error in catch: $providerError');
      }
      debugPrint('Error in _generateSolution: $e\n$stackTrace');
      if (!mounted) return;
      
      String errorMessage = e.toString();
      String errorTitle = 'エラー';
      
      // APIキー関連のエラーの場合
      if (errorMessage.contains('APIキー') || errorMessage.contains('OPENAI_API_KEY')) {
        errorTitle = 'APIキー設定が必要です';
      } else if (errorMessage.contains('API request failed')) {
        errorTitle = 'API接続エラー';
        errorMessage = 'ChatGPT APIへの接続に失敗しました。\n\n'
            '確認事項：\n'
            '• インターネット接続を確認\n'
            '• APIキーが正しく設定されているか確認\n'
            '• OpenAI APIの利用制限に達していないか確認';
      } else if (errorMessage.contains('Empty response')) {
        errorTitle = 'API応答エラー';
        errorMessage = 'ChatGPT APIからの応答が空でした。\n\n'
            'APIキーとネットワーク接続を確認してください。';
      }
      
      _showSnackBar('エラーが発生しました');
      _showErrorDialog(errorMessage, title: errorTitle);
    } finally {
      try {
        ref.read(expressionProvider.notifier).setLoading(false);
      } catch (providerError) {
        debugPrint('Provider error in finally: $providerError');
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

  void _showErrorDialog(String message, {String title = 'エラー'}) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(message),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expressionState = ref.watch(expressionProvider);

    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildLatexPreview(expressionState.latex),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildExpressionField(expressionState.input),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildCalculator(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Icon(Icons.calculate, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          const Text('MathStep'),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: _openFormulaEditor,
          tooltip: 'Open formula editor',
        ),
        IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GuideScreen()),
            );
          },
          tooltip: 'Usage guide',
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
            ? LatexPreviewScrollable(expression: latexExpression)
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
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
            '数式を入力してください',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Use the keypad or the formula editor\\nto enter an expression',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExpressionField(String currentExpression) {
    return TextField(
      controller: _textController,
      focusNode: _textFieldFocus,
      keyboardType: TextInputType.none,
      showCursor: true,
      decoration: InputDecoration(
        labelText: 'Enter an expression',
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
        hintText: 'Example: (2x+1)/(x-3) = cbrt(x+2)',
        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        prefixIcon: Icon(Icons.calculate, color: Colors.blue.shade600),
        suffixIcon: currentExpression.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, color: Colors.red.shade600),
                onPressed: () {
                  _textController.clear();
                },
                tooltip: '繧ｯ繝ｪ繧｢',
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      onTap: _focusInput,
    );
  }

  Widget _buildGenerateButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : _generateSolution,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: isLoading
              ? Colors.grey.shade400
              : Colors.blue.shade600,
          foregroundColor: Colors.white,
          elevation: isLoading ? 0 : 4,
          shadowColor: Colors.blue.shade200,
        ),
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.auto_awesome, size: 22),
        label: Text(
          isLoading ? '生成中...' : '解説を表示',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
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
                _insertText(event.value);
                break;
            }
          },
        ),
      ),
    );
  }
}
