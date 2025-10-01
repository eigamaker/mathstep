import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../localization/localization_extensions.dart';
import '../utils/asciimath_converter.dart';

class SimpleMathDisplay extends StatelessWidget {
  const SimpleMathDisplay({super.key, required this.expression});

  final String expression;

  @override
  Widget build(BuildContext context) {
    final trimmed = expression.trim();
    if (trimmed.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Text(
          context.l10n.homeInputRequired,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    // AsciiMath形式をLaTeX形式に変換
    final latexExpression = AsciiMathConverter.asciiMathToLatex(trimmed);
    final prepared = _prepareForDisplay(latexExpression);

    return Center(
      child: Math.tex(
        prepared,
        mathStyle: MathStyle.display,
        textStyle: const TextStyle(fontSize: 18, color: Colors.black87),
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

    // 積分記号の処理
    if (result.contains('∫')) {
      result = result.replaceAll('∫', r'\\int');
      result = result.replaceAllMapped(
        RegExp(r'\\int(?!\\limits)(?=\\s*(_|\\^))'),
        (match) => r'\\int\\limits',
      );
    }

    // 累乗の処理
    result = result.replaceAllMapped(
      RegExp(r'(\w+)\^\{([^}]+)\}'),
      (match) => '${match.group(1)}^{${match.group(2)}}',
    );

    return result;
  }
}
