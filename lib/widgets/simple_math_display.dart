import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class SimpleMathDisplay extends StatelessWidget {
  final String expression;

  const SimpleMathDisplay({super.key, required this.expression});

  @override
  Widget build(BuildContext context) {
    final trimmed = expression.trim();
    if (trimmed.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text(
          '数式を入力してください',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    final prepared = _prepareForDisplay(trimmed);

    return Center(
      child: Math.tex(
        prepared,
        mathStyle: MathStyle.display,
        textStyle: const TextStyle(fontSize: 24, color: Colors.black87),
        onErrorFallback: (_) => _buildFallback(trimmed),
      ),
    );
  }

  Widget _buildFallback(String content) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Text(
        content,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          fontFamily: 'monospace',
        ),
      ),
    );
  }

  String _prepareForDisplay(String input) {
    var result = input;

    if (result.contains('∫')) {
      result = result.replaceAll('∫', r'\int');
      result = result.replaceAllMapped(
        RegExp(r'\\int(?!\\limits)(?=\s*(_|\^))'),
        (match) => r'\int\limits',
      );
    }

    return result;
  }
}
