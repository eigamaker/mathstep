import 'package:flutter/material.dart';

import '../models/solution.dart';
import 'latex_preview.dart';

class SolutionStepCard extends StatelessWidget {
  const SolutionStepCard({super.key, required this.step, required this.index});

  final SolutionStep step;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ステップタイトル
            _buildStepTitle(theme),
            const SizedBox(height: 12),
            // 統合された説明と数式表示
            _buildIntegratedContent(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTitle(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Step ${index + 1}: ${step.title}',
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _buildIntegratedContent(ThemeData theme) {
    // 説明文と数式を統合して表示
    final hasLatex = step.latexExpression != null && 
                     step.latexExpression!.trim().isNotEmpty;
    
    if (!hasLatex) {
      // 数式がない場合は説明文のみ
      return _buildEnhancedDescription(step.description, theme);
    }

    // 数式がある場合は統合表示
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 説明文（改善されたスタイル）
          _buildEnhancedDescription(step.description, theme),
          const SizedBox(height: 16),
          // 数式表示（区切り線付き）
          Container(
            width: double.infinity,
            height: 1,
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
          const SizedBox(height: 12),
          // 数式プレビュー
          _buildMathExpression(theme),
        ],
      ),
    );
  }

  Widget _buildEnhancedDescription(String description, ThemeData theme) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 説明文のアイコン
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '解説',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 説明文（数式表現を除去してプレーンなテキストのみ）
          Text(
            _cleanDescription(description),
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.6,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMathExpression(ThemeData theme) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 100, // 分数表示のための最小高さを設定
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.functions,
                size: 16,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(width: 6),
              Text(
                '数式',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LatexPreview(
            expression: step.latexExpression!,
            showBorder: false,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
          ),
        ],
      ),
    );
  }

  String _cleanDescription(String description) {
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
    
    return cleaned;
  }
}
