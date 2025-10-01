import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'simple_math_display.dart';

class LatexPreview extends StatelessWidget {
  const LatexPreview({
    super.key, 
    required this.expression,
    this.showBorder = true,
    this.padding = const EdgeInsets.all(12),
  });

  final String expression;
  final bool showBorder;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final trimmed = expression.trim();
    if (trimmed.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: showBorder ? BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ) : null,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SimpleMathDisplay(expression: trimmed),
        ),
      ),
    );
  }
}
