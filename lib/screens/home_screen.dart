import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/calculator_keypad.dart';
import '../widgets/latex_preview.dart';
import '../widgets/input_method_selector.dart';
import '../services/chatgpt_service.dart';
import '../models/math_expression.dart';
import '../models/solution.dart';
import 'solution_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _textController = TextEditingController();
  String _currentExpression = '';
  String _latexExpression = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _currentExpression = _textController.text;
      _latexExpression = _convertToLatex(_currentExpression);
    });
  }

  String _convertToLatex(String calculatorSyntax) {
    // 基本的な変換（詳細は後で実装）
    String latex = calculatorSyntax;
    latex = latex.replaceAll('frac(', r'\frac{');
    latex = latex.replaceAll('sqrt(', r'\sqrt{');
    latex = latex.replaceAll('cbrt(', r'\sqrt[3]{');
    latex = latex.replaceAll('sin(', r'\sin(');
    latex = latex.replaceAll('cos(', r'\cos(');
    latex = latex.replaceAll('tan(', r'\tan(');
    latex = latex.replaceAll('ln(', r'\ln(');
    latex = latex.replaceAll('log(', r'\log(');
    latex = latex.replaceAll('pi', r'\pi');
    latex = latex.replaceAll('e', 'e');
    latex = latex.replaceAll('i', 'i');
    return latex;
  }

  void _insertText(String text) {
    final cursorPosition = _textController.selection.baseOffset;
    final textBefore = _textController.text.substring(0, cursorPosition);
    final textAfter = _textController.text.substring(cursorPosition);
    
    _textController.text = textBefore + text + textAfter;
    _textController.selection = TextSelection.fromPosition(
      TextPosition(offset: cursorPosition + text.length),
    );
  }

  void _deleteText() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MathStep'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // 入力方法選択
          const InputMethodSelector(),
          
          // LaTeXプレビュー
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'プレビュー',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _latexExpression.isNotEmpty
                        ? LatexPreview(expression: _latexExpression)
                        : const Center(
                            child: Text(
                              '数式を入力してください',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          
          // テキスト入力フィールド
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: '数式入力（電卓シンタックス）',
                border: OutlineInputBorder(),
                hintText: '例: (2x+1)/(x-3) = cbrt(x+2)',
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 解説生成ボタン
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _generateSolution,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
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
        ],
      ),
    );
  }
}
