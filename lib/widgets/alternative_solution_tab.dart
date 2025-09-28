import 'package:flutter/material.dart';

import '../models/solution.dart';
import 'solution_step_card.dart';

class AlternativeSolutionTab extends StatelessWidget {
  const AlternativeSolutionTab({super.key, required this.alternativeSolution});

  final AlternativeSolution alternativeSolution;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              alternativeSolution.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...alternativeSolution.steps.asMap().entries.map(
              (entry) => Padding(
                padding: EdgeInsets.only(top: entry.key == 0 ? 0 : 12),
                child: SolutionStepCard(step: entry.value, index: entry.key),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
