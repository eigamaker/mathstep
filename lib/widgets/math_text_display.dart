import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/math_text_processor.dart';
import '../utils/syntax_converter.dart';
import 'latex_preview.dart';

/// 数式とテキストを適切に表示するウィジェット
class MathTextDisplay extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final TextStyle? mathStyle;
  final double mathFontSize;

  const MathTextDisplay({
    super.key,
    required this.text,
    this.textStyle,
    this.mathStyle,
    this.mathFontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    // 数式を含まない場合は通常のテキストとして表示
    if (!MathTextProcessor.containsMath(text)) {
      return Text(
        text,
        style: textStyle ?? const TextStyle(fontSize: 14),
      );
    }

    // 数式を含む場合は分割して表示
    final segments = MathTextProcessor.parseTextWithMath(text);
    
    return Wrap(
      children: segments.map((segment) {
        if (segment.type == MathTextType.math) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            child: _buildMathWidget(segment.content),
          );
        } else {
          return Text(
            segment.content,
            style: textStyle ?? const TextStyle(fontSize: 14),
          );
        }
      }).toList(),
    );
  }

  Widget _buildMathWidget(String mathExpression) {
    // 不完全な数式（括弧が閉じられていない）のチェック
    if (_hasUnclosedParentheses(mathExpression)) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.orange.shade200, width: 1),
        ),
        child: Text(
          mathExpression,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontFamily: 'monospace',
          ),
        ),
      );
    }

    // 不完全な関数呼び出しのチェック（sin(, log(, cos( など）
    if (_hasIncompleteFunctionCall(mathExpression)) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.orange.shade200, width: 1),
        ),
        child: Text(
          mathExpression,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontFamily: 'monospace',
          ),
        ),
      );
    }

    // 不完全な累乗のチェック（x^, e^, x^(2 など）
    if (_hasIncompletePower(mathExpression)) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.orange.shade200, width: 1),
        ),
        child: Text(
          mathExpression,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontFamily: 'monospace',
          ),
        ),
      );
    }

    // 不完全な分数のチェック（1/, x/, sin(x)/ など）
    if (_hasIncompleteFraction(mathExpression)) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.orange.shade200, width: 1),
        ),
        child: Text(
          mathExpression,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontFamily: 'monospace',
          ),
        ),
      );
    }
    
    // SyntaxConverterを使用してLaTeX形式に変換
    final latexExpression = SyntaxConverter.calculatorToLatex(mathExpression);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 50, // 分数表示のための最小高さを設定
          maxHeight: 80, // 最大高さも増加
        ),
        child: _buildLatexPreview(latexExpression, mathExpression),
      ),
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

  Widget _buildLatexPreview(String latexExpression, String original) {
    try {
      return LatexPreview(expression: latexExpression);
    } catch (e) {
      // エラーが発生した場合はフォールバック表示
      return Container(
        padding: const EdgeInsets.all(8),
        child: Text(
          original,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontFamily: 'monospace',
          ),
        ),
      );
    }
  }
}

/// 数式を読みやすいテキストに変換して表示するウィジェット
class ReadableMathTextDisplay extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;

  const ReadableMathTextDisplay({
    super.key,
    required this.text,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('ReadableMathTextDisplay: Building with text: "$text"');
    
    if (text.isEmpty) {
      debugPrint('ReadableMathTextDisplay: Text is empty, returning SizedBox.shrink()');
      return const SizedBox.shrink();
    }

    // 数式を含まない場合は通常のテキストとして表示
    if (!MathTextProcessor.containsMath(text)) {
      debugPrint('ReadableMathTextDisplay: No math found, displaying as regular text');
      return Text(
        text,
        style: textStyle ?? const TextStyle(fontSize: 14),
      );
    }

    // 数式を含む場合は分割して表示
    final segments = MathTextProcessor.parseTextWithMath(text);
    
    return Wrap(
      children: segments.map((segment) {
        if (segment.type == MathTextType.math) {
          // SyntaxConverterを使用してLaTeX形式に変換
          final latexExpression = SyntaxConverter.calculatorToLatex(segment.content);
          
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: 40, // 分数表示のための最小高さを設定
                maxHeight: 60, // 最大高さも増加
              ),
              child: LatexPreview(expression: latexExpression),
            ),
          );
        } else {
          return Text(
            segment.content,
            style: textStyle ?? const TextStyle(fontSize: 14),
          );
        }
      }).toList(),
    );
  }
}
