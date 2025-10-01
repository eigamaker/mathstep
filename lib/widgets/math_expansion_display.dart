import 'package:flutter/material.dart';

import '../models/solution.dart';
import 'latex_preview.dart';
import 'math_text_display.dart';

/// 数式展開型の解法表示ウィジェット
/// 数式の展開過程の中で説明やヒントを表示する
class MathExpansionDisplay extends StatelessWidget {
  const MathExpansionDisplay({
    super.key,
    required this.steps,
  });

  final List<SolutionStep> steps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 解法のタイトル
          _buildSolutionTitle(theme),
          const SizedBox(height: 16),
          // 数式展開過程
          _buildMathExpansion(theme),
        ],
      ),
    );
  }

  Widget _buildSolutionTitle(ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.functions,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          '解法',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildMathExpansion(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          _buildExpansionStep(theme, steps[i], i),
          if (i < steps.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildExpansionStep(ThemeData theme, SolutionStep step, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 数式表示
        if (step.latexExpression != null && step.latexExpression!.trim().isNotEmpty)
          _buildMathExpression(theme, step.latexExpression!),
        
        // 説明文（数式の下に表示）
        if (step.description.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildExplanation(theme, step.description),
        ],
        
        // 次のステップへの矢印（最後のステップ以外）
        if (index < steps.length - 1) ...[
          const SizedBox(height: 16),
          _buildArrow(theme),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildMathExpression(ThemeData theme, String expression) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 60, // 最小高さを設定
          maxHeight: 120, // 最大高さを設定
        ),
        child: LatexPreview(
          expression: expression,
          showBorder: false,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        ),
      ),
    );
  }

  Widget _buildExplanation(ThemeData theme, String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ReadableMathTextDisplay(
              text: _enhanceExplanation(description),
              textStyle: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrow(ThemeData theme) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_downward,
              size: 16,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(width: 4),
            Text(
              '次のステップ',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _enhanceExplanation(String description) {
    // 説明文をより分かりやすくするための改善
    var enhanced = description;

    // 数学的な表現をより親しみやすく
    enhanced = enhanced.replaceAll('である', 'です');
    enhanced = enhanced.replaceAll('である。', 'です。');

    // ステップバイステップの説明を強調
    if (enhanced.contains('まず') || enhanced.contains('次に')) {
      enhanced = '📝 $enhanced';
    }

    // 重要なポイントを強調
    if (enhanced.contains('重要') || enhanced.contains('注意')) {
      enhanced = '⚠️ $enhanced';
    }

    // 結果を強調
    if (enhanced.contains('結果') || enhanced.contains('答え')) {
      enhanced = '✅ $enhanced';
    }

    // コツやヒントを強調
    if (enhanced.contains('コツ') || enhanced.contains('ヒント')) {
      enhanced = '💡 $enhanced';
    }

    return enhanced;
  }
}
