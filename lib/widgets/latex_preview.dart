import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'simple_math_display.dart';

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
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: math.max(100, MediaQuery.of(context).size.width - 32),
            ),
            child: _buildMathExpression(),
          ),
        ),
      ),
    );
  }

  Widget _buildMathExpression() {
    // SimpleMathDisplayの表示ロジックを優先使用
    return SimpleMathDisplay(expression: expression);
  }
}
