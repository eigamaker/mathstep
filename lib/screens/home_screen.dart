import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/calculator_keypad.dart';
import '../widgets/latex_preview_scroll.dart';
import '../services/chatgpt_service.dart';
import '../models/math_expression.dart';
import 'solution_screen.dart';
import 'guide_screen.dart';
import '../utils/syntax_converter.dart';
import 'formula_editor_screen.dart';
import '../config/api_config.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode();
  String _currentExpression = '';
  String _latexExpression = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    // アプリ起動時にテキストフィールドにフォーカスを当てる
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _textFieldFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFieldFocus.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _currentExpression = _textController.text;
      _latexExpression = SyntaxConverter.calculatorToLatex(_currentExpression);
    });
  }


  Future<void> _openFormulaEditor() async {
    final edited = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormulaEditorScreen(initialCalculatorSyntax: _textController.text),
      ),
    );
    if (edited is String) {
      _textController.text = edited;
    }
  }






  void _insertText(String text) {
    // テキストフィールドにフォーカスを当てる
    _textFieldFocus.requestFocus();
    
    final cursorPosition = _textController.selection.baseOffset;
    final textBefore = _textController.text.substring(0, cursorPosition);
    final textAfter = _textController.text.substring(cursorPosition);
    
    _textController.text = textBefore + text + textAfter;
    _textController.selection = TextSelection.fromPosition(
      TextPosition(offset: cursorPosition + text.length),
    );
  }

  void _deleteText() {
    // テキストフィールドにフォーカスを当てる
    _textFieldFocus.requestFocus();
    
    final cursorPosition = _textController.selection.baseOffset;
    if (cursorPosition > 0) {
      final textBefore = _textController.text.substring(0, cursorPosition - 1);
      final textAfter = _textController.text.substring(cursorPosition);
      
      _textController.text = textBefore + textAfter;
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: cursorPosition - 1),
      );
    }
  }

  void _moveCursor(int direction) {
    // テキストフィールドにフォーカスを当てる
    _textFieldFocus.requestFocus();
    
    final cursorPosition = _textController.selection.baseOffset;
    final newPosition = (cursorPosition + direction).clamp(0, _textController.text.length);
    
    _textController.selection = TextSelection.fromPosition(
      TextPosition(offset: newPosition),
    );
  }

  Future<void> _generateSolution() async {
    if (_currentExpression.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('数式を入力してください')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // APIキーの設定状況をチェック
      final isApiConfigured = await _checkApiConfiguration();
      
      if (!isApiConfigured) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('APIキーが設定されていません。デモデータを表示します。'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ChatGPTに送信中...'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }

      final chatGptService = ChatGptService();
      final solution = await chatGptService.generateSolution(_latexExpression);
      
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SolutionScreen(
              mathExpression: MathExpression(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                calculatorSyntax: _currentExpression,
                latexExpression: _latexExpression,
                timestamp: DateTime.now(),
              ),
              solution: solution,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _checkApiConfiguration() async {
    try {
      // API設定をチェック
      return ApiConfig.isConfigured;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MathStep'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _openFormulaEditor,
            tooltip: '式エディタを開く',
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GuideScreen(),
                ),
              );
            },
            tooltip: '使い方ガイド',
          ),
        ],
      ),
      body: Column(
        children: [
          // LaTeXプレビュー
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade50,
              ),
              child: _latexExpression.isNotEmpty
                  ? LatexPreviewScrollable(expression: _latexExpression)
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.functions,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            '数式を入力してください',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'キーパッドまたは式エディタを使用して数式を入力できます',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          
          // テキスト入力フィールド
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _textController,
              focusNode: _textFieldFocus,
              keyboardType: TextInputType.none, // デフォルトキーボードを無効化
              showCursor: true,
              decoration: InputDecoration(
                labelText: '数式を入力',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: '例: (2x+1)/(x-3) = cbrt(x+2)',
                prefixIcon: const Icon(Icons.calculate),
                suffixIcon: _currentExpression.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _textController.clear();
                        },
                        tooltip: 'クリア',
                      )
                    : null,
              ),
              onTap: () {
                // タップ時にフォーカスを維持するが、キーボードは表示しない
                _textFieldFocus.requestFocus();
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 解説生成ボタン
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _generateSolution,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: _isLoading
                  ? const Text('処理中...', style: TextStyle(fontSize: 18))
                  : const Text(
                      '解説を表示',
                      style: TextStyle(fontSize: 18),
                    ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 電卓キーパッド
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: CalculatorKeypad(
                onKeyPressed: (key) {
                  switch (key) {
                    case 'DEL':
                      _deleteText();
                      break;
                    case '←':
                      _moveCursor(-1);
                      break;
                    case '→':
                      _moveCursor(1);
                      break;
                    default:
                      _insertText(key);
                  }
                },
              ),
            ),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
