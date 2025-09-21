import '../../constants/app_constants.dart';
import '../../providers/solution_storage_provider.dart';

/// 履歴画面の状態を管理するクラス
class HistoryState {
  const HistoryState({
    this.searchQuery = '',
    this.sortBy = AppConstants.sortByTimestamp,
    this.sortAscending = false,
  });

  final String searchQuery;
  final String sortBy;
  final bool sortAscending;

  HistoryState copyWith({
    String? searchQuery,
    String? sortBy,
    bool? sortAscending,
  }) {
    return HistoryState(
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}

/// 履歴項目のフィルタリングとソートを行うクラス
class HistoryFilter {
  static List<MathExpressionWithSolution> filterAndSort(
    List<MathExpressionWithSolution> items,
    HistoryState state,
  ) {
    var filtered = items;
    
    // 検索フィルタリング
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered.where((item) {
        return item.expression.calculatorSyntax.toLowerCase().contains(query) ||
            item.expression.latexExpression.toLowerCase().contains(query) ||
            (item.solution.problemStatement?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
    
    // ソート
    filtered.sort((a, b) {
      int comparison;
      switch (state.sortBy) {
        case AppConstants.sortByExpression:
          comparison = a.expression.calculatorSyntax.compareTo(b.expression.calculatorSyntax);
          break;
        case AppConstants.sortByTimestamp:
        default:
          comparison = a.expression.timestamp.compareTo(b.expression.timestamp);
          break;
      }
      return state.sortAscending ? comparison : -comparison;
    });
    
    return filtered;
  }
}

/// 日時フォーマット用のユーティリティクラス
class DateTimeFormatter {
  static String formatRelative(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}${AppConstants.daysAgo}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}${AppConstants.hoursAgo}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}${AppConstants.minutesAgo}';
    } else {
      return AppConstants.justNow;
    }
  }
}
