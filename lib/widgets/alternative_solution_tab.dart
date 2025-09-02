import 'package:flutter/material.dart';
import '../models/solution.dart';
import 'solution_step_card.dart';

class AlternativeSolutionTab extends StatefulWidget {
  final AlternativeSolution alternativeSolution;

  const AlternativeSolutionTab({
    super.key,
    required this.alternativeSolution,
  });

  @override
  State<AlternativeSolutionTab> createState() => _AlternativeSolutionTabState();
}

class _AlternativeSolutionTabState extends State<AlternativeSolutionTab> {
  bool _isExpanded = false;
  final List<SolutionStep> _expandedSteps = [];

  void _toggleStepExpansion(String stepId) {
    setState(() {
      if (_expandedSteps.any((step) => step.id == stepId)) {
        _expandedSteps.removeWhere((step) => step.id == stepId);
      } else {
        final step = widget.alternativeSolution.steps.firstWhere((s) => s.id == stepId);
        _expandedSteps.add(step);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          widget.alternativeSolution.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        trailing: Icon(
          _isExpanded ? Icons.expand_less : Icons.expand_more,
        ),
        onExpansionChanged: (expanded) {
          setState(() {
            _isExpanded = expanded;
          });
        },
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: widget.alternativeSolution.steps.map((step) {
                final isStepExpanded = _expandedSteps.any((s) => s.id == step.id);
                
                return SolutionStepCard(
                  step: step,
                  isExpanded: isStepExpanded,
                  onToggleExpansion: () => _toggleStepExpansion(step.id),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
