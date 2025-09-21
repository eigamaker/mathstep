// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'MathStep';

  @override
  String get commonErrorTitle => '错误';

  @override
  String get commonOkButton => '确定';

  @override
  String get commonCancelButton => '取消';

  @override
  String get commonDeleteButton => '删除';

  @override
  String get commonCloseButton => '关闭';

  @override
  String get commonClear => '清除';

  @override
  String get homeGenerating => '生成中...';

  @override
  String get homeInputRequired => '请输入一个表达式。';

  @override
  String get homeApiKeyMissingSnack => '未配置 OpenAI API 密钥。';

  @override
  String get homeApiKeyMissingDialogTitle => '需要 API 密钥';

  @override
  String get homeApiKeyMissingDialogMessage =>
      '未配置 OpenAI API 密钥。\n\n设置方法：\n1. 在项目根目录创建 .env 文件\n2. 添加：OPENAI_API_KEY=your_api_key_here\n3. 重新启动应用\n\nAPI 密钥可在 OpenAI 官网获取。';

  @override
  String get homeSendingToChatGpt => '正在发送到 ChatGPT...';

  @override
  String get homeApiConnectionErrorTitle => 'API 连接错误';

  @override
  String get homeApiConnectionErrorMessage =>
      '无法连接到 ChatGPT API。\n\n请检查：\n• 网络连接是否正常\n• 是否正确设置了 API 密钥\n• 是否未达到 OpenAI API 的使用限制';

  @override
  String get homeApiResponseErrorTitle => 'API 响应错误';

  @override
  String get homeApiResponseErrorMessage =>
      'ChatGPT API 返回了空响应。\n\n请检查 API 密钥和网络连接。';

  @override
  String get homeGenericErrorSnack => '发生错误。';

  @override
  String get homePlaceholderTitle => '请输入表达式开始使用';

  @override
  String get homePlaceholderSubtitle => '使用键盘或公式编辑器输入表达式。';

  @override
  String get homeExpressionFieldLabel => '输入表达式';

  @override
  String get homeExpressionHint => '示例：(2x+1)/(x-3) = cbrt(x+2)';

  @override
  String get homeConditionFieldLabel => '条件/目标（可选）';

  @override
  String get homeConditionHint => '示例：求 x > 0 时的最小值，求实数解的个数';

  @override
  String get adLoadingMessage => '正在加载广告...';

  @override
  String get adLoadFailedMessage => '广告加载失败。';

  @override
  String get adRewardMessage => '正在显示解法！';

  @override
  String get adNotReadyMessage => '广告尚未准备好。';

  @override
  String get rewardAdShowingMessage => '广告播放中...';

  @override
  String get rewardAdButtonReady => '显示解法';

  @override
  String get historyTitle => '历史记录';

  @override
  String get historySortTooltip => '排序历史';

  @override
  String get historySearchHint => '搜索表达式...';

  @override
  String historyErrorMessage(String error) {
    return '错误：$error';
  }

  @override
  String historyDeleteConfirmation(String expression) {
    return '要从历史记录中删除 $expression 吗？';
  }

  @override
  String get historySortDialogTitle => '排序';

  @override
  String get historySortOptionNewest => '按最新优先';

  @override
  String get historySortOptionExpression => '按表达式排序';

  @override
  String get historySortOrderAscending => '升序';

  @override
  String get historyCopyTooltip => '复制表达式';

  @override
  String get historyViewTooltip => '查看解法';

  @override
  String get historyCopySuccessMessage => '表达式已复制到剪贴板。';

  @override
  String get historyEmptyTitle => '暂无历史记录';

  @override
  String get historyEmptyMessage => '输入表达式并生成解法后，将在此显示。';

  @override
  String relativeTimeDaysAgo(int count) {
    return '$count天前';
  }

  @override
  String relativeTimeHoursAgo(int count) {
    return '$count小时前';
  }

  @override
  String relativeTimeMinutesAgo(int count) {
    return '$count分钟前';
  }

  @override
  String get relativeTimeJustNow => '刚刚';

  @override
  String get guideHintTitle => '💡 小提示';

  @override
  String get formulaEditorTitle => '公式编辑器（支持数学III）';

  @override
  String get formulaEditorApplyTooltip => '应用';

  @override
  String get formulaEditorFieldLabel => '以计算器语法编辑（可换行）';

  @override
  String get languageSelectionTitle => '语言';

  @override
  String get languageSelectionHeading => '选择要使用的语言';

  @override
  String get languageSelectionDescription => '请选择应用中使用的语言。';

  @override
  String get languageSelectionCurrentLabel => '当前语言';

  @override
  String get languageSelectionContinue => '开始使用';

  @override
  String get languageSelectionDone => '完成';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsLanguageLabel => '语言';

  @override
  String settingsLanguageDescription(String native, String english) {
    return '当前语言：$native（$english）';
  }

  @override
  String get splashTagline => '一步一步理解数学解法';

  @override
  String get splashTapToStart => '点击开始';

  @override
  String get navigationHome => '输入';

  @override
  String get navigationHistory => '历史';

  @override
  String get navigationSettings => '设置';

  @override
  String get solutionStepExpressionLabel => '表达式：';

  @override
  String get solutionStepDescriptionLabel => '详细说明：';
}

/// The translations for Chinese, as used in China (`zh_CN`).
class AppLocalizationsZhCn extends AppLocalizationsZh {
  AppLocalizationsZhCn() : super('zh_CN');

  @override
  String get appTitle => 'MathStep';

  @override
  String get commonErrorTitle => '错误';

  @override
  String get commonOkButton => '确定';

  @override
  String get commonCancelButton => '取消';

  @override
  String get commonDeleteButton => '删除';

  @override
  String get commonCloseButton => '关闭';

  @override
  String get commonClear => '清除';

  @override
  String get homeGenerating => '生成中...';

  @override
  String get homeInputRequired => '请输入一个表达式。';

  @override
  String get homeApiKeyMissingSnack => '未配置 OpenAI API 密钥。';

  @override
  String get homeApiKeyMissingDialogTitle => '需要 API 密钥';

  @override
  String get homeApiKeyMissingDialogMessage =>
      '未配置 OpenAI API 密钥。\n\n设置方法：\n1. 在项目根目录创建 .env 文件\n2. 添加：OPENAI_API_KEY=your_api_key_here\n3. 重新启动应用\n\nAPI 密钥可在 OpenAI 官网获取。';

  @override
  String get homeSendingToChatGpt => '正在发送到 ChatGPT...';

  @override
  String get homeApiConnectionErrorTitle => 'API 连接错误';

  @override
  String get homeApiConnectionErrorMessage =>
      '无法连接到 ChatGPT API。\n\n请检查：\n• 网络连接是否正常\n• 是否正确设置了 API 密钥\n• 是否未达到 OpenAI API 的使用限制';

  @override
  String get homeApiResponseErrorTitle => 'API 响应错误';

  @override
  String get homeApiResponseErrorMessage =>
      'ChatGPT API 返回了空响应。\n\n请检查 API 密钥和网络连接。';

  @override
  String get homeGenericErrorSnack => '发生错误。';

  @override
  String get homePlaceholderTitle => '请输入表达式开始使用';

  @override
  String get homePlaceholderSubtitle => '使用键盘或公式编辑器输入表达式。';

  @override
  String get homeExpressionFieldLabel => '输入表达式';

  @override
  String get homeExpressionHint => '示例：(2x+1)/(x-3) = cbrt(x+2)';

  @override
  String get homeConditionFieldLabel => '条件/目标（可选）';

  @override
  String get homeConditionHint => '示例：求 x > 0 时的最小值，求实数解的个数';

  @override
  String get adLoadingMessage => '正在加载广告...';

  @override
  String get adLoadFailedMessage => '广告加载失败。';

  @override
  String get adRewardMessage => '正在显示解法！';

  @override
  String get adNotReadyMessage => '广告尚未准备好。';

  @override
  String get rewardAdShowingMessage => '广告播放中...';

  @override
  String get rewardAdButtonReady => '显示解法';

  @override
  String get historyTitle => '历史记录';

  @override
  String get historySortTooltip => '排序历史';

  @override
  String get historySearchHint => '搜索表达式...';

  @override
  String historyErrorMessage(String error) {
    return '错误：$error';
  }

  @override
  String historyDeleteConfirmation(String expression) {
    return '要从历史记录中删除 $expression 吗？';
  }

  @override
  String get historySortDialogTitle => '排序';

  @override
  String get historySortOptionNewest => '按最新优先';

  @override
  String get historySortOptionExpression => '按表达式排序';

  @override
  String get historySortOrderAscending => '升序';

  @override
  String get historyCopyTooltip => '复制表达式';

  @override
  String get historyViewTooltip => '查看解法';

  @override
  String get historyCopySuccessMessage => '表达式已复制到剪贴板。';

  @override
  String get historyEmptyTitle => '暂无历史记录';

  @override
  String get historyEmptyMessage => '输入表达式并生成解法后，将在此显示。';

  @override
  String relativeTimeDaysAgo(int count) {
    return '$count天前';
  }

  @override
  String relativeTimeHoursAgo(int count) {
    return '$count小时前';
  }

  @override
  String relativeTimeMinutesAgo(int count) {
    return '$count分钟前';
  }

  @override
  String get relativeTimeJustNow => '刚刚';

  @override
  String get guideHintTitle => '💡 小提示';

  @override
  String get formulaEditorTitle => '公式编辑器（支持数学III）';

  @override
  String get formulaEditorApplyTooltip => '应用';

  @override
  String get formulaEditorFieldLabel => '以计算器语法编辑（可换行）';

  @override
  String get languageSelectionTitle => '语言';

  @override
  String get languageSelectionHeading => '选择要使用的语言';

  @override
  String get languageSelectionDescription => '请选择应用中使用的语言。';

  @override
  String get languageSelectionCurrentLabel => '当前语言';

  @override
  String get languageSelectionContinue => '开始使用';

  @override
  String get languageSelectionDone => '完成';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsLanguageLabel => '语言';

  @override
  String settingsLanguageDescription(String native, String english) {
    return '当前语言：$native（$english）';
  }

  @override
  String get splashTagline => '一步一步理解数学解法';

  @override
  String get splashTapToStart => '点击开始';

  @override
  String get navigationHome => '输入';

  @override
  String get navigationHistory => '历史';

  @override
  String get navigationSettings => '设置';

  @override
  String get solutionStepExpressionLabel => '表达式：';

  @override
  String get solutionStepDescriptionLabel => '详细说明：';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appTitle => 'MathStep';

  @override
  String get commonErrorTitle => '錯誤';

  @override
  String get commonOkButton => '確定';

  @override
  String get commonCancelButton => '取消';

  @override
  String get commonDeleteButton => '刪除';

  @override
  String get commonCloseButton => '關閉';

  @override
  String get commonClear => '清除';

  @override
  String get homeGenerating => '產生中...';

  @override
  String get homeInputRequired => '請輸入數學式。';

  @override
  String get homeApiKeyMissingSnack => '尚未設定 OpenAI API 金鑰。';

  @override
  String get homeApiKeyMissingDialogTitle => '需要 API 金鑰';

  @override
  String get homeApiKeyMissingDialogMessage =>
      '尚未設定 OpenAI API 金鑰。\n\n設定方式：\n1. 在專案根目錄建立 .env 檔案\n2. 加入：OPENAI_API_KEY=your_api_key_here\n3. 重新啟動應用程式\n\nAPI 金鑰可在 OpenAI 官方網站取得。';

  @override
  String get homeSendingToChatGpt => '正在傳送至 ChatGPT...';

  @override
  String get homeApiConnectionErrorTitle => 'API 連線錯誤';

  @override
  String get homeApiConnectionErrorMessage =>
      '無法連線至 ChatGPT API。\n\n請確認：\n• 網路連線是否正常\n• 是否正確設定 API 金鑰\n• 是否未達到 OpenAI API 使用限制';

  @override
  String get homeApiResponseErrorTitle => 'API 回應錯誤';

  @override
  String get homeApiResponseErrorMessage =>
      'ChatGPT API 傳回空白回應。\n\n請檢查 API 金鑰與網路連線。';

  @override
  String get homeGenericErrorSnack => '發生錯誤。';

  @override
  String get homePlaceholderTitle => '輸入數學式開始使用';

  @override
  String get homePlaceholderSubtitle => '使用鍵盤或公式編輯器輸入數學式。';

  @override
  String get homeExpressionFieldLabel => '輸入數學式';

  @override
  String get homeExpressionHint => '範例：(2x+1)/(x-3) = cbrt(x+2)';

  @override
  String get homeConditionFieldLabel => '條件／目標（選填）';

  @override
  String get homeConditionHint => '範例：求 x > 0 時的最小值、求實數解的個數';

  @override
  String get adLoadingMessage => '正在載入廣告...';

  @override
  String get adLoadFailedMessage => '廣告載入失敗。';

  @override
  String get adRewardMessage => '將顯示解法！';

  @override
  String get adNotReadyMessage => '廣告尚未準備好。';

  @override
  String get rewardAdShowingMessage => '廣告播放中...';

  @override
  String get rewardAdButtonReady => '顯示解法';

  @override
  String get historyTitle => '歷程';

  @override
  String get historySortTooltip => '排序歷程';

  @override
  String get historySearchHint => '搜尋數學式...';

  @override
  String historyErrorMessage(String error) {
    return '錯誤：$error';
  }

  @override
  String historyDeleteConfirmation(String expression) {
    return '要從歷程中刪除 $expression 嗎？';
  }

  @override
  String get historySortDialogTitle => '排序';

  @override
  String get historySortOptionNewest => '最新優先';

  @override
  String get historySortOptionExpression => '依數學式排序';

  @override
  String get historySortOrderAscending => '遞增';

  @override
  String get historyCopyTooltip => '複製數學式';

  @override
  String get historyViewTooltip => '查看解法';

  @override
  String get historyCopySuccessMessage => '已將數學式複製到剪貼簿。';

  @override
  String get historyEmptyTitle => '尚無歷程';

  @override
  String get historyEmptyMessage => '輸入數學式並產生解法後，就會顯示在這裡。';

  @override
  String relativeTimeDaysAgo(int count) {
    return '$count 天前';
  }

  @override
  String relativeTimeHoursAgo(int count) {
    return '$count 小時前';
  }

  @override
  String relativeTimeMinutesAgo(int count) {
    return '$count 分鐘前';
  }

  @override
  String get relativeTimeJustNow => '剛剛';

  @override
  String get guideHintTitle => '💡 小提示';

  @override
  String get formulaEditorTitle => '公式編輯器（支援數學III）';

  @override
  String get formulaEditorApplyTooltip => '套用';

  @override
  String get formulaEditorFieldLabel => '以計算器語法編輯（可換行）';

  @override
  String get languageSelectionTitle => '語言';

  @override
  String get languageSelectionHeading => '選擇使用的語言';

  @override
  String get languageSelectionDescription => '請選擇要在應用程式中使用的語言。';

  @override
  String get languageSelectionCurrentLabel => '目前的語言';

  @override
  String get languageSelectionContinue => '開始使用';

  @override
  String get languageSelectionDone => '完成';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsLanguageLabel => '語言';

  @override
  String settingsLanguageDescription(String native, String english) {
    return '目前語言：$native（$english）';
  }

  @override
  String get splashTagline => '一步一步理解數學解法';

  @override
  String get splashTapToStart => '點選開始';

  @override
  String get navigationHome => '輸入';

  @override
  String get navigationHistory => '歷程';

  @override
  String get navigationSettings => '設定';

  @override
  String get solutionStepExpressionLabel => '數學式：';

  @override
  String get solutionStepDescriptionLabel => '詳細說明：';
}
