import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../localization/localization_extensions.dart';
import '../../providers/solution_storage_provider.dart';
import '../../widgets/latex_preview.dart';
import 'history_state.dart';

/// 陞ｻ・･雎・ｽｴ鬯・・蟯ｼ郢ｧ螳夲ｽ｡・ｨ驕会ｽｺ邵ｺ蜷ｶ・狗ｹｧ・ｦ郢ｧ・｣郢ｧ・ｸ郢ｧ・ｧ郢昴・繝ｨ
class HistoryItemWidget extends StatelessWidget {
  const HistoryItemWidget({
    super.key,
    required this.item,
    required this.onView,
    required this.onDelete,
    this.onCopyAndPaste,
  });

  final MathExpressionWithSolution item;
  final VoidCallback onView;
  final VoidCallback onDelete;
  final VoidCallback? onCopyAndPaste;

  /// 履歴画面のプレビューエリアの高さを計算
  double _calculateHistoryPreviewHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // 履歴画面では少し小さめに設定
    final minHeight = 100.0;
    final maxHeight = 200.0;
    final heightRatio = screenHeight > 800 ? 0.15 : 0.20; // 履歴では小さめに
    
    double calculatedHeight = screenHeight * heightRatio;
    
    // 最小・最大値でクランプ
    calculatedHeight = calculatedHeight.clamp(minHeight, maxHeight);
    
    // 横画面の場合は少し小さく
    if (screenWidth > screenHeight) {
      calculatedHeight *= 0.7;
    }
    
    return calculatedHeight;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.historyItemSpacing),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // 隰ｨ・ｰ陟台ｸ翫・郢晢ｽｬ郢晁侭ﾎ礼ｹ晢ｽｼ繝ｻ蛹ｻﾎ鍋ｹｧ・､郢晢ｽｳ鬩幢ｽｨ陋ｻ繝ｻ・ｼ繝ｻ
            _buildExpressionPreview(context),

            // 郢ｧ・｢郢ｧ・ｯ郢ｧ・ｷ郢晢ｽｧ郢晢ｽｳ郢晄㈱縺｡郢晢ｽｳ郢ｧ・ｨ郢晢ｽｪ郢ｧ・｢
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildExpressionPreview(BuildContext context) {
    return Container(
      height: _calculateHistoryPreviewHeight(context),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: LatexPreview(expression: item.expression.latexExpression),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 隴鯉ｽ･隴弱ｊ・｡・ｨ驕会ｽｺ
          Expanded(
            child: Text(
              DateTimeFormatter.formatRelative(
                item.expression.timestamp,
                context.l10n,
              ),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // 郢ｧ・｢郢ｧ・ｯ郢ｧ・ｷ郢晢ｽｧ郢晢ｽｳ郢晄㈱縺｡郢晢ｽｳ
          Row(
            children: [
              // 闕ｳ・ｭ髴・ｽｫ郢ｧ螳夲ｽｦ荵晢ｽ狗ｹ晄㈱縺｡郢晢ｽｳ
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.visibility,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  onPressed: onView,
                  tooltip: context.l10n.historyViewTooltip,
                ),
              ),
              const SizedBox(width: 8),

              // 郢ｧ・ｳ郢晄鱒繝ｻ+郢晏｣ｹ繝ｻ郢ｧ・ｹ郢晏現繝ｻ郢ｧ・ｿ郢晢ｽｳ
              if (onCopyAndPaste != null)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.content_copy,
                      color: Colors.green.shade700,
                      size: 20,
                    ),
                    onPressed: onCopyAndPaste,
                    tooltip: context.l10n.historyCopyAndPasteTooltip,
                  ),
                ),
              const SizedBox(width: 8),

              // 陷台ｼ∝求郢晄㈱縺｡郢晢ｽｳ
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red.shade700,
                    size: 20,
                  ),
                  onPressed: onDelete,
                  tooltip: context.l10n.commonDeleteButton,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
