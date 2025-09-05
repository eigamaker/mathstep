import 'package:flutter/material.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('キーの使い方'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategory(
              '累乗・根号',
              [
                _buildExample('2^3', ['2', 'x^y', '3']),
                _buildExample('√9', ['√', '9', ')']),
                _buildExample('∛8', ['∛', '8', ')']),
                _buildExample('⁴√16', ['ⁿ√', '4', ',', '1', '6', ')']),
                _buildExample('x^2 + 1', ['x', 'x^y', '2', '+', '1']),
              ],
            ),
            const SizedBox(height: 24),
            _buildCategory(
              '分数・絶対値',
              [
                _buildExample('1/2', ['a/b', '1', ',', '2', ')']),
                _buildExample('3/4 + 1/2', ['a/b', '3', ',', '4', ')', '+', 'a/b', '1', ',', '2', ')']),
                _buildExample('|-5|', ['|x|', '-', '5', ')']),
                _buildExample('|x - 3|', ['|x|', 'x', '-', '3', ')']),
              ],
            ),
            const SizedBox(height: 24),
            _buildCategory(
              '三角関数',
              [
                _buildExample('sin(30°)', ['sin', '3', '0', ')']),
                _buildExample('cos(60°)', ['cos', '6', '0', ')']),
                _buildExample('tan(45°)', ['tan', '4', '5', ')']),
                _buildExample('sin²(x) + cos²(x)', ['sin', 'x', ')', 'x^y', '2', '+', 'cos', 'x', ')', 'x^y', '2']),
              ],
            ),
            const SizedBox(height: 24),
            _buildCategory(
              '対数・指数',
              [
                _buildExample('ln(e)', ['ln', 'e', ')']),
                _buildExample('log(100)', ['log', '1', '0', '0', ')']),
                _buildExample('e^2', ['e', 'x^y', '2']),
                _buildExample('π × 2', ['π', '×', '2']),
                _buildExample('2^x', ['2', 'x^y', 'x']),
              ],
            ),
            const SizedBox(height: 24),
            _buildCategory(
              '高度な数学',
              [
                _buildExample('₅P₃', ['P', '5', ',', '3', ')']),
                _buildExample('₅C₃', ['C', '5', ',', '3', ')']),
                _buildExample('Σ(n=1 to 5) n', ['Σ', 'n', ',', '1', ',', '5', ')']),
                _buildExample('3 + 4i', ['3', '+', '4', 'i']),
                _buildExample('|3 + 4i|', ['|x|', '3', '+', '4', 'i', ')']),
                _buildExample('n!', ['n!']),
              ],
            ),
            const SizedBox(height: 24),
            _buildCategory(
              '変数・複雑な式',
              [
                _buildExample('x² + 2x + 1', ['x', 'x^y', '2', '+', '2', '×', 'x', '+', '1']),
                _buildExample('(x + 1)/(x - 1)', ['(', 'x', '+', '1', ')', '/', '(', 'x', '-', '1', ')']),
                _buildExample('√(x² + y²)', ['√', '(', 'x', 'x^y', '2', '+', 'y', 'x^y', '2', ')', ')']),
                _buildExample('sin(x) + cos(y)', ['sin', 'x', ')', '+', 'cos', 'y', ')']),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 ヒント',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• 関数キー（sin, cos, √など）を押すと自動的に「(」が入力されます\n'
                    '• カーソル移動は ◀ ▶ キーを使用してください\n'
                    '• 間違えた場合は DEL キーで削除できます\n'
                    '• 数式はリアルタイムでプレビューされます',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade700,
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

  Widget _buildCategory(String title, List<Widget> examples) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 12),
        ...examples,
      ],
    );
  }

  Widget _buildExample(String expression, List<String> keySequence) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '数式: $expression',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'キーの順番:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: keySequence.map((key) => _buildKeyChip(key)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyChip(String key) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade300),
      ),
      child: Text(
        key,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.blue.shade800,
        ),
      ),
    );
  }
}
