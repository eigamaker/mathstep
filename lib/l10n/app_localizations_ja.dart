// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'MathStep';

  @override
  String get commonErrorTitle => 'エラー';

  @override
  String get commonOkButton => 'OK';

  @override
  String get commonCancelButton => 'キャンセル';

  @override
  String get commonDeleteButton => '削除';

  @override
  String get commonCloseButton => '閉じる';

  @override
  String get commonClear => 'クリア';

  @override
  String get homeGenerating => '生成中...';

  @override
  String get homeInputRequired => '数式を入力してください。';

  @override
  String get homeApiKeyMissingSnack => 'OpenAI APIキーが設定されていません。';

  @override
  String get homeApiKeyMissingDialogTitle => 'APIキーが必要です';

  @override
  String get homeApiKeyMissingDialogMessage =>
      'OpenAI APIキーが設定されていません。\n\n設定方法：\n1. プロジェクトルートに .env ファイルを作成\n2. OPENAI_API_KEY=your_api_key_here を記述\n3. アプリを再起動\n\nAPIキーはOpenAI公式サイトで取得できます。';

  @override
  String get homeSendingToChatGpt => 'ChatGPTに送信中...';

  @override
  String get homeApiConnectionErrorTitle => 'API接続エラー';

  @override
  String get homeApiConnectionErrorMessage =>
      'ChatGPT API への接続に失敗しました。\n\n確認事項：\n• インターネット接続を確認\n• APIキーが正しく設定されているか確認\n• OpenAI API の利用制限に達していないか確認';

  @override
  String get homeApiResponseErrorTitle => 'API応答エラー';

  @override
  String get homeApiResponseErrorMessage =>
      'ChatGPT API からの応答が空でした。\n\nAPIキーとネットワーク接続を確認してください。';

  @override
  String get homeGenericErrorSnack => 'エラーが発生しました。';

  @override
  String get homePlaceholderTitle => '数式を入力して開始しましょう';

  @override
  String get homePlaceholderSubtitle => 'テンキーまたは式エディタを使って数式を入力してください。';

  @override
  String get homeExpressionFieldLabel => '数式を入力';

  @override
  String get homeExpressionHint => '例: (2x+1)/(x-3) = cbrt(x+2)';

  @override
  String get homeConditionFieldLabel => '条件・求める解（任意）';

  @override
  String get homeConditionHint => '例: x > 0 のときの最小値を求めよ、実数解の個数を求めよ';

  @override
  String get adLoadingMessage => '広告を読み込み中...';

  @override
  String get adLoadFailedMessage => '広告の読み込みに失敗しました。';

  @override
  String get adRewardMessage => '解法を表示します！';

  @override
  String get adNotReadyMessage => '広告の準備がまだできていません。';

  @override
  String get rewardAdShowingMessage => '広告を表示中...';

  @override
  String get rewardAdButtonReady => '解法を表示';

  @override
  String get historyTitle => '履歴';

  @override
  String get historySortTooltip => '履歴を並び替え';

  @override
  String get historySearchHint => '数式を検索...';

  @override
  String historyErrorMessage(String error) {
    return 'エラー: $error';
  }

  @override
  String historyDeleteConfirmation(String expression) {
    return '$expression を履歴から削除しますか？';
  }

  @override
  String get historySortDialogTitle => '並び替え';

  @override
  String get historySortOptionNewest => '新しい順';

  @override
  String get historySortOptionExpression => '数式順';

  @override
  String get historySortOrderAscending => '昇順';

  @override
  String get historyCopyTooltip => '数式をコピー';

  @override
  String get historyViewTooltip => '解法を見る';

  @override
  String get historyCopySuccessMessage => '数式をクリップボードにコピーしました。';

  @override
  String get historyEmptyTitle => '履歴がありません';

  @override
  String get historyEmptyMessage => '数式を入力して解法を生成すると、ここに履歴が表示されます。';

  @override
  String relativeTimeDaysAgo(int count) {
    return '$count日前';
  }

  @override
  String relativeTimeHoursAgo(int count) {
    return '$count時間前';
  }

  @override
  String relativeTimeMinutesAgo(int count) {
    return '$count分前';
  }

  @override
  String get relativeTimeJustNow => 'たった今';

  @override
  String get guideHintTitle => '💡 ヒント';

  @override
  String get formulaEditorTitle => '式エディタ（数III対応）';

  @override
  String get formulaEditorApplyTooltip => '反映';

  @override
  String get formulaEditorFieldLabel => '電卓記法で編集（改行可）';

  @override
  String get languageSelectionTitle => '言語';

  @override
  String get languageSelectionHeading => '使用する言語を選択';

  @override
  String get languageSelectionDescription => 'アプリで利用する言語を選んでください。';

  @override
  String get languageSelectionCurrentLabel => '現在の言語';

  @override
  String get languageSelectionContinue => '開始する';

  @override
  String get languageSelectionDone => '完了';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsLanguageLabel => '言語';

  @override
  String settingsLanguageDescription(String native, String english) {
    return '現在は $native ($english) に設定されています';
  }

  @override
  String get splashTagline => '数学のステップバイステップ解説';

  @override
  String get splashTapToStart => 'タップして開始';

  @override
  String get navigationHome => '入力';

  @override
  String get navigationHistory => '履歴';

  @override
  String get navigationSettings => '設定';

  @override
  String get solutionStepExpressionLabel => '数式:';

  @override
  String get solutionStepDescriptionLabel => '詳細説明:';
}
