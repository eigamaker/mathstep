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
          // 蜈・・謨ｰ蠑剰｡ｨ遉ｺ
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

          // 繧ｿ繝・
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: l10n.solutionTabMain),
              Tab(text: l10n.solutionTabAlternative),
            ],
          ),

          // 繧ｿ繝悶さ繝ｳ繝・Φ繝・
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 隗｣豕輔ち繝・
                _buildSolutionTab(),
                // 蛻･隗｣繝ｻ讀懃ｮ励ち繝・
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
          // 蛻･隗｣繧ｻ繧ｯ繧ｷ繝ｧ繝ｳ
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

          // 讀懃ｮ励・螳夂ｾｩ蝓溘メ繧ｧ繝・け繧ｻ繧ｯ繧ｷ繝ｧ繝ｳ
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
    // 蜈ｱ譛画ｩ溯・縺ｮ螳溯｣・
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.solutionShareNotAvailable)),
    );
  }

  void _saveToHistory() {
    // 螻･豁ｴ菫晏ｭ俶ｩ溯・縺ｮ螳溯｣・
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.solutionSaveSuccess)));
  }
}
