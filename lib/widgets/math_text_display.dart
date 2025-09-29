import 'package:flutter/material.dart';
import '../utils/math_text_processor.dart';
import '../utils/asciimath_converter.dart';
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
    // AsciiMath形式をLaTeX形式に変換して表示
    final latexExpression = AsciiMathConverter.asciiMathToLatex(mathExpression);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.blue.shade200, width: 1),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 40),
        child: LatexPreview(expression: latexExpression),
      ),
    );
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
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: Text(
              MathTextProcessor.mathToReadableText(segment.content),
              style: TextStyle(
                fontSize: (textStyle?.fontSize ?? 14) * 0.9,
                fontFamily: 'monospace',
                color: Colors.grey.shade700,
              ),
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
