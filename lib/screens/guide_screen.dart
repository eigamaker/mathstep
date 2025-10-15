import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../constants/app_colors.dart';
import '../localization/localization_extensions.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final categories = <_GuideCategory>[
      _GuideCategory(
        title: l10n.guideCategoryExponentsTitle,
        examples: const [
          _GuideExample(expression: 'x^2', keySequence: ['x', 'x^y', '2']),
          _GuideExample(
            expression: '2^{x+1}',
            keySequence: ['2', 'x^y', '(', 'x', '+', '1', ')'],
          ),
          _GuideExample(
            expression: 'e^{x^2}',
            keySequence: ['e', 'x^y', '(', 'x', 'x^y', '2', ')'],
          ),
          _GuideExample(
            expression: 'pow(2, 3)',
            keySequence: ['x^()', '2', ',', '3', ')'],
          ),
          _GuideExample(expression: '\\sqrt{9}', keySequence: ['√', '9', ')']),
          _GuideExample(
            expression: '\\sqrt[3]{8}',
            keySequence: ['∛', '8', ')'],
          ),
          _GuideExample(
            expression: '\\sqrt[4]{16}',
            keySequence: ['ⁿ√', '4', ',', '16', ')'],
          ),
        ],
      ),
      _GuideCategory(
        title: l10n.guideCategoryFractionsTitle,
        examples: const [
          _GuideExample(
            expression: '\\frac{1}{2}',
            keySequence: ['a/b', '1', ',', '2', ')'],
          ),
          _GuideExample(
            expression: '\\frac{x+1}{x-1}',
            keySequence: ['a/b', 'x', '+', '1', ',', 'x', '-', '1', ')'],
          ),
          _GuideExample(expression: '|x|', keySequence: ['|x|', 'x', ')']),
          _GuideExample(
            expression: '|3+4i|',
            keySequence: ['|x|', '3', '+', '4', 'i', ')'],
          ),
        ],
      ),
      _GuideCategory(
        title: l10n.guideCategoryTrigLogTitle,
        examples: const [
          _GuideExample(
            expression: '\\sin(x)',
            keySequence: ['sin', 'x', ')'],
          ),
          _GuideExample(
            expression: '\\cos(x)',
            keySequence: ['cos', 'x', ')'],
          ),
          _GuideExample(
            expression: '\\tan(x)',
            keySequence: ['tan', 'x', ')'],
          ),
          _GuideExample(expression: '\\ln(e)', keySequence: ['ln', 'e', ')']),
          _GuideExample(
            expression: '\\log(100)',
            keySequence: ['log', '1', '0', '0', ')'],
          ),
        ],
      ),
      _GuideCategory(
        title: l10n.guideCategorySeriesIntegralsTitle,
        examples: const [
          _GuideExample(
            expression: '\\sum_{i=1}^{5} x_i',
            keySequence: ['Σ', 'i', '=', '1', ',', '5', ',', 'x', '_', 'i', ')'],
          ),
          _GuideExample(
            expression: '\\prod_{i=1}^{4} x_i',
            keySequence: ['Π', 'i', '=', '1', ',', '4', ',', 'x', '_', 'i', ')'],
          ),
          _GuideExample(
            expression: '\\int_{0}^{1} x^2 \\, dx',
            keySequence: [
              '∫', '0', ',', '1', ',', 'x', 'x^y', '2', ',', 'x', ')'
            ],
          ),
          _GuideExample(
            expression: '\\int_{0}^{\\pi/2} \\sin(x) \\, dx',
            keySequence: [
              '∫', '0', ',', 'π', '/', '2', ',', 'sin', 'x', ')', ',', 'x', ')'
            ],
          ),
        ],
      ),
      _GuideCategory(
        title: l10n.guideCategoryComplexTitle,
        examples: const [
          _GuideExample(expression: '3+4i', keySequence: ['3', '+', '4', 'i']),
          _GuideExample(
            expression: '\\overline{z}',
            keySequence: ['z*', 'z', ')'],
          ),
          _GuideExample(expression: '\\Re(z)', keySequence: ['Re', 'z', ')']),
          _GuideExample(expression: '\\Im(z)', keySequence: ['Im', 'z', ')']),
          _GuideExample(
            expression: 'P_{3}^{5}',
            keySequence: ['P', '5', ',', '3', ')'],
          ),
          _GuideExample(
            expression: 'C_{3}^{5}',
            keySequence: ['C', '5', ',', '3', ')'],
          ),
        ],
      ),
    ];

    final tips = [
      l10n.guideTipAutoParenthesis,
      l10n.guideTipExponentKeys,
      l10n.guideTipArrowKeys,
      l10n.guideTipDeleteKey,
      l10n.guideTipSigmaPi,
      l10n.guideTipIntegralNotation,
      l10n.guideTipFractionKey,
      l10n.guideTipCloseParenthesis,
    ];

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
              child: const Icon(Icons.help_outline, color: Colors.white, size: 20),
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
                l10n.guideAppBarTitle,
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final category in categories) ...[
              _buildCategory(context, category),
              const SizedBox(height: 24),
            ],
            SizedBox(height: categories.isEmpty ? 0 : 8),
            _buildTipsSection(context, tips),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(BuildContext context, _GuideCategory category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        for (final example in category.examples)
          _buildExample(context, example),
      ],
    );
  }

  Widget _buildExample(BuildContext context, _GuideExample example) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                context.l10n.guideExpressionLabel(''),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Math.tex(
                  example.expression,
                  mathStyle: MathStyle.text,
                  textStyle: const TextStyle(fontSize: 16, color: Colors.black87),
                  onErrorFallback: (_) => Text(
                    example.expression,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'monospace',
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.guideKeySequenceLabel,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: example.keySequence.map(_buildKeyChip).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyChip(String key) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        key,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }

  Widget _buildTipsSection(BuildContext context, List<String> tips) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.guideHintTitle,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          for (final tip in tips)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '• $tip',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GuideCategory {
  const _GuideCategory({required this.title, required this.examples});

  final String title;
  final List<_GuideExample> examples;
}

class _GuideExample {
  const _GuideExample({required this.expression, required this.keySequence});

  final String expression;
  final List<String> keySequence;
}
