import 'package:flutter/material.dart';

import '../models/solution.dart';
import 'latex_preview.dart';

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
        // 統合された説明と数式表示
        _buildIntegratedStep(theme, step),
        
        // 次のステップへの矢印（最後のステップ以外）
        if (index < steps.length - 1) ...[
          const SizedBox(height: 16),
          _buildArrow(theme),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildIntegratedStep(ThemeData theme, SolutionStep step) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 説明文（数式表現を除去してプレーンなテキストのみ）
          Text(
            _cleanExplanation(step.description),
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.6,
              color: theme.colorScheme.onSurface,
            ),
          ),
          
          // 数式表示（説明文の下に表示）
          if (step.latexExpression != null && step.latexExpression!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildMathExpression(theme, step.latexExpression!),
          ],
        ],
      ),
    );
  }

  Widget _buildMathExpression(ThemeData theme, String expression) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 80, // 分数表示のための最小高さを設定
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: LatexPreview(
        expression: expression,
        showBorder: false,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
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

  String _cleanExplanation(String description) {
    // 説明文から数式表現を除去してプレーンなテキストにする
    var cleaned = description;

    // 数式パターンを除去
    cleaned = cleaned.replaceAll(RegExp(r'sqrt\([^)]+\)'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\b(abs|sin|cos|tan|log|ln|sqrt|integral|sum|prod|limit|d/dx)\s*\([^)]+\)'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\b\w+\^\w+'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\b\w+/\w+'), '');
    cleaned = cleaned.replaceAll(RegExp(r'integral[^a-zA-Z]*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'limit[^a-zA-Z]*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'd/dx[^a-zA-Z]*'), '');

    // 余分な空白を整理
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    // 数学的な表現をより親しみやすく
    cleaned = cleaned.replaceAll('である', 'です');
    cleaned = cleaned.replaceAll('である。', 'です。');

    // ステップバイステップの説明を強調
    if (cleaned.contains('まず') || cleaned.contains('次に')) {
      cleaned = '📝 $cleaned';
    }

    // 重要なポイントを強調
    if (cleaned.contains('重要') || cleaned.contains('注意')) {
      cleaned = '⚠️ $cleaned';
    }

    // 結果を強調
    if (cleaned.contains('結果') || cleaned.contains('答え')) {
      cleaned = '✅ $cleaned';
    }

    // コツやヒントを強調
    if (cleaned.contains('コツ') || cleaned.contains('ヒント')) {
      cleaned = '💡 $cleaned';
    }

    return cleaned;
  }
}
