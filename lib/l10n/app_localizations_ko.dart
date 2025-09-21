// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'MathStep';

  @override
  String get commonErrorTitle => '오류';

  @override
  String get commonOkButton => '확인';

  @override
  String get commonCancelButton => '취소';

  @override
  String get commonDeleteButton => '삭제';

  @override
  String get commonCloseButton => '닫기';

  @override
  String get commonClear => '지우기';

  @override
  String get homeGenerating => '생성 중...';

  @override
  String get homeInputRequired => '식을 입력하세요.';

  @override
  String get homeApiKeyMissingSnack => 'OpenAI API 키가 설정되지 않았습니다.';

  @override
  String get homeApiKeyMissingDialogTitle => 'API 키가 필요합니다';

  @override
  String get homeApiKeyMissingDialogMessage =>
      'OpenAI API 키가 설정되지 않았습니다.\n\n설정 방법:\n1. 프로젝트 루트에 .env 파일을 생성합니다.\n2. OPENAI_API_KEY=your_api_key_here 를 추가합니다.\n3. 앱을 다시 시작합니다.\n\nAPI 키는 OpenAI 공식 웹사이트에서 발급받을 수 있습니다.';

  @override
  String get homeSendingToChatGpt => 'ChatGPT로 전송 중...';

  @override
  String get homeApiConnectionErrorTitle => 'API 연결 오류';

  @override
  String get homeApiConnectionErrorMessage =>
      'ChatGPT API에 연결하지 못했습니다.\n\n다음을 확인하세요:\n• 인터넷 연결 상태\n• API 키가 올바르게 설정되었는지\n• OpenAI API 사용 한도에 도달하지 않았는지';

  @override
  String get homeApiResponseErrorTitle => 'API 응답 오류';

  @override
  String get homeApiResponseErrorMessage =>
      'ChatGPT API에서 빈 응답이 반환되었습니다.\n\nAPI 키와 네트워크 연결을 확인하세요.';

  @override
  String get homeGenericErrorSnack => '오류가 발생했습니다.';

  @override
  String get homePlaceholderTitle => '식을 입력하고 시작하세요';

  @override
  String get homePlaceholderSubtitle => '키패드 또는 식 편집기를 사용해 수식을 입력하세요.';

  @override
  String get homeExpressionFieldLabel => '식 입력';

  @override
  String get homeExpressionHint => '예: (2x+1)/(x-3) = cbrt(x+2)';

  @override
  String get homeConditionFieldLabel => '조건·목표 (선택)';

  @override
  String get homeConditionHint => '예: x > 0일 때의 최솟값을 구하시오, 실수 해의 개수를 구하시오';

  @override
  String get adLoadingMessage => '광고를 불러오는 중...';

  @override
  String get adLoadFailedMessage => '광고를 불러오지 못했습니다.';

  @override
  String get adRewardMessage => '해설을 표시합니다!';

  @override
  String get adNotReadyMessage => '광고가 아직 준비되지 않았습니다.';

  @override
  String get rewardAdShowingMessage => '광고 표시 중...';

  @override
  String get rewardAdButtonReady => '해설 보기';

  @override
  String get historyTitle => '기록';

  @override
  String get historySortTooltip => '기록 정렬';

  @override
  String get historySearchHint => '식을 검색...';

  @override
  String historyErrorMessage(String error) {
    return '오류: $error';
  }

  @override
  String historyDeleteConfirmation(String expression) {
    return '$expression 항목을 기록에서 삭제하시겠습니까?';
  }

  @override
  String get historySortDialogTitle => '정렬';

  @override
  String get historySortOptionNewest => '최신 순';

  @override
  String get historySortOptionExpression => '수식 순';

  @override
  String get historySortOrderAscending => '오름차순';

  @override
  String get historyCopyTooltip => '수식 복사';

  @override
  String get historyViewTooltip => '해설 보기';

  @override
  String get historyCopySuccessMessage => '수식을 클립보드에 복사했습니다.';

  @override
  String get historyEmptyTitle => '기록이 없습니다';

  @override
  String get historyEmptyMessage => '식을 입력하고 해설을 생성하면 이곳에 표시됩니다.';

  @override
  String relativeTimeDaysAgo(int count) {
    return '$count일 전';
  }

  @override
  String relativeTimeHoursAgo(int count) {
    return '$count시간 전';
  }

  @override
  String relativeTimeMinutesAgo(int count) {
    return '$count분 전';
  }

  @override
  String get relativeTimeJustNow => '방금 전';

  @override
  String get guideHintTitle => '💡 팁';

  @override
  String get formulaEditorTitle => '식 편집기(수학 III 지원)';

  @override
  String get formulaEditorApplyTooltip => '반영';

  @override
  String get formulaEditorFieldLabel => '계산기 표기법으로 편집 (줄바꿈 가능)';

  @override
  String get languageSelectionTitle => '언어';

  @override
  String get languageSelectionHeading => '사용할 언어를 선택하세요';

  @override
  String get languageSelectionDescription => '앱에서 사용할 언어를 선택하세요.';

  @override
  String get languageSelectionCurrentLabel => '현재 선택된 언어';

  @override
  String get languageSelectionContinue => '시작하기';

  @override
  String get languageSelectionDone => '완료';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsLanguageLabel => '언어';

  @override
  String settingsLanguageDescription(String native, String english) {
    return '현재 언어: $native ($english)';
  }

  @override
  String get splashTagline => '수학을 단계별로 이해하기';

  @override
  String get splashTapToStart => '탭하여 시작';

  @override
  String get navigationHome => '입력';

  @override
  String get navigationHistory => '기록';

  @override
  String get navigationSettings => '설정';

  @override
  String get solutionStepExpressionLabel => '수식:';

  @override
  String get solutionStepDescriptionLabel => '자세한 설명:';
}
