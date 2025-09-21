import 'package:mathstep/l10n/app_localizations.dart';

import '../../constants/app_constants.dart';
import '../../providers/solution_storage_provider.dart';

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

class HistoryFilter {
  static List<MathExpressionWithSolution> filterAndSort(
    List<MathExpressionWithSolution> items,
    HistoryState state,
  ) {
    var filtered = items;

    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered.where((item) {
        return item.expression.calculatorSyntax.toLowerCase().contains(query) ||
            item.expression.latexExpression.toLowerCase().contains(query) ||
            (item.solution.problemStatement?.toLowerCase().contains(query) ??
                false);
      }).toList();
    }

    filtered.sort((a, b) {
      int comparison;
      switch (state.sortBy) {
        case AppConstants.sortByExpression:
          comparison = a.expression.calculatorSyntax.compareTo(
            b.expression.calculatorSyntax,
          );
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

class DateTimeFormatter {
  static String formatRelative(DateTime dateTime, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return l10n.relativeTimeDaysAgo(difference.inDays);
    } else if (difference.inHours > 0) {
      return l10n.relativeTimeHoursAgo(difference.inHours);
    } else if (difference.inMinutes > 0) {
      return l10n.relativeTimeMinutesAgo(difference.inMinutes);
    } else {
      return l10n.relativeTimeJustNow;
    }
  }
}
