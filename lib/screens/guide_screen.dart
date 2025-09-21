import 'package:flutter/material.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('\u30ad\u30fc\u306e\u4f7f\u3044\u65b9'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategory('\u6307\u6570\u30fb\u6839\u53f7', [
              _buildExample('x^2', ['x', 'x^y', '2']),
              _buildExample('2^{x+1}', ['2', 'x^()', 'x', '+', '1', ')']),
              _buildExample('e^{x^2}', ['e', 'x^()', 'x', 'x^y', '2', ')']),
              _buildExample('\\sqrt{9}', ['\u221a', '9', ')']),
              _buildExample('\\sqrt[3]{8}', ['\u221b', '8', ')']),
              _buildExample('\\sqrt[4]{16}', [
                '\u207f\u221a',
                '4',
                ',',
                '16',
                ')',
              ]),
            ]),
            const SizedBox(height: 24),
            _buildCategory('\u5206\u6570\u30fb\u7d76\u5bfe\u5024', [
              _buildExample('\\frac{1}{2}', ['a/b', '1', ',', '2', ')']),
              _buildExample('\\frac{x+1}{x-1}', [
                'a/b',
                'x',
                '+',
                '1',
                ',',
                'x',
                '-',
                '1',
                ')',
              ]),
              _buildExample('|x|', ['|x|', 'x', ')']),
              _buildExample('|3+4i|', ['|x|', '3', '+', '4', 'i', ')']),
            ]),
            const SizedBox(height: 24),
            _buildCategory('\u4e09\u89d2\u30fb\u5bfe\u6570\u95a2\u6570', [
              _buildExample('\\sin(x)', ['sin(', 'x', ')']),
              _buildExample('\\cos(x)', ['cos(', 'x', ')']),
              _buildExample('\\tan(x)', ['tan(', 'x', ')']),
              _buildExample('\\ln(e)', ['ln(', 'e', ')']),
              _buildExample('\\log(100)', ['log(', '1', '0', '0', ')']),
            ]),
            const SizedBox(height: 24),
            _buildCategory('\u7dcf\u548c\u30fb\u7a4d\u5206\u30fb\u7a4d', [
              _buildExample('\\sum_{1}^{5} x', [
                '\u03a3',
                '1',
                ',',
                '5',
                ',',
                'x',
                ')',
              ]),
              _buildExample('\\prod_{1}^{4} x', [
                '\u03a0',
                '1',
                ',',
                '4',
                ',',
                'x',
                ')',
              ]),
              _buildExample('\\int_{0}^{1} x^2 \\, dx', [
                '\u222b',
                '0',
                ',',
                '1',
                ',',
                'x',
                'x^y',
                '2',
                ',',
                'x',
                ')',
              ]),
              _buildExample('\\int \\sin(x) \\, dx', [
                '\u222b',
                'sin(',
                'x',
                ')',
                ',',
                'x',
                ')',
              ]),
            ]),
            const SizedBox(height: 24),
            _buildCategory(
              '\u8907\u7d20\u6570\u30fb\u7d44\u307f\u5408\u308f\u305b',
              [
                _buildExample('3+4i', ['3', '+', '4', 'i']),
                _buildExample('\\overline{z}', ['z*', 'z', ')']),
                _buildExample('\\Re(z)', ['Re', 'z', ')']),
                _buildExample('\\Im(z)', ['Im', 'z', ')']),
                _buildExample('P_{3}^{5}', ['P', '5', ',', '3', ')']),
                _buildExample('C_{3}^{5}', ['C', '5', ',', '3', ')']),
              ],
            ),
            const SizedBox(height: 32),
            _buildTipsSection(context),
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
            '\u6570\u5f0f: ' + expression,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            '\u30ad\u30fc\u306e\u9806\u756a:',
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

  Widget _buildTipsSection(BuildContext context) {
    final tips = <String>[
      '\u95a2\u6570\u30ad\u30fc\uff08sin, cos, \u221a \u306a\u3069\uff09\u3092\u62bc\u3059\u3068\u81ea\u52d5\u7684\u306b\u300c(\u300d\u304c\u5165\u529b\u3055\u308c\u307e\u3059\u3002',
      'x^y\u30ad\u30fc\u3067\u7c21\u5358\u306a\u6307\u6570\u3092\u3001x^()\u30ad\u30fc\u3067\u5f0f\u306e\u6307\u6570\u3092\u5165\u529b\u3067\u304d\u307e\u3059\u3002',
      '\u77e2\u5370\u30ad\u30fc\uff08\u2190 \u2192\uff09\u3067\u30ab\u30fc\u30bd\u30eb\u3092\u79fb\u52d5\u3067\u304d\u307e\u3059\u3002',
      'DEL\u30ad\u30fc\u3067\u30ab\u30fc\u30bd\u30eb\u306e\u5de6\u5074\u3092\u524a\u9664\u3067\u304d\u307e\u3059\u3002',
      '\u03a3, \u03a0, \u222b \u30ad\u30fc\u306f\u30ab\u30f3\u30de\u533a\u5207\u308a\u3067\u4e0b\u9650\u30fb\u4e0a\u9650\u30fb\u5f0f\u3092\u5165\u529b\u3057\u307e\u3059\u3002',
      'a/b\u30ad\u30fc\u3067\u5206\u6570\u3092\u5165\u529b\u3057\u3001\u30ab\u30f3\u30de\u3067\u5206\u5b50\u3068\u5206\u6bcd\u3092\u533a\u5207\u308a\u307e\u3059\u3002',
      '\u5fc5\u8981\u306b\u5fdc\u3058\u3066 ) \u30ad\u30fc\u3067\u62ec\u5f27\u3092\u9589\u3058\u3066\u304f\u3060\u3055\u3044\u3002',
    ];

    return Container(
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
            '\U0001f4a1 \u30d2\u30f3\u30c8',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 8),
          ...tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '\u2022 ' + tip,
                style: TextStyle(fontSize: 14, color: Colors.blue.shade700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
