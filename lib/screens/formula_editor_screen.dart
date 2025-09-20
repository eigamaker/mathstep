import 'package:flutter/material.dart';
import '../utils/syntax_converter.dart';
import '../widgets/latex_preview.dart';

class FormulaEditorScreen extends StatefulWidget {
  final String initialCalculatorSyntax;

  const FormulaEditorScreen({super.key, required this.initialCalculatorSyntax});

  @override
  State<FormulaEditorScreen> createState() => _FormulaEditorScreenState();
}

class _FormulaEditorScreenState extends State<FormulaEditorScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialCalculatorSyntax);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _insertTemplate(String text, {int? caretTo}) {
    final sel = _controller.selection;
    final start = sel.start < 0 ? _controller.text.length : sel.start;
    final end = sel.end < 0 ? _controller.text.length : sel.end;
    final before = _controller.text.substring(0, start);
    final after = _controller.text.substring(end);
    final newText = before + text + after;
    _controller.text = newText;
    final target = caretTo ?? (before.length + text.length);
    _controller.selection = TextSelection.fromPosition(TextPosition(offset: target));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final latex = SyntaxConverter.calculatorToLatex(_controller.text);
    return Scaffold(
      appBar: AppBar(
        title: const Text('式エディタ (数3対応)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: '反映',
            onPressed: () => Navigator.pop(context, _controller.text),
          )
        ],
      ),
      body: Column(
        children: [
          // Preview
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(12),
              child: LatexPreview(expression: latex.isEmpty ? ' ' : latex),
            ),
          ),
          // Editor
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: '電卓記法で編集 (改行可)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.multiline,
              maxLines: null,
              minLines: 5,
              onChanged: (_) => setState(() {}),
              onTap: () {
                // タップ時にフォーカスを維持する
                _controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: _controller.text.length),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Template toolbar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _tool('frac', () => _insertTemplate('frac( , )', caretTo: _controller.selection.baseOffset + 5)),
                _tool('sqrt', () => _insertTemplate('sqrt()', caretTo: _controller.selection.baseOffset + 5)),
                _tool('^', () => _insertTemplate('^')),
                _tool('abs', () => _insertTemplate('abs()', caretTo: _controller.selection.baseOffset + 4)),
                _tool('int a→b', () => _insertTemplate('integral(a,b,f(x),x)', caretTo: _controller.selection.baseOffset + 9)),
                _tool('∫ f dx', () => _insertTemplate('integral(f(x),x)', caretTo: _controller.selection.baseOffset + 9)),
                _tool('d/dx', () => _insertTemplate('diff(f(x),x)', caretTo: _controller.selection.baseOffset + 5)),
                _tool('d²/dx²', () => _insertTemplate('diff2(f(x),x)', caretTo: _controller.selection.baseOffset + 6)),
                _tool('∂/∂x', () => _insertTemplate('partial(f(x),x)', caretTo: _controller.selection.baseOffset + 8)),
                _tool('lim x→a', () => _insertTemplate('limit(x,a,f(x))', caretTo: _controller.selection.baseOffset + 7)),
                _tool('sum', () => _insertTemplate('sum(i=1,n,f(i))')),
                _tool('prod', () => _insertTemplate('prod(i=1,n,f(i))')),
                _tool('Σ i,1..n', () => _insertTemplate('sum(i,1,n,f(i))')),
                _tool('Π k,1..n', () => _insertTemplate('prod(k,1,n,a_k)')),
                _tool('cases', () => _insertTemplate('cases((f(x), x<0),(g(x), 0<=x))')),
                _tool('bmat 2x2', () => _insertTemplate('matrix((a,b),(c,d))')),
                _tool('bmat 3x3', () => _insertTemplate('matrix((a,b,c),(d,e,f),(g,h,i))')),
                _tool('| |', () => _insertTemplate('| |', caretTo: _controller.selection.baseOffset + 1)),
                _tool('( )', () => _insertTemplate('() ', caretTo: _controller.selection.baseOffset + 1)),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _tool(String label, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
