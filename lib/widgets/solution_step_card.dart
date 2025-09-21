import 'package:flutter/material.dart';
import '../models/solution.dart';
import '../localization/localization_extensions.dart';
import 'latex_preview.dart';

class SolutionStepCard extends StatelessWidget {
  final SolutionStep step;
  final bool isExpanded;
  final VoidCallback onToggleExpansion;

  const SolutionStepCard({
    super.key,
    required this.step,
    required this.isExpanded,
    required this.onToggleExpansion,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          step.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          step.description,
          maxLines: isExpanded ? null : 2,
          overflow: isExpanded ? null : TextOverflow.ellipsis,
        ),
        trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
        onExpansionChanged: (expanded) {
          onToggleExpansion();
        },
        children: [
          if (step.latexExpression != null && step.latexExpression!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.solutionStepExpressionLabel,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  LatexPreview(expression: step.latexExpression!),
                ],
              ),
            ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.solutionStepDescriptionLabel,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(step.description, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
