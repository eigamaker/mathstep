import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'simple_math_display.dart';

class LatexPreview extends StatelessWidget {
  const LatexPreview({super.key, required this.expression});

  final String expression;

  @override
  Widget build(BuildContext context) {
    final trimmed = expression.trim();
    if (trimmed.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SimpleMathDisplay(expression: trimmed),
      ),
    );
  }
}
