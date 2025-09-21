import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../localization/localization_extensions.dart';

/// 履歴が空の場合のプレースホルダーウィジェット
class EmptyHistoryPlaceholder extends StatelessWidget {
  const EmptyHistoryPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.history,
            size: AppConstants.largeIconSize,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.historyEmptyTitle,
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.historyEmptyMessage,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
