import 'package:flutter/material.dart';
import '../models/math_expression.dart';
import '../models/solution.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('解説'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareSolution,
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_add),
            onPressed: _saveToHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          // 元の数式表示
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '問題:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                LatexPreview(expression: widget.mathExpression.latexExpression),
              ],
            ),
          ),
          
          // タブ
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '解法'),
              Tab(text: '別解・検算'),
            ],
          ),
          
          // タブコンテンツ
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 解法タブ
                _buildSolutionTab(),
                // 別解・検算タブ
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
          // 別解セクション
          if (widget.solution.alternativeSolutions != null &&
              widget.solution.alternativeSolutions!.isNotEmpty) ...[
            const Text(
              '別解',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...widget.solution.alternativeSolutions!.map(
              (altSolution) => AlternativeSolutionTab(
                alternativeSolution: altSolution,
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // 検算・定義域チェックセクション
          if (widget.solution.verification != null) ...[
            const Text(
              '検算・定義域チェック',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            VerificationSection(
              verification: widget.solution.verification!,
            ),
          ],
        ],
      ),
    );
  }

  void _shareSolution() {
    // 共有機能の実装
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('共有機能は今後実装予定です')),
    );
  }

  void _saveToHistory() {
    // 履歴保存機能の実装
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('履歴に保存しました')),
    );
  }
}
