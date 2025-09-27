/// Application-wide constants that are not user facing.
class AppConstants {
  // Storage keys
  static const String solutionsKey = 'solutions';
  static const String expressionsKey = 'expressions';

  // Sorting options
  static const String sortByTimestamp = 'timestamp';
  static const String sortByExpression = 'expression';

  // String cleaning patterns
  static const String multipleBackslashesPattern = r'\\{3,}';
  static const String replacementBackslashes = '\\\\';

  // Layout metrics
  static const double historyItemSpacing = 12.0;
  static const double largeIconSize = 64.0;

  // AdMob configuration (Rewarded Ad only)
  static const String testRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String productionRewardedAdUnitId =
      'ca-app-pub-1998641949557439~5856126902';

  // Default identifiers
  static const String unknownId = 'unknown';
}
