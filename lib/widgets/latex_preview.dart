import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'simple_math_display.dart';
import '../constants/app_colors.dart';

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
      height: double.infinity, // 親の高さ制約を尊重
      padding: const EdgeInsets.all(12), // 適切なパディングに調整
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
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
