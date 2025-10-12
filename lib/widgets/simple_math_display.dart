import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../localization/localization_extensions.dart';
import '../utils/syntax_converter.dart';

class SimpleMathDisplay extends StatelessWidget {
  const SimpleMathDisplay({
    super.key,
    required this.expression,
    this.rawExpression,
  });

  final String expression;
  final String? rawExpression;

  @override
  Widget build(BuildContext context) {
    final trimmedExpression = expression.trim();
    final trimmedRaw = (rawExpression ?? expression).trim();

    if (trimmedRaw.isEmpty) {
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

    // 不完全な数式（括弧が閉じられていない）のチェック
    if (_hasUnclosedParentheses(trimmedRaw)) {
      return _buildFallback(trimmedRaw);
    }

    // 不完全な関数呼び出しのチェック（sin(, log(, cos( など）
    if (_hasIncompleteFunctionCall(trimmedRaw)) {
      return _buildFallback(trimmedRaw);
    }

    // 不完全な累乗のチェック（x^, e^, x^(2 など）
    if (_hasIncompletePower(trimmedRaw)) {
      return _buildFallback(trimmedRaw);
    }

    // 不完全な分数のチェック（1/, x/, sin(x)/ など）
    if (_hasIncompleteFraction(trimmedRaw)) {
      return _buildFallback(trimmedRaw);
    }

    // SyntaxConverterを使用してLaTeX形式に変換
    final latexExpression = rawExpression != null
        ? (trimmedExpression.isNotEmpty
            ? trimmedExpression
            : SyntaxConverter.calculatorToLatex(trimmedRaw))
        : SyntaxConverter.calculatorToLatex(trimmedExpression);
    final prepared = _prepareForDisplay(latexExpression);

    return Center(
      child: _buildMathWidget(prepared, trimmedRaw),
    );
  }

  bool _hasUnclosedParentheses(String input) {
    int parenthesesCount = 0;
    int bracketCount = 0;
    
    for (int i = 0; i < input.length; i++) {
      final char = input[i];
      if (char == '(') {
        parenthesesCount++;
      } else if (char == ')') {
        parenthesesCount--;
      } else if (char == '[') {
        bracketCount++;
      } else if (char == ']') {
        bracketCount--;
      }
    }
    
    return parenthesesCount != 0 || bracketCount != 0;
  }

  bool _hasIncompleteFunctionCall(String input) {
    // 不完全な関数呼び出しをチェック: sin(, log(, cos(, tan(, ln( など
    final incompleteFunctionPattern = RegExp(r'\b(sin|cos|tan|log|ln|sqrt)\s*\(\s*$');
    return incompleteFunctionPattern.hasMatch(input);
  }

  bool _hasIncompletePower(String input) {
    // 不完全な累乗をチェック: x^, e^, x^(2 など
    final incompletePowerPattern = RegExp(r'\^$|\^\(\s*$|\^\(\s*[^)]*$');
    return incompletePowerPattern.hasMatch(input);
  }

  bool _hasIncompleteFraction(String input) {
    // 不完全な分数をチェック: 1/, x/, sin(x)/ など
    final incompleteFractionPattern = RegExp(r'/\s*$');
    return incompleteFractionPattern.hasMatch(input);
  }

  Widget _buildMathWidget(String prepared, String original) {
    try {
      return Math.tex(
        prepared,
        mathStyle: MathStyle.display,
        textStyle: const TextStyle(fontSize: 22, color: Colors.black87),
        onErrorFallback: (_) => _buildFallback(original),
      );
    } catch (e) {
      // エラーが発生した場合はフォールバック表示
      return _buildFallback(original);
    }
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
