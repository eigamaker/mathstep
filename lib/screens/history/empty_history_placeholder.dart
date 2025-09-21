import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

/// 履歴が空の場合のプレースホルダーウィジェット
class EmptyHistoryPlaceholder extends StatelessWidget {
  const EmptyHistoryPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: AppConstants.largeIconSize,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            AppConstants.emptyHistoryTitle,
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            AppConstants.emptyHistoryMessage,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
