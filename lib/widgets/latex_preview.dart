import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'simple_math_display.dart';

class LatexPreview extends StatelessWidget {
  const LatexPreview({
    super.key, 
    required this.expression,
    this.rawExpression,
    this.showBorder = true,
    this.padding = const EdgeInsets.all(12),
  });

  final String expression;
  final String? rawExpression;
  final bool showBorder;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final trimmedExpression = expression.trim();
    final trimmedRaw = rawExpression?.trim() ?? '';
    if (trimmedExpression.isEmpty && trimmedRaw.isEmpty) {
      return const SizedBox.shrink();
    }

    final effectiveExpression =
        trimmedExpression.isNotEmpty ? trimmedExpression : trimmedRaw;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 60, // 分数表示のための最小高さを設定
      ),
      padding: padding,
      decoration: showBorder ? BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ) : null,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SimpleMathDisplay(
          expression: effectiveExpression,
          rawExpression: trimmedRaw.isNotEmpty ? trimmedRaw : null,
        ),
      ),
    );
  }
}
