import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../utils/syntax_converter.dart';

/// テキスト内の数式を自動検出・変換して表示するウィジェット
/// テキストと数式が自然に混ざった表示を実現
class InlineMathDisplay extends StatelessWidget {
  const InlineMathDisplay({
    super.key,
    required this.text,
    this.textStyle,
  });

  final String text;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = textStyle ?? theme.textTheme.bodyLarge?.copyWith(
      height: 1.6,
      color: theme.colorScheme.onSurface,
    );

    return _buildMixedContent(text, defaultStyle);
  }

  Widget _buildMixedContent(String text, TextStyle? textStyle) {
    // 数式パターンを検出
    final mathPatterns = [
      // 関数記号
      RegExp(r'\b(abs|sin|cos|tan|log|ln|sqrt|integral|sum|prod|limit|d/dx)\s*\([^)]+\)'),
      // 累乗
      RegExp(r'\b\w+\^\w+'),
      // 分数
      RegExp(r'\b\w+/\w+'),
      // 根号
      RegExp(r'sqrt\([^)]+\)'),
      // 積分
      RegExp(r'integral[^a-zA-Z]*'),
      // 極限
      RegExp(r'limit[^a-zA-Z]*'),
      // 微分
      RegExp(r'd/dx[^a-zA-Z]*'),
    ];

    // テキストを分割
    final parts = _splitTextByMath(text, mathPatterns);

    return Wrap(
      children: parts.map((part) {
        if (part.isMath) {
          return _buildMathWidget(part.content, textStyle);
        } else {
          return Text(part.content, style: textStyle);
        }
      }).toList(),
    );
  }

  Widget _buildMathWidget(String mathExpression, TextStyle? textStyle) {
    try {
      // 不完全な数式（括弧が閉じられていない）のチェック
      if (_hasUnclosedParentheses(mathExpression)) {
        return _buildFallback(mathExpression, textStyle);
      }

      // 不完全な関数呼び出しのチェック（sin(, log(, cos( など）
      if (_hasIncompleteFunctionCall(mathExpression)) {
        return _buildFallback(mathExpression, textStyle);
      }

      // 不完全な累乗のチェック（x^, e^, x^(2 など）
      if (_hasIncompletePower(mathExpression)) {
        return _buildFallback(mathExpression, textStyle);
      }

      // 不完全な分数のチェック（1/, x/, sin(x)/ など）
      if (_hasIncompleteFraction(mathExpression)) {
        return _buildFallback(mathExpression, textStyle);
      }
      
      // SyntaxConverterを使用してLaTeX形式に変換
      final latexExpression = SyntaxConverter.calculatorToLatex(mathExpression);
      final prepared = _prepareForDisplay(latexExpression);
      final baseFontSize = textStyle?.fontSize ?? 16;

      return _buildMathTex(prepared, mathExpression, textStyle, baseFontSize);
    } catch (e) {
      return _buildFallback(mathExpression, textStyle);
    }
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

  Widget _buildMathTex(String prepared, String original, TextStyle? textStyle, double baseFontSize) {
    try {
      return Math.tex(
        prepared,
        mathStyle: MathStyle.text,
        textStyle: textStyle?.copyWith(
          fontSize: baseFontSize * 0.9, // 少し小さく
        ),
        onErrorFallback: (_) => _buildFallback(original, textStyle),
      );
    } catch (e) {
      // エラーが発生した場合はフォールバック表示
      return _buildFallback(original, textStyle);
    }
  }

  Widget _buildFallback(String content, TextStyle? textStyle) {
    final baseFontSize = textStyle?.fontSize ?? 16;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Text(
        content,
        style: textStyle?.copyWith(
          fontFamily: 'monospace',
          fontSize: baseFontSize * 0.8,
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

  List<_TextPart> _splitTextByMath(String text, List<RegExp> patterns) {
    final parts = <_TextPart>[];
    int currentIndex = 0;

    while (currentIndex < text.length) {
      int? nextMathIndex;
      String? mathMatch;

      // 最も早い位置の数式パターンを検索
      for (final pattern in patterns) {
        final match = pattern.firstMatch(text.substring(currentIndex));
        if (match != null) {
          final matchIndex = currentIndex + match.start;
          if (nextMathIndex == null || matchIndex < nextMathIndex) {
            nextMathIndex = matchIndex;
            mathMatch = match.group(0);
          }
        }
      }

      if (nextMathIndex != null && mathMatch != null) {
        // 数式の前のテキストを追加
        if (nextMathIndex > currentIndex) {
          parts.add(_TextPart(
            content: text.substring(currentIndex, nextMathIndex),
            isMath: false,
          ));
        }

        // 数式を追加
        parts.add(_TextPart(
          content: mathMatch,
          isMath: true,
        ));

        currentIndex = nextMathIndex + mathMatch.length;
      } else {
        // 残りのテキストを追加
        parts.add(_TextPart(
          content: text.substring(currentIndex),
          isMath: false,
        ));
        break;
      }
    }

    return parts;
  }
}

class _TextPart {
  const _TextPart({
    required this.content,
    required this.isMath,
  });

  final String content;
  final bool isMath;
}
