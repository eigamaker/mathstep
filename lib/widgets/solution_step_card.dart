import 'package:flutter/material.dart';

import '../models/solution.dart';
import 'latex_preview.dart';
import 'math_text_display.dart';

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
            Text(
              'Step ${index + 1}: ${step.title}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ReadableMathTextDisplay(
              text: step.description,
              textStyle: theme.textTheme.bodyMedium,
            ),
            if (step.latexExpression != null &&
                step.latexExpression!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              LatexPreview(expression: step.latexExpression!),
            ],
          ],
        ),
      ),
    );
  }
}
