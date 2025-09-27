import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
    Locale('zh', 'CN'),
    Locale('zh', 'TW'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'MathStep'**
  String get appTitle;

  /// No description provided for @commonErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonErrorTitle;

  /// No description provided for @commonOkButton.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOkButton;

  /// No description provided for @commonCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancelButton;

  /// No description provided for @commonDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDeleteButton;

  /// No description provided for @commonCloseButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonCloseButton;

  /// No description provided for @commonClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// No description provided for @homeGenerating.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get homeGenerating;

  /// No description provided for @homeInputRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter an expression.'**
  String get homeInputRequired;

  /// No description provided for @homeApiKeyMissingSnack.
  ///
  /// In en, this message translates to:
  /// **'OpenAI API key is not configured.'**
  String get homeApiKeyMissingSnack;

  /// No description provided for @homeApiKeyMissingDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'API key required'**
  String get homeApiKeyMissingDialogTitle;

  /// No description provided for @homeApiKeyMissingDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'OpenAI API key is not configured.\n\nHow to set it:\n1. Create a .env file in the project root\n2. Add the line: OPENAI_API_KEY=your_api_key_here\n3. Restart the app\n\nYou can obtain an API key from the official OpenAI website.'**
  String get homeApiKeyMissingDialogMessage;

  /// No description provided for @homeSendingToChatGpt.
  ///
  /// In en, this message translates to:
  /// **'Sending to ChatGPT...'**
  String get homeSendingToChatGpt;

  /// No description provided for @homeApiConnectionErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'API connection error'**
  String get homeApiConnectionErrorTitle;

  /// No description provided for @homeApiConnectionErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to reach the ChatGPT API.\n\nCheck the following:\n• Verify your internet connection\n• Make sure the API key is set correctly\n• Confirm that your OpenAI usage limits have not been reached'**
  String get homeApiConnectionErrorMessage;

  /// No description provided for @homeApiResponseErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'API response error'**
  String get homeApiResponseErrorTitle;

  /// No description provided for @homeApiResponseErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'The ChatGPT API returned an empty response.\n\nPlease verify your API key and network connection.'**
  String get homeApiResponseErrorMessage;

  /// No description provided for @homeGenericErrorSnack.
  ///
  /// In en, this message translates to:
  /// **'An error occurred.'**
  String get homeGenericErrorSnack;

  /// No description provided for @homePlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter an expression to begin'**
  String get homePlaceholderTitle;

  /// No description provided for @homePlaceholderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use the keypad or the formula editor to enter an expression.'**
  String get homePlaceholderSubtitle;

  /// No description provided for @homeExpressionFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Expression'**
  String get homeExpressionFieldLabel;

  /// No description provided for @homeExpressionHint.
  ///
  /// In en, this message translates to:
  /// **'Example: (2x+1)/(x-3) = cbrt(x+2)'**
  String get homeExpressionHint;

  /// No description provided for @homeConditionFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Conditions or target (optional)'**
  String get homeConditionFieldLabel;

  /// No description provided for @homeConditionHint.
  ///
  /// In en, this message translates to:
  /// **'Example: Find the minimum when x > 0, determine the number of real solutions'**
  String get homeConditionHint;

  /// No description provided for @adLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'Loading an ad...'**
  String get adLoadingMessage;

  /// No description provided for @adLoadFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to load the ad.'**
  String get adLoadFailedMessage;

  /// No description provided for @adRewardMessage.
  ///
  /// In en, this message translates to:
  /// **'Solution unlocked!'**
  String get adRewardMessage;

  /// No description provided for @adNotReadyMessage.
  ///
  /// In en, this message translates to:
  /// **'The ad is not ready yet.'**
  String get adNotReadyMessage;

  /// No description provided for @rewardAdShowingMessage.
  ///
  /// In en, this message translates to:
  /// **'Showing ad...'**
  String get rewardAdShowingMessage;

  /// No description provided for @rewardAdButtonReady.
  ///
  /// In en, this message translates to:
  /// **'Show solution'**
  String get rewardAdButtonReady;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historySortTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sort history'**
  String get historySortTooltip;

  /// No description provided for @historySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search expressions...'**
  String get historySearchHint;

  /// No description provided for @historyErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String historyErrorMessage(String error);

  /// No description provided for @historyDeleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Remove {expression} from history?'**
  String historyDeleteConfirmation(String expression);

  /// No description provided for @historySortDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get historySortDialogTitle;

  /// No description provided for @historySortOptionNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get historySortOptionNewest;

  /// No description provided for @historySortOptionExpression.
  ///
  /// In en, this message translates to:
  /// **'By expression'**
  String get historySortOptionExpression;

  /// No description provided for @historySortOrderAscending.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get historySortOrderAscending;

  /// No description provided for @historyCopyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy expression'**
  String get historyCopyTooltip;

  /// No description provided for @historyViewTooltip.
  ///
  /// In en, this message translates to:
  /// **'View solution'**
  String get historyViewTooltip;

  /// No description provided for @historyCopySuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Copied the expression to the clipboard.'**
  String get historyCopySuccessMessage;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter an expression and generate a solution to see it listed here.'**
  String get historyEmptyMessage;

  /// No description provided for @relativeTimeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {1 day ago} other {{count} days ago}}'**
  String relativeTimeDaysAgo(int count);

  /// No description provided for @relativeTimeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {1 hour ago} other {{count} hours ago}}'**
  String relativeTimeHoursAgo(int count);

  /// No description provided for @relativeTimeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {1 minute ago} other {{count} minutes ago}}'**
  String relativeTimeMinutesAgo(int count);

  /// No description provided for @relativeTimeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get relativeTimeJustNow;

  /// No description provided for @guideHintTitle.
  ///
  /// In en, this message translates to:
  /// **'💡 Tips'**
  String get guideHintTitle;

  /// No description provided for @languageSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSelectionTitle;

  /// No description provided for @languageSelectionHeading.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get languageSelectionHeading;

  /// No description provided for @languageSelectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Pick the language you would like to use in the app.'**
  String get languageSelectionDescription;

  /// No description provided for @languageSelectionCurrentLabel.
  ///
  /// In en, this message translates to:
  /// **'Currently selected'**
  String get languageSelectionCurrentLabel;

  /// No description provided for @languageSelectionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get languageSelectionContinue;

  /// No description provided for @languageSelectionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get languageSelectionDone;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageLabel;

  /// No description provided for @settingsLanguageDescription.
  ///
  /// In en, this message translates to:
  /// **'Currently set to {native} ({english})'**
  String settingsLanguageDescription(String native, String english);

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Step-by-step math explanations'**
  String get splashTagline;

  /// No description provided for @splashTapToStart.
  ///
  /// In en, this message translates to:
  /// **'Tap to start'**
  String get splashTapToStart;

  /// No description provided for @navigationHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navigationHome;

  /// No description provided for @navigationHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navigationHistory;

  /// No description provided for @navigationSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navigationSettings;

  /// No description provided for @solutionStepExpressionLabel.
  ///
  /// In en, this message translates to:
  /// **'Expression:'**
  String get solutionStepExpressionLabel;

  /// No description provided for @solutionStepDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Detailed explanation:'**
  String get solutionStepDescriptionLabel;

  /// No description provided for @guideAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Using the keypad'**
  String get guideAppBarTitle;

  /// No description provided for @guideCategoryExponentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Exponents & radicals'**
  String get guideCategoryExponentsTitle;

  /// No description provided for @guideCategoryFractionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Fractions & absolute values'**
  String get guideCategoryFractionsTitle;

  /// No description provided for @guideCategoryTrigLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Trigonometric & logarithmic functions'**
  String get guideCategoryTrigLogTitle;

  /// No description provided for @guideCategorySeriesIntegralsTitle.
  ///
  /// In en, this message translates to:
  /// **'Series, integrals & products'**
  String get guideCategorySeriesIntegralsTitle;

  /// No description provided for @guideCategoryComplexTitle.
  ///
  /// In en, this message translates to:
  /// **'Complex numbers & combinations'**
  String get guideCategoryComplexTitle;

  /// No description provided for @guideExpressionLabel.
  ///
  /// In en, this message translates to:
  /// **'Expression: {expression}'**
  String guideExpressionLabel(String expression);

  /// No description provided for @guideKeySequenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Key sequence:'**
  String get guideKeySequenceLabel;

  /// No description provided for @guideTipAutoParenthesis.
  ///
  /// In en, this message translates to:
  /// **'Function keys (sin, cos, √, etc.) automatically insert an opening parenthesis.'**
  String get guideTipAutoParenthesis;

  /// No description provided for @guideTipExponentKeys.
  ///
  /// In en, this message translates to:
  /// **'Use the x^y key for simple exponents and x^() when the exponent is an expression.'**
  String get guideTipExponentKeys;

  /// No description provided for @guideTipArrowKeys.
  ///
  /// In en, this message translates to:
  /// **'Use the arrow keys (← →) to move the cursor.'**
  String get guideTipArrowKeys;

  /// No description provided for @guideTipDeleteKey.
  ///
  /// In en, this message translates to:
  /// **'Press DEL to delete the character to the left of the cursor.'**
  String get guideTipDeleteKey;

  /// No description provided for @guideTipSigmaPi.
  ///
  /// In en, this message translates to:
  /// **'For Σ, Π, and ∫ keys, use commas to enter lower bound, upper bound, and expression.'**
  String get guideTipSigmaPi;

  /// No description provided for @guideTipFractionKey.
  ///
  /// In en, this message translates to:
  /// **'Use the a/b key for fractions and separate the numerator and denominator with the comma key.'**
  String get guideTipFractionKey;

  /// No description provided for @guideTipCloseParenthesis.
  ///
  /// In en, this message translates to:
  /// **'Close parentheses with the ) key whenever necessary.'**
  String get guideTipCloseParenthesis;

  /// No description provided for @homeSampleLoaded.
  ///
  /// In en, this message translates to:
  /// **'Loaded sample expression: {expression}'**
  String homeSampleLoaded(String expression);

  /// No description provided for @homeClipboardPasteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Pasted the expression from the clipboard.'**
  String get homeClipboardPasteSuccess;

  /// No description provided for @homeClipboardEmpty.
  ///
  /// In en, this message translates to:
  /// **'Clipboard is empty.'**
  String get homeClipboardEmpty;

  /// No description provided for @homeClipboardPasteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to paste from the clipboard.'**
  String get homeClipboardPasteFailed;

  /// No description provided for @homeSampleTooltip.
  ///
  /// In en, this message translates to:
  /// **'Load a sample expression'**
  String get homeSampleTooltip;

  /// No description provided for @homePasteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Paste from clipboard'**
  String get homePasteTooltip;

  /// No description provided for @historyDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove from history'**
  String get historyDeleteDialogTitle;

  /// No description provided for @historyCopyAndPasteMessage.
  ///
  /// In en, this message translates to:
  /// **'Copied the expression and pasted it into the input field.'**
  String get historyCopyAndPasteMessage;

  /// No description provided for @historyCopyAndPasteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy and paste into the input'**
  String get historyCopyAndPasteTooltip;

  /// No description provided for @settingsOtherSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Other settings'**
  String get settingsOtherSettingsTitle;

  /// No description provided for @settingsOtherSettingsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get settingsOtherSettingsComingSoon;

  /// No description provided for @settingsOtherSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Additional options will be added in future updates.'**
  String get settingsOtherSettingsDescription;

  /// No description provided for @settingsLanguageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed to {language}'**
  String settingsLanguageChanged(String language);

  /// No description provided for @settingsLegalDocumentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Legal Documents'**
  String get settingsLegalDocumentsTitle;

  /// No description provided for @settingsLegalDocumentsDescription.
  ///
  /// In en, this message translates to:
  /// **'Please review our Privacy Policy and Terms of Service.'**
  String get settingsLegalDocumentsDescription;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @termsOfServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfServiceTitle;

  /// No description provided for @solutionAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Solution'**
  String get solutionAppBarTitle;

  /// No description provided for @solutionProblemLabel.
  ///
  /// In en, this message translates to:
  /// **'Problem:'**
  String get solutionProblemLabel;

  /// No description provided for @solutionTabMain.
  ///
  /// In en, this message translates to:
  /// **'Solution'**
  String get solutionTabMain;

  /// No description provided for @solutionTabAlternative.
  ///
  /// In en, this message translates to:
  /// **'Alternatives & checks'**
  String get solutionTabAlternative;

  /// No description provided for @solutionAlternativeSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Alternative solutions'**
  String get solutionAlternativeSectionTitle;

  /// No description provided for @solutionVerificationSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification & domain check'**
  String get solutionVerificationSectionTitle;

  /// No description provided for @solutionShareNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Sharing will be available in a future update.'**
  String get solutionShareNotAvailable;

  /// No description provided for @solutionSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Saved to history.'**
  String get solutionSaveSuccess;

  /// No description provided for @verificationDomainCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'Domain check'**
  String get verificationDomainCheckTitle;

  /// No description provided for @verificationVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verificationVerificationTitle;

  /// No description provided for @verificationCommonPitfallsTitle.
  ///
  /// In en, this message translates to:
  /// **'Common pitfalls'**
  String get verificationCommonPitfallsTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'CN':
            return AppLocalizationsZhCn();
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
