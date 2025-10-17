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
  // Test Ad Unit IDs (commented out for production)
  // static const String testRewardedAdUnitId =
  //     'ca-app-pub-3940256099942544/5224354917';

  // Production Ad Unit IDs
  static const String productionRewardedAdUnitIdAndroid =
      'ca-app-pub-1998641949557439/3057244181';

  static const String productionRewardedAdUnitIdIOS =
      'ca-app-pub-1998641949557439/4530086849';

  static String getRewardedAdUnitId() {
    // Always use production IDs (test IDs are commented out above)
    // if (kDebugMode) {
    //   return testRewardedAdUnitId;
    // }

    if (Platform.isIOS) {
      return productionRewardedAdUnitIdIOS;
    }

    if (Platform.isAndroid) {
      return productionRewardedAdUnitIdAndroid;
    }

    return productionRewardedAdUnitIdAndroid;
  }

  // Default identifiers
  static const String unknownId = 'unknown';
}

