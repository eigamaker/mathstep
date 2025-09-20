import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class LatexPreview extends StatelessWidget {
  final String expression;

  const LatexPreview({
    super.key,
    required this.expression,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth - 32; // パディングを考慮
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: math.max(100, availableWidth), // 最小100pxを保証
              ),
              child: _buildMathExpression(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMathExpression() {
    try {
      // LaTeX式をMath.texでレンダリング
      return Math.tex(
        expression,
        textStyle: const TextStyle(
          fontSize: 24,
          color: Colors.black87,
        ),
        mathStyle: MathStyle.display, // より大きな表示スタイル
      );
    } catch (e) {
      // LaTeXの解析に失敗した場合は、プレーンテキストで表示
      return Text(
        expression,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.red,
          fontFamily: 'monospace',
        ),
      );
    }
  }
}
