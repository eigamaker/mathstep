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

  @override
  String get guideAppBarTitle => 'キーの使い方';

  @override
  String get guideCategoryExponentsTitle => '指数・根号';

  @override
  String get guideCategoryFractionsTitle => '分数・絶対値';

  @override
  String get guideCategoryTrigLogTitle => '三角・対数関数';

  @override
  String get guideCategorySeriesIntegralsTitle => '総和・積分・積';

  @override
  String get guideCategoryComplexTitle => '複素数・組み合わせ';

  @override
  String guideExpressionLabel(String expression) {
    return '数式: $expression';
  }

  @override
  String get guideKeySequenceLabel => 'キーの順番:';

  @override
  String get guideTipAutoParenthesis =>
      '関数キー（sin, cos, √ など）を押すと自動的に「(」が入力されます。';

  @override
  String get guideTipExponentKeys => 'x^yキーで単純な指数を、x^()キーで式の指数を入力できます。';

  @override
  String get guideTipArrowKeys => '矢印キー（← →）でカーソルを移動できます。';

  @override
  String get guideTipDeleteKey => 'DELキーでカーソルの左側を削除できます。';

  @override
  String get guideTipSigmaPi => 'Σ, Π, ∫ キーはカンマ区切りで下限・上限・式を入力します。';

  @override
  String get guideTipIntegralNotation =>
      '∫ キーを押すと「integral(下限,上限,被積分関数,変数)」の形式で入力できます。';

  @override
  String get guideTipFractionKey => 'a/bキーで分数を入力し、カンマで分子と分母を区切ります。';

  @override
  String get guideTipCloseParenthesis => '必要に応じて ) キーで括弧を閉じてください。';

  @override
  String homeSampleLoaded(String expression) {
    return 'サンプル数式を読み込みました: $expression';
  }

  @override
  String get homeClipboardPasteSuccess => 'クリップボードから数式を貼り付けました。';

  @override
  String get homeClipboardEmpty => 'クリップボードが空です。';

  @override
  String get homeClipboardPasteFailed => '貼り付けに失敗しました。';

  @override
  String get homeSampleTooltip => 'サンプル数式を読み込み';

  @override
  String get homePasteTooltip => 'クリップボードから貼り付け';

  @override
  String get historyDeleteDialogTitle => '履歴から削除';

  @override
  String get historyCopyAndPasteMessage => '数式をコピーして入力欄に貼り付けました。';

  @override
  String get historyCopyAndPasteTooltip => 'コピーして入力欄に貼り付け';

  @override
  String get settingsOtherSettingsTitle => 'その他の設定';

  @override
  String get settingsOtherSettingsComingSoon => '準備中です';

  @override
  String get settingsOtherSettingsDescription => '今後、より多くの設定項目を追加予定です。';

  @override
  String settingsLanguageChanged(String language) {
    return '言語を$languageに変更しました。';
  }

  @override
  String get settingsLegalDocumentsTitle => '法的文書';

  @override
  String get settingsLegalDocumentsDescription => 'プライバシーポリシーと利用規約をご確認ください。';

  @override
  String get privacyPolicyTitle => 'プライバシーポリシー';

  @override
  String get termsOfServiceTitle => 'エンドユーザーライセンス契約';

  @override
  String get solutionAppBarTitle => '解説';

  @override
  String get solutionProblemLabel => '問題:';

  @override
  String get solutionTabMain => '解法';

  @override
  String get solutionTabAlternative => '類似問題';

  @override
  String get solutionSimilarProblemsSectionTitle => '類似問題';

  @override
  String get solutionSimilarProblemTitle => '類似問題';

  @override
  String get solutionSimilarProblemDescription => 'なぜ類似しているか';

  @override
  String get solutionSimilarProblemExpression => '問題式';

  @override
  String get solutionSimilarProblemSolutionSteps => '解法';

  @override
  String get solutionSimilarProblemEmptyMessage => '類似問題はまだありません。';

  @override
  String get solutionTabGraph => 'グラフ';

  @override
  String get solutionAlternativeSectionTitle => '別の解法';

  @override
  String get solutionVerificationSectionTitle => '検証と定義域の確認';

  @override
  String get solutionStepsEmptyMessage => 'APIから解法の手順は返されませんでした。';

  @override
  String get solutionAlternativeEmptyMessage => '追加の解法はまだありません。';

  @override
  String get solutionShareNotAvailable => '共有機能は今後のアップデートで対応予定です。';

  @override
  String get solutionSaveSuccess => '履歴に保存しました。';

  @override
  String solutionStepBadgeLabel(int stepNumber, String stepTitle) {
    return 'ステップ$stepNumber: $stepTitle';
  }

  @override
  String get solutionNextStepLabel => '次のステップ';

  @override
  String get solutionGraphSectionTitle => '関数のグラフ';

  @override
  String solutionGraphFunctionLabel(String expression) {
    return 'f(x) = $expression';
  }

  @override
  String get solutionGraphNotSupported => 'この数式はグラフ表示に対応していません。';

  @override
  String solutionGraphErrorMessage(String error) {
    return 'グラフの生成中にエラーが発生しました: $error';
  }

  @override
  String get solutionGraphNoDataMessage => 'グラフデータがありません';

  @override
  String get verificationDomainCheckTitle => '定義域チェック';

  @override
  String get verificationVerificationTitle => '検算';

  @override
  String get verificationCommonPitfallsTitle => 'よくある間違い';

  @override
  String get tutorialWelcomeTitle => 'チュートリアルへようこそ';

  @override
  String get tutorialWelcomeDescription =>
      'MathStepの使い方を順番に学んでいきましょう。各ステップで実際のキーを押して操作を覚えることができます。';

  @override
  String get tutorialBasicOperationsTitle => '基本的な四則演算';

  @override
  String get tutorialBasicOperationsDescription =>
      'まずは基本的な四則演算から始めましょう。+、-、×、÷のキーを使って計算式を入力できます。';

  @override
  String get tutorialExponentsTitle => '指数・累乗の入力';

  @override
  String get tutorialExponentsDescription =>
      'x^yキーを使って指数を入力しましょう。x^2や2^（x+1）のような式が作れます。';

  @override
  String get tutorialSquareRootTitle => '平方根の入力';

  @override
  String get tutorialSquareRootDescription =>
      '√キーを使って平方根を入力しましょう。√(9)のように入力できます。';

  @override
  String get tutorialFractionsTitle => '分数の入力';

  @override
  String get tutorialFractionsDescription =>
      'a/bキーを使って分数を入力しましょう。分子と分母をカンマで区切って入力します。';

  @override
  String get tutorialSummationTitle => '総和記号の入力';

  @override
  String get tutorialSummationDescription =>
      'Σキーを使って総和を入力しましょう。変数、下限、上限、式の順で入力します。';

  @override
  String get tutorialIntegralTitle => '積分記号の入力';

  @override
  String get tutorialIntegralDescription =>
      '∫キーを使って積分を入力しましょう。下限、上限、被積分関数、変数の順で入力します。';

  @override
  String get tutorialTrigonometricTitle => '三角関数の入力';

  @override
  String get tutorialTrigonometricDescription =>
      'sin、cos、tanキーを使って三角関数を入力しましょう。';

  @override
  String get tutorialCompletionTitle => 'チュートリアル完了';

  @override
  String get tutorialCompletionDescription =>
      'おめでとうございます！チュートリアルが完了しました。これでMathStepの基本的な使い方をマスターできました。';

  @override
  String tutorialStepIndicator(int current, int total) {
    return 'ステップ $current / $total';
  }

  @override
  String get tutorialKeySequenceLabel => 'キーの順番:';

  @override
  String get tutorialSkipButton => 'スキップ';

  @override
  String get tutorialPreviousButton => '前へ';

  @override
  String get tutorialNextButton => '次へ';

  @override
  String get tutorialCompleteButton => '完了';
}
