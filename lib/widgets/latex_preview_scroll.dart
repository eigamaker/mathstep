import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class LatexPreviewScrollable extends StatelessWidget {
  final String expression;

  const LatexPreviewScrollable({
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
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width - 32,
            ),
            child: _buildMathExpression(),
          ),
        ),
      ),
    );
  }

  Widget _buildMathExpression() {
    try {
      return Math.tex(
        expression,
        textStyle: const TextStyle(
          fontSize: 18,
          color: Colors.black87,
        ),
        mathStyle: MathStyle.display, // より大きな表示スタイル
      );
    } catch (e) {
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

