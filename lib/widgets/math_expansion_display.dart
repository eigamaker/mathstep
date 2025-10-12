import 'package:flutter/material.dart';

import '../localization/localization_extensions.dart';
import '../models/solution.dart';
import 'latex_preview.dart';

class MathExpansionDisplay extends StatelessWidget {
  const MathExpansionDisplay({super.key, required this.steps});

  final List<SolutionStep> steps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSolutionTitle(context, theme),
          const SizedBox(height: 16),
          _buildMathExpansion(context, theme),
        ],
      ),
    );
  }

  Widget _buildSolutionTitle(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Icon(Icons.calculate, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          context.l10n.solutionTabMain,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildMathExpansion(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          _buildExpansionStep(context, theme, steps[i], i),
          if (i < steps.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildExpansionStep(
    BuildContext context,
    ThemeData theme,
    SolutionStep step,
    int index,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIntegratedStep(theme, step),
        if (index < steps.length - 1) ...[
          const SizedBox(height: 16),
          _buildArrow(context, theme),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildIntegratedStep(ThemeData theme, SolutionStep step) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _cleanExplanation(step.description),
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.6,
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (step.latexExpression != null &&
              step.latexExpression!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildMathExpression(theme, step.latexExpression!),
          ],
        ],
      ),
    );
  }

  Widget _buildMathExpression(ThemeData theme, String expression) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 80),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: LatexPreview(
        expression: expression,
        showBorder: false,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
      ),
    );
  }

  Widget _buildArrow(BuildContext context, ThemeData theme) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_downward,
              size: 16,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(width: 4),
            Text(
              context.l10n.solutionNextStepLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _cleanExplanation(String description) {
    var cleaned = description;

    cleaned = cleaned.replaceAll(RegExp(r'sqrt\([^)]+\)'), '');
    cleaned = cleaned.replaceAll(
      RegExp(
        r'\b(abs|sin|cos|tan|log|ln|sqrt|integral|sum|prod|limit|d/dx)\s*\([^)]+\)',
      ),
      '',
    );
    cleaned = cleaned.replaceAll(RegExp(r'\b\w+\^\w+'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\b\w+/\w+'), '');
    cleaned = cleaned.replaceAll(RegExp(r'integral[^a-zA-Z]*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'limit[^a-zA-Z]*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'd/dx[^a-zA-Z]*'), '');

    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    cleaned = cleaned.replaceAll('である', 'です');
    cleaned = cleaned.replaceAll('である。', 'です。');

    if (cleaned.contains('まず') || cleaned.contains('次に')) {
      cleaned = '📝 ';
    }

    if (cleaned.contains('重要') || cleaned.contains('注意')) {
      cleaned = '⚠️ ';
    }

    if (cleaned.contains('結果') || cleaned.contains('答え')) {
      cleaned = '✅ ';
    }

    if (cleaned.contains('コツ') || cleaned.contains('ヒント')) {
      cleaned = '💡 ';
    }

    return cleaned;
  }
}
