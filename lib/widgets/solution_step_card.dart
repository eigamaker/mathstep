import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../localization/localization_extensions.dart';
import '../models/solution.dart';
import 'common_ui_components.dart';
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
            CommonUIComponents.buildStepTitleBadge(
              context: context,
              title: step.title,
              index: index,
              theme: theme,
            ),
            const SizedBox(height: 12),
            _buildIntegratedContent(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildIntegratedContent(BuildContext context, ThemeData theme) {
    final hasLatex =
        step.latexExpression != null && step.latexExpression!.trim().isNotEmpty;

    if (!hasLatex) {
      return _buildEnhancedDescription(context, step.description, theme);
    }

    return CommonUIComponents.buildCardContainer(
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEnhancedDescription(context, step.description, theme),
          const SizedBox(height: 16),
          CommonUIComponents.buildDivider(theme),
          const SizedBox(height: 12),
          _buildMathExpression(context, theme),
        ],
      ),
    );
  }

  Widget _buildEnhancedDescription(
    BuildContext context,
    String description,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonUIComponents.buildSectionTitle(
          context.l10n.solutionStepDescriptionLabel,
          icon: Icons.lightbulb_outline,
          color: theme.colorScheme.primary,
          theme: theme,
        ),
        const SizedBox(height: 8),
        _buildDescriptionWithMath(CommonUIComponents.cleanDescription(description), theme),
      ],
    );
  }

  Widget _buildMathExpression(BuildContext context, ThemeData theme) {
    return CommonUIComponents.buildCardContainer(
      theme: theme,
      backgroundColor: theme.colorScheme.surface,
      borderColor: theme.colorScheme.outline.withValues(alpha: 0.3),
      borderRadius: 8.0,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonUIComponents.buildSectionTitle(
            context.l10n.solutionStepExpressionLabel,
            icon: Icons.calculate,
            color: theme.colorScheme.secondary,
            theme: theme,
          ),
          const SizedBox(height: 12),
          if (step.latexExpression != null)
            _buildMathTex(step.latexExpression!),
        ],
      ),
    );
  }

  Widget _buildMathTex(String latexExpression) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
      child: Math.tex(
        latexExpression,
        mathStyle: MathStyle.text,
        textStyle: const TextStyle(fontSize: 16, color: Colors.black87),
        onErrorFallback: (_) => Text(
          latexExpression,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'monospace',
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionWithMath(String description, ThemeData theme) {
    // 数式パターンを検出
    final mathPatterns = [
      // LaTeX数式（$...$ または $$...$$）
      RegExp(r'\$([^$]+)\$'),
      // 分数（a/b形式）
      RegExp(r'\b\w+/\w+\b'),
      // 累乗（x^y形式）
      RegExp(r'\b\w+\^\w+\b'),
      // 根号（sqrt(x)形式）
      RegExp(r'sqrt\([^)]+\)'),
      // 関数（sin, cos, tan, log, ln等）
      RegExp(r'\b(sin|cos|tan|log|ln|sqrt|abs|exp|ln|log)\s*\([^)]+\)'),
    ];

    // テキストを分割
    final parts = _splitTextByMath(description, mathPatterns);

    return Wrap(
      children: parts.map((part) {
        if (part.isMath) {
          return _buildInlineMath(part.content, theme);
        } else {
          return Text(
            part.content,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.6,
              color: theme.colorScheme.onSurface,
            ),
          );
        }
      }).toList(),
    );
  }

  Widget _buildInlineMath(String mathExpression, ThemeData theme) {
    // LaTeX数式の場合は$を除去
    String cleanExpression = mathExpression;
    if (mathExpression.startsWith('\$') && mathExpression.endsWith('\$')) {
      cleanExpression = mathExpression.substring(1, mathExpression.length - 1);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Math.tex(
        cleanExpression,
        mathStyle: MathStyle.text,
        textStyle: TextStyle(
          fontSize: 14,
          color: theme.colorScheme.onSurface,
        ),
        onErrorFallback: (_) => Text(
          mathExpression,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'monospace',
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  List<_TextPart> _splitTextByMath(String text, List<RegExp> patterns) {
    final List<_TextPart> parts = [];
    int currentIndex = 0;

    while (currentIndex < text.length) {
      int nextMathIndex = text.length;
      RegExp? matchedPattern;

      // 最も早い数式パターンを探す
      for (final pattern in patterns) {
        final match = pattern.firstMatch(text.substring(currentIndex));
        if (match != null) {
          final matchIndex = currentIndex + match.start;
          if (matchIndex < nextMathIndex) {
            nextMathIndex = matchIndex;
            matchedPattern = pattern;
          }
        }
      }

      // テキスト部分を追加
      if (nextMathIndex > currentIndex) {
        final textPart = text.substring(currentIndex, nextMathIndex);
        if (textPart.isNotEmpty) {
          parts.add(_TextPart(content: textPart, isMath: false));
        }
      }

      // 数式部分を追加
      if (matchedPattern != null) {
        final match = matchedPattern.firstMatch(text.substring(nextMathIndex));
        if (match != null) {
          final mathPart = text.substring(
            nextMathIndex + match.start,
            nextMathIndex + match.end,
          );
          parts.add(_TextPart(content: mathPart, isMath: true));
          currentIndex = nextMathIndex + match.end;
        } else {
          currentIndex = nextMathIndex + 1;
        }
      } else {
        // 残りのテキストを追加
        final remainingText = text.substring(currentIndex);
        if (remainingText.isNotEmpty) {
          parts.add(_TextPart(content: remainingText, isMath: false));
        }
        break;
      }
    }

    return parts;
  }
}

class _TextPart {
  const _TextPart({required this.content, required this.isMath});

  final String content;
  final bool isMath;
}
