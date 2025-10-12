import 'package:flutter/material.dart';

import '../localization/localization_extensions.dart';
import '../models/solution.dart';
import 'common_ui_components.dart';
import 'latex_preview.dart';

class SolutionStepCard extends StatelessWidget {
  const SolutionStepCard({super.key, required this.step, required this.index});

  final SolutionStep step;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonUIComponents.buildStepTitleBadge(
              context: context,
              title: step.title,
              index: index,
              theme: theme,
            ),
            const SizedBox(height: 12),
            _buildIntegratedContent(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildIntegratedContent(BuildContext context, ThemeData theme) {
    final hasLatex =
        step.latexExpression != null && step.latexExpression!.trim().isNotEmpty;

    if (!hasLatex) {
      return _buildEnhancedDescription(context, step.description, theme);
    }

    return CommonUIComponents.buildCardContainer(
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEnhancedDescription(context, step.description, theme),
          const SizedBox(height: 16),
          CommonUIComponents.buildDivider(theme),
          const SizedBox(height: 12),
          _buildMathExpression(context, theme),
        ],
      ),
    );
  }

  Widget _buildEnhancedDescription(
    BuildContext context,
    String description,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonUIComponents.buildSectionTitle(
          context.l10n.solutionStepDescriptionLabel,
          icon: Icons.lightbulb_outline,
          color: theme.colorScheme.primary,
          theme: theme,
        ),
        const SizedBox(height: 8),
        Text(
          CommonUIComponents.cleanDescription(description),
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.6,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildMathExpression(BuildContext context, ThemeData theme) {
    return CommonUIComponents.buildCardContainer(
      theme: theme,
      backgroundColor: theme.colorScheme.surface,
      borderColor: theme.colorScheme.outline.withValues(alpha: 0.3),
      borderRadius: 8.0,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonUIComponents.buildSectionTitle(
            context.l10n.solutionStepExpressionLabel,
            icon: Icons.calculate,
            color: theme.colorScheme.secondary,
            theme: theme,
          ),
          const SizedBox(height: 12),
          if (step.latexExpression != null)
            LatexPreview(
              expression: step.latexExpression!,
              showBorder: false,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
            ),
        ],
      ),
    );
  }
}
