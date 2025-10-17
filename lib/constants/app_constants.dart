import 'dart:io';

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
  // Switch between test and production by commenting/uncommenting the appropriate lines below

  static String getRewardedAdUnitId() {
    // TEST Ad Unit ID (uncomment for testing)
    // return 'ca-app-pub-3940256099942544/5224354917';

    // PRODUCTION Ad Unit IDs (uncomment for production)
    if (Platform.isIOS) {
      return 'ca-app-pub-1998641949557439/4530086849';
    }
    return 'ca-app-pub-1998641949557439/3057244181';
  }

  // Default identifiers
  static const String unknownId = 'unknown';
}
