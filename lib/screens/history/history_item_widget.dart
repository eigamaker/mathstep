import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_constants.dart';
import '../../localization/localization_extensions.dart';
import '../../providers/solution_storage_provider.dart';
import '../../widgets/latex_preview.dart';
import 'history_state.dart';

/// 履歴項目を表示するウィジェット
class HistoryItemWidget extends StatelessWidget {
  const HistoryItemWidget({
    super.key,
    required this.item,
    required this.onView,
    required this.onDelete,
  });

  final MathExpressionWithSolution item;
  final VoidCallback onView;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.historyItemSpacing),
      child: InkWell(
        onTap: onView,
        borderRadius: BorderRadius.circular(
          AppConstants.historyItemBorderRadius,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.historyItemPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildExpressionPreview(),
              const SizedBox(height: AppConstants.historyItemSpacing),
              _buildExpressionText(context),
              const SizedBox(height: 8),
              if (item.solution.problemStatement != null)
                _buildProblemStatement(),
              const SizedBox(height: 8),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpressionPreview() {
    return Container(
      height: AppConstants.historyItemHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: LatexPreview(expression: item.expression.latexExpression),
      ),
    );
  }

  Widget _buildExpressionText(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            item.expression.calculatorSyntax,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'monospace',
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy, size: AppConstants.iconSize),
          onPressed: () => _copyToClipboard(context),
          tooltip: context.l10n.historyCopyTooltip,
        ),
      ],
    );
  }

  Widget _buildProblemStatement() {
    return Text(
      item.solution.problemStatement!,
      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
      maxLines: AppConstants.maxHistoryItemLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          DateTimeFormatter.formatRelative(
            item.expression.timestamp,
            context.l10n,
          ),
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.visibility, size: AppConstants.iconSize),
              onPressed: onView,
              tooltip: context.l10n.historyViewTooltip,
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: AppConstants.iconSize),
              onPressed: onDelete,
              tooltip: context.l10n.commonDeleteButton,
            ),
          ],
        ),
      ],
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: item.expression.calculatorSyntax));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.historyCopySuccessMessage),
        duration: const Duration(
          seconds: AppConstants.maxSnackBarDurationSeconds,
        ),
      ),
    );
  }
}
