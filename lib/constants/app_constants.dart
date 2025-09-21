/// アプリケーション全体で使用される定数
class AppConstants {
  // ストレージキー
  static const String solutionsKey = 'solutions';
  static const String expressionsKey = 'expressions';
  
  // エラーメッセージ
  static const String apiKeyNotConfiguredError = 
      'OpenAI APIキーが設定されていません。.envファイルにOPENAI_API_KEYを設定してください。';
  static const String apiRequestFailedError = 'API request failed with status';
  static const String emptyResponseError = 'Empty response from API';
  static const String jsonParseError = 'APIからの応答を解析できませんでした。';
  static const String jsonFormatError = 'APIからの応答を解析できませんでした。JSON形式が正しくありません。';
  
  // UI関連
  static const String copySuccessMessage = '数式をクリップボードにコピーしました';
  static const String deleteConfirmTitle = '履歴から削除';
  static const String sortDialogTitle = '並び替え';
  static const String emptyHistoryTitle = '履歴がありません';
  static const String emptyHistoryMessage = '数式を入力して解法を生成すると、\nここに履歴が表示されます';
  
  // ソートオプション
  static const String sortByTimestamp = 'timestamp';
  static const String sortByExpression = 'expression';
  
  // 時間表示
  static const String justNow = 'たった今';
  static const String minutesAgo = '分前';
  static const String hoursAgo = '時間前';
  static const String daysAgo = '日前';
  
  // デフォルト値
  static const String unknownId = 'unknown';
  static const String untitled = 'Untitled';
  static const String noDescription = 'No description';
  
  // 正規表現パターン
  static const String multipleBackslashesPattern = r'\\{3,}';
  static const String replacementBackslashes = '\\\\';
  
  // 制限値
  static const int maxSnackBarDurationSeconds = 2;
  static const int maxHistoryItemLines = 2;
  static const double historyItemHeight = 60.0;
  static const double historyItemBorderRadius = 12.0;
  static const double historyItemPadding = 16.0;
  static const double historyItemSpacing = 12.0;
  static const double iconSize = 20.0;
  static const double largeIconSize = 64.0;
  
  // AdMob設定
  static const String testRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917'; // テスト用（リワード広告）
  static const String productionRewardedAdUnitId = 'ca-app-pub-1998641949557439~5856126902'; // 本番用（コメントアウト中）
  
  // 広告関連メッセージ
  static const String adLoadingMessage = '広告を読み込み中...';
  static const String adLoadFailedMessage = '広告の読み込みに失敗しました';
  static const String adRewardMessage = '解法を表示します！';
  static const String adNotReadyMessage = '広告の準備ができていません';
}
