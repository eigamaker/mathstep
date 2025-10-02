import 'package:flutter/material.dart';

import '../localization/localization_extensions.dart';
import '../models/math_expression.dart';
import '../models/solution.dart';
import '../widgets/alternative_solution_tab.dart';
import '../widgets/latex_preview.dart';
import '../widgets/solution_step_card.dart';
import '../widgets/math_expansion_display.dart';
import '../widgets/verification_section.dart';
import '../widgets/math_graph_display.dart';
import '../utils/asciimath_converter.dart';

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
        title: Text(l10n.solutionAppBarTitle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
            const Tab(text: 'グラフ'),
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
              children: [_buildStepsTab(), _buildAlternativeTab(), _buildGraphTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsTab() {
    final steps = widget.solution.steps;
    if (steps.isEmpty) {
      return const _EmptyState(message: 'No steps were returned by the API.');
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 数式展開型の解法表示
        MathExpansionDisplay(steps: steps),
        const SizedBox(height: 16),
        // 従来のステップカードも表示（詳細な説明用）
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

    if ((alternativeSolutions == null || alternativeSolutions.isEmpty) &&
        verification == null) {
      return const _EmptyState(message: 'No additional material yet.');
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
            (alt) => AlternativeSolutionTab(alternativeSolution: alt),
          ),
          const SizedBox(height: 24),
        ],
        if (verification != null) ...[
          Text(
            context.l10n.solutionVerificationSectionTitle,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          VerificationSection(verification: verification),
        ],
      ],
    );
  }

  Widget _buildGraphTab() {
    // 元の数式をAsciiMath形式に変換
    final asciiMathExpression = AsciiMathConverter.calculatorToAsciiMath(
      widget.mathExpression.calculatorSyntax,
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '関数のグラフ',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'f(x) = $asciiMathExpression',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontFamily: 'monospace',
            ),
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
            constraints: const BoxConstraints(
              minHeight: 80, // 分数表示のための最小高さを設定
            ),
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
