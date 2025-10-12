import 'package:flutter/material.dart';

import '../localization/localization_extensions.dart';
import '../utils/math_expression_utils.dart';

class CommonUIComponents {
  CommonUIComponents._();

  static Widget buildSectionTitle(
    String title, {
    required IconData icon,
    required Color color,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  static Widget buildCardContainer({
    required Widget child,
    required ThemeData theme,
    Color? backgroundColor,
    Color? borderColor,
    double borderRadius = 12.0,
    EdgeInsets? padding,
  }) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: (borderColor ?? theme.colorScheme.outline).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: child,
    );
  }

  static Widget buildDivider(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 1,
      color: theme.colorScheme.outline.withOpacity(0.2),
    );
  }

  static Widget buildStepTitleBadge({
    required BuildContext context,
    required String title,
    required int index,
    required ThemeData theme,
  }) {
    final label = context.l10n.solutionStepBadgeLabel(index + 1, title);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  static String cleanDescription(String description) {
    return MathExpressionUtils.cleanDescription(description);
  }
}
