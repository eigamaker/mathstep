import 'package:flutter/material.dart';

import '../localization/localization_extensions.dart';
import '../models/math_expression.dart';
import '../models/solution.dart';
import '../utils/asciimath_converter.dart';
import '../widgets/alternative_solution_tab.dart';
import '../widgets/latex_preview.dart';
import '../widgets/math_expansion_display.dart';
import '../widgets/math_graph_display.dart';
import '../widgets/solution_step_card.dart';
import '../widgets/verification_section.dart';

class SolutionScreen extends StatefulWidget {
  const SolutionScreen({
    super.key,
    required this.mathExpression,
    required this.solution,
  });

  final MathExpression mathExpression;
  final Solution solution;

  @override
  State<SolutionScreen> createState() => _SolutionScreenState();
}

class _SolutionScreenState extends State<SolutionScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.calculate, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                l10n.solutionAppBarTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: _shareSolution),
          IconButton(
            icon: const Icon(Icons.bookmark_add),
            onPressed: _saveToHistory,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.solutionTabMain),
            Tab(text: l10n.solutionTabAlternative),
            Tab(text: l10n.solutionTabGraph),
          ],
        ),
      ),
      body: Column(
        children: [
          _ProblemSummary(
            problemStatement: widget.solution.problemStatement,
            latexExpression: widget.mathExpression.latexExpression,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStepsTab(),
                _buildAlternativeTab(),
                _buildGraphTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsTab() {
    final steps = widget.solution.steps;
    final l10n = context.l10n;

    if (steps.isEmpty) {
      return _EmptyState(message: l10n.solutionStepsEmptyMessage);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        MathExpansionDisplay(steps: steps),
        const SizedBox(height: 16),
        ...steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SolutionStepCard(step: step, index: index),
          );
        }),
      ],
    );
  }

  Widget _buildAlternativeTab() {
    final alternativeSolutions = widget.solution.alternativeSolutions;
    final verification = widget.solution.verification;
    final l10n = context.l10n;

    if ((alternativeSolutions == null || alternativeSolutions.isEmpty) &&
        verification == null) {
      return _EmptyState(message: l10n.solutionAlternativeEmptyMessage);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (alternativeSolutions != null &&
            alternativeSolutions.isNotEmpty) ...[
          Text(
            context.l10n.solutionAlternativeSectionTitle,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...alternativeSolutions.map(
            (item) => AlternativeSolutionTab(alternativeSolution: item),
          ),
          const SizedBox(height: 24),
        ],
        if (verification != null)
          VerificationSection(verification: verification),
      ],
    );
  }

  Widget _buildGraphTab() {
    final asciiMathExpression = AsciiMathConverter.calculatorToAsciiMath(
      widget.mathExpression.calculatorSyntax,
    );
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.solutionGraphSectionTitle,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.solutionGraphFunctionLabel(asciiMathExpression),
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontFamily: 'monospace'),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: MathGraphDisplay(
              asciiMathExpression: asciiMathExpression,
              minX: -5.0,
              maxX: 5.0,
              minY: -10.0,
              maxY: 10.0,
            ),
          ),
        ],
      ),
    );
  }

  void _shareSolution() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.solutionShareNotAvailable)),
    );
  }

  void _saveToHistory() {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.solutionSaveSuccess)));
  }
}

class _ProblemSummary extends StatelessWidget {
  const _ProblemSummary({
    required this.problemStatement,
    required this.latexExpression,
  });

  final String? problemStatement;
  final String latexExpression;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.solutionProblemLabel,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            constraints: const BoxConstraints(minHeight: 80),
            child: LatexPreview(expression: latexExpression),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 48,
              color: Theme.of(context).hintColor,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
