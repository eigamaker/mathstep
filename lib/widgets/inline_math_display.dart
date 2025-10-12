import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../utils/asciimath_converter.dart';

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
      // AsciiMath形式をLaTeX形式に変換
      final latexExpression = AsciiMathConverter.asciiMathToLatex(mathExpression);
      final prepared = _prepareForDisplay(latexExpression);

      return Math.tex(
        prepared,
        mathStyle: MathStyle.text,
        textStyle: textStyle?.copyWith(
          fontSize: (textStyle?.fontSize ?? 16) * 0.9, // 少し小さく
        ),
        onErrorFallback: (_) => _buildFallback(mathExpression, textStyle),
      );
    } catch (e) {
      return _buildFallback(mathExpression, textStyle);
    }
  }

  Widget _buildFallback(String content, TextStyle? textStyle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Text(
        content,
        style: textStyle?.copyWith(
          fontFamily: 'monospace',
          fontSize: (textStyle?.fontSize ?? 16) * 0.8,
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
