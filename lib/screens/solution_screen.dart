import 'package:flutter/material.dart';
import '../models/math_expression.dart';
import '../models/solution.dart';
import '../localization/localization_extensions.dart';
import '../widgets/latex_preview.dart';
import '../widgets/solution_step_card.dart';
import '../widgets/alternative_solution_tab.dart';
import '../widgets/verification_section.dart';

class SolutionScreen extends StatefulWidget {
  final MathExpression mathExpression;
  final Solution solution;

  const SolutionScreen({
    super.key,
    required this.mathExpression,
    required this.solution,
  });

  @override
  State<SolutionScreen> createState() => _SolutionScreenState();
}

class _SolutionScreenState extends State<SolutionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<SolutionStep> _expandedSteps = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleStepExpansion(String stepId) {
    setState(() {
      if (_expandedSteps.any((step) => step.id == stepId)) {
        _expandedSteps.removeWhere((step) => step.id == stepId);
      } else {
        final step = widget.solution.steps.firstWhere((s) => s.id == stepId);
        _expandedSteps.add(step);
      }
    });
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
      ),
      body: Column(
        children: [
          // 問題文エリア
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.solutionProblemLabel,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                if (widget.solution.problemStatement != null) ...[
                  Text(
                    widget.solution.problemStatement!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                LatexPreview(expression: widget.mathExpression.latexExpression),
              ],
            ),
          ),

          // タブ
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: l10n.solutionTabMain),
              Tab(text: l10n.solutionTabAlternative),
            ],
          ),

          // タブコンテンツ
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // メインタブ
                _buildSolutionTab(),
                // 代替解法タブ
                _buildAlternativeTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSolutionTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.solution.steps.length,
      itemBuilder: (context, index) {
        final step = widget.solution.steps[index];
        final isExpanded = _expandedSteps.any((s) => s.id == step.id);

        return SolutionStepCard(
          step: step,
          isExpanded: isExpanded,
          onToggleExpansion: () => _toggleStepExpansion(step.id),
        );
      },
    );
  }

  Widget _buildAlternativeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 代替解法
          if (widget.solution.alternativeSolutions != null &&
              widget.solution.alternativeSolutions!.isNotEmpty) ...[
            Text(
              context.l10n.solutionAlternativeSectionTitle,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...widget.solution.alternativeSolutions!.map(
              (altSolution) =>
                  AlternativeSolutionTab(alternativeSolution: altSolution),
            ),
            const SizedBox(height: 24),
          ],

          // 検証・確認セクション
          if (widget.solution.verification != null) ...[
            Text(
              context.l10n.solutionVerificationSectionTitle,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            VerificationSection(verification: widget.solution.verification!),
          ],
        ],
      ),
    );
  }

  void _shareSolution() {
    // 共有機能の実装
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.solutionShareNotAvailable)),
    );
  }

  void _saveToHistory() {
    // 履歴保存の実装
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.solutionSaveSuccess)));
  }
}
