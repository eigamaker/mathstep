// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MathStep';

  @override
  String get commonErrorTitle => 'Error';

  @override
  String get commonOkButton => 'OK';

  @override
  String get commonCancelButton => 'Cancel';

  @override
  String get commonDeleteButton => 'Delete';

  @override
  String get commonCloseButton => 'Close';

  @override
  String get commonClear => 'Clear';

  @override
  String get homeGenerating => 'Generating...';

  @override
  String get homeInputRequired => 'Please enter an expression.';

  @override
  String get homeApiKeyMissingSnack => 'OpenAI API key is not configured.';

  @override
  String get homeApiKeyMissingDialogTitle => 'API key required';

  @override
  String get homeApiKeyMissingDialogMessage =>
      'OpenAI API key is not configured.\n\nHow to set it:\n1. Create a .env file in the project root\n2. Add the line: OPENAI_API_KEY=your_api_key_here\n3. Restart the app\n\nYou can obtain an API key from the official OpenAI website.';

  @override
  String get homeSendingToChatGpt => 'Sending to ChatGPT...';

  @override
  String get homeApiConnectionErrorTitle => 'API connection error';

  @override
  String get homeApiConnectionErrorMessage =>
      'Failed to reach the ChatGPT API.\n\nCheck the following:\n• Verify your internet connection\n• Make sure the API key is set correctly\n• Confirm that your OpenAI usage limits have not been reached';

  @override
  String get homeApiResponseErrorTitle => 'API response error';

  @override
  String get homeApiResponseErrorMessage =>
      'The ChatGPT API returned an empty response.\n\nPlease verify your API key and network connection.';

  @override
  String get homeGenericErrorSnack => 'An error occurred.';

  @override
  String get homePlaceholderTitle => 'Enter an expression to begin';

  @override
  String get homePlaceholderSubtitle =>
      'Use the keypad or the formula editor to enter an expression.';

  @override
  String get homeExpressionFieldLabel => 'Expression';

  @override
  String get homeExpressionHint => 'Example: (2x+1)/(x-3) = cbrt(x+2)';

  @override
  String get homeConditionFieldLabel => 'Conditions or target (optional)';

  @override
  String get homeConditionHint =>
      'Example: Find the minimum when x > 0, determine the number of real solutions';

  @override
  String get adLoadingMessage => 'Loading an ad...';

  @override
  String get adLoadFailedMessage => 'Failed to load the ad.';

  @override
  String get adRewardMessage => 'Solution unlocked!';

  @override
  String get adNotReadyMessage => 'The ad is not ready yet.';

  @override
  String get rewardAdShowingMessage => 'Showing ad...';

  @override
  String get rewardAdButtonReady => 'Show solution';

  @override
  String get historyTitle => 'History';

  @override
  String get historySortTooltip => 'Sort history';

  @override
  String get historySearchHint => 'Search expressions...';

  @override
  String historyErrorMessage(String error) {
    return 'Error: $error';
  }

  @override
  String historyDeleteConfirmation(String expression) {
    return 'Remove $expression from history?';
  }

  @override
  String get historySortDialogTitle => 'Sort';

  @override
  String get historySortOptionNewest => 'Newest first';

  @override
  String get historySortOptionExpression => 'By expression';

  @override
  String get historySortOrderAscending => 'Ascending';

  @override
  String get historyCopyTooltip => 'Copy expression';

  @override
  String get historyViewTooltip => 'View solution';

  @override
  String get historyCopySuccessMessage =>
      'Copied the expression to the clipboard.';

  @override
  String get historyEmptyTitle => 'No history yet';

  @override
  String get historyEmptyMessage =>
      'Enter an expression and generate a solution to see it listed here.';

  @override
  String relativeTimeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String relativeTimeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String relativeTimeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String get relativeTimeJustNow => 'Just now';

  @override
  String get guideHintTitle => '💡 Tips';

  @override
  String get languageSelectionTitle => 'Language';

  @override
  String get languageSelectionHeading => 'Choose your language';

  @override
  String get languageSelectionDescription =>
      'Pick the language you would like to use in the app.';

  @override
  String get languageSelectionCurrentLabel => 'Currently selected';

  @override
  String get languageSelectionContinue => 'Continue';

  @override
  String get languageSelectionDone => 'Done';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguageLabel => 'Language';

  @override
  String settingsLanguageDescription(String native, String english) {
    return 'Currently set to $native ($english)';
  }

  @override
  String get splashTagline => 'Step-by-step math explanations';

  @override
  String get splashTapToStart => 'Tap to start';

  @override
  String get navigationHome => 'Home';

  @override
  String get navigationHistory => 'History';

  @override
  String get navigationSettings => 'Settings';

  @override
  String get solutionStepExpressionLabel => 'Expression:';

  @override
  String get solutionStepDescriptionLabel => 'Detailed explanation:';

  @override
  String get guideAppBarTitle => 'Using the keypad';

  @override
  String get guideCategoryExponentsTitle => 'Exponents & radicals';

  @override
  String get guideCategoryFractionsTitle => 'Fractions & absolute values';

  @override
  String get guideCategoryTrigLogTitle =>
      'Trigonometric & logarithmic functions';

  @override
  String get guideCategorySeriesIntegralsTitle =>
      'Series, integrals & products';

  @override
  String get guideCategoryComplexTitle => 'Complex numbers & combinations';

  @override
  String guideExpressionLabel(String expression) {
    return 'Expression: $expression';
  }

  @override
  String get guideKeySequenceLabel => 'Key sequence:';

  @override
  String get guideTipAutoParenthesis =>
      'Function keys (sin, cos, √, etc.) automatically insert an opening parenthesis.';

  @override
  String get guideTipExponentKeys =>
      'Use the x^y key for simple exponents and x^() when the exponent is an expression.';

  @override
  String get guideTipArrowKeys =>
      'Use the arrow keys (← →) to move the cursor.';

  @override
  String get guideTipDeleteKey =>
      'Press DEL to delete the character to the left of the cursor.';

  @override
  String get guideTipSigmaPi =>
      'For Σ, Π, and ∫ keys, use commas to enter lower bound, upper bound, and expression.';

  @override
  String get guideTipFractionKey =>
      'Use the a/b key for fractions and separate the numerator and denominator with the comma key.';

  @override
  String get guideTipCloseParenthesis =>
      'Close parentheses with the ) key whenever necessary.';

  @override
  String homeSampleLoaded(String expression) {
    return 'Loaded sample expression: $expression';
  }

  @override
  String get homeClipboardPasteSuccess =>
      'Pasted the expression from the clipboard.';

  @override
  String get homeClipboardEmpty => 'Clipboard is empty.';

  @override
  String get homeClipboardPasteFailed => 'Failed to paste from the clipboard.';

  @override
  String get homeSampleTooltip => 'Load a sample expression';

  @override
  String get homePasteTooltip => 'Paste from clipboard';

  @override
  String get historyDeleteDialogTitle => 'Remove from history';

  @override
  String get historyCopyAndPasteMessage =>
      'Copied the expression and pasted it into the input field.';

  @override
  String get historyCopyAndPasteTooltip => 'Copy and paste into the input';

  @override
  String get settingsOtherSettingsTitle => 'Other settings';

  @override
  String get settingsOtherSettingsComingSoon => 'Coming soon';

  @override
  String get settingsOtherSettingsDescription =>
      'Additional options will be added in future updates.';

  @override
  String settingsLanguageChanged(String language) {
    return 'Language changed to $language';
  }

  @override
  String get solutionAppBarTitle => 'Solution';

  @override
  String get solutionProblemLabel => 'Problem:';

  @override
  String get solutionTabMain => 'Solution';

  @override
  String get solutionTabAlternative => 'Alternatives & checks';

  @override
  String get solutionAlternativeSectionTitle => 'Alternative solutions';

  @override
  String get solutionVerificationSectionTitle => 'Verification & domain check';

  @override
  String get solutionShareNotAvailable =>
      'Sharing will be available in a future update.';

  @override
  String get solutionSaveSuccess => 'Saved to history.';

  @override
  String get verificationDomainCheckTitle => 'Domain check';

  @override
  String get verificationVerificationTitle => 'Verification';

  @override
  String get verificationCommonPitfallsTitle => 'Common pitfalls';
}
