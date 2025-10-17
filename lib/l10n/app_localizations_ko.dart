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

  @override
  String get guideAppBarTitle => '키 사용법';

  @override
  String get guideCategoryExponentsTitle => '지수와 근';

  @override
  String get guideCategoryFractionsTitle => '분수와 절댓값';

  @override
  String get guideCategoryTrigLogTitle => '삼각함수와 로그';

  @override
  String get guideCategorySeriesIntegralsTitle => '수열·적분·곱셈';

  @override
  String get guideCategoryComplexTitle => '복소수와 조합';

  @override
  String guideExpressionLabel(String expression) {
    return '수식: $expression';
  }

  @override
  String get guideKeySequenceLabel => '입력 순서:';

  @override
  String get guideTipAutoParenthesis =>
      '함수 키(sin, cos, √ 등)를 누르면 자동으로 \"(\"가 입력됩니다.';

  @override
  String get guideTipExponentKeys =>
      'x^y 키는 간단한 지수에, x^() 키는 식 전체를 지수로 입력할 때 사용하세요.';

  @override
  String get guideTipArrowKeys => '← → 키로 커서를 이동할 수 있습니다.';

  @override
  String get guideTipDeleteKey => 'DEL 키로 커서 왼쪽 문자를 삭제합니다.';

  @override
  String get guideTipSigmaPi => 'Σ, Π, ∫ 키는 쉼표로 하한, 상한, 식을 구분해 입력합니다.';

  @override
  String get guideTipIntegralNotation =>
      '∫ 키를 누르면 \"integral(하한,상한,피적분함수,변수)\" 형식으로 입력할 수 있습니다.';

  @override
  String get guideTipFractionKey => 'a/b 키로 분수를 입력하고 쉼표로 분자와 분모를 나눕니다.';

  @override
  String get guideTipCloseParenthesis => '필요할 때 ) 키로 괄호를 닫아 주세요.';

  @override
  String homeSampleLoaded(String expression) {
    return '샘플 수식을 불러왔습니다: $expression';
  }

  @override
  String get homeClipboardPasteSuccess => '클립보드에서 수식을 붙여넣었습니다.';

  @override
  String get homeClipboardEmpty => '클립보드가 비어 있습니다.';

  @override
  String get homeClipboardPasteFailed => '붙여넣기에 실패했습니다.';

  @override
  String get homeSampleTooltip => '샘플 수식 불러오기';

  @override
  String get homePasteTooltip => '클립보드에서 붙여넣기';

  @override
  String get historyDeleteDialogTitle => '기록에서 삭제';

  @override
  String get historyCopyAndPasteMessage => '수식을 복사하여 입력란에 붙여넣었습니다.';

  @override
  String get historyCopyAndPasteTooltip => '복사 후 입력란에 붙여넣기';

  @override
  String get settingsOtherSettingsTitle => '기타 설정';

  @override
  String get settingsOtherSettingsComingSoon => '준비 중';

  @override
  String get settingsOtherSettingsDescription => '추가 설정은 향후 업데이트에서 제공될 예정입니다.';

  @override
  String settingsLanguageChanged(String language) {
    return '언어가 $language(으)로 변경되었습니다.';
  }

  @override
  String get settingsLegalDocumentsTitle => '법적 문서';

  @override
  String get settingsLegalDocumentsDescription => '개인정보처리방침과 이용약관을 확인해 주세요.';

  @override
  String get privacyPolicyTitle => '개인정보처리방침';

  @override
  String get termsOfServiceTitle => '최종 사용자 라이선스 계약';

  @override
  String get solutionAppBarTitle => '해설';

  @override
  String get solutionProblemLabel => '문제:';

  @override
  String get solutionTabMain => '해법';

  @override
  String get solutionTabAlternative => '유사 문제';

  @override
  String get solutionSimilarProblemsSectionTitle => '유사 문제';

  @override
  String get solutionSimilarProblemTitle => '유사 문제';

  @override
  String get solutionSimilarProblemDescription => '유사한 이유';

  @override
  String get solutionSimilarProblemExpression => '문제식';

  @override
  String get solutionSimilarProblemSolutionSteps => '해법';

  @override
  String get solutionSimilarProblemEmptyMessage => '아직 유사 문제가 없습니다.';

  @override
  String get solutionTabGraph => '그래프';

  @override
  String get solutionAlternativeSectionTitle => '대안 해법';

  @override
  String get solutionVerificationSectionTitle => '검산 및 정의역 확인';

  @override
  String get solutionStepsEmptyMessage => 'API에서 반환된 단계가 없습니다.';

  @override
  String get solutionAlternativeEmptyMessage => '추가 자료가 아직 없습니다.';

  @override
  String get solutionShareNotAvailable => '공유 기능은 추후 업데이트에서 제공될 예정입니다.';

  @override
  String get solutionSaveSuccess => '기록에 저장했습니다.';

  @override
  String solutionStepBadgeLabel(int stepNumber, String stepTitle) {
    return '단계 $stepNumber: $stepTitle';
  }

  @override
  String get solutionNextStepLabel => '다음 단계';

  @override
  String get solutionGraphSectionTitle => '함수 그래프';

  @override
  String solutionGraphFunctionLabel(String expression) {
    return 'f(x) = $expression';
  }

  @override
  String get solutionGraphNotSupported => '이 식은 그래프 표시를 지원하지 않습니다.';

  @override
  String solutionGraphErrorMessage(String error) {
    return '그래프를 생성하는 동안 오류가 발생했습니다: $error';
  }

  @override
  String get solutionGraphNoDataMessage => '그래프 데이터가 없습니다';

  @override
  String get verificationDomainCheckTitle => '정의역 확인';

  @override
  String get verificationVerificationTitle => '검산';

  @override
  String get verificationCommonPitfallsTitle => '자주 하는 실수';

  @override
  String get tutorialWelcomeTitle => '튜토리얼에 오신 것을 환영합니다';

  @override
  String get tutorialWelcomeDescription =>
      'MathStep 사용법을 단계별로 배워봅시다. 각 단계에서 실제로 키를 눌러 기능을 익힐 수 있습니다.';

  @override
  String get tutorialBasicFunctionTitle => '기본 함수 입력';

  @override
  String get tutorialBasicFunctionDescription =>
      '기본적인 함수부터 시작해보겠습니다. f(x)=x²+1과 같은 간단한 식을 입력해보겠습니다.';

  @override
  String get tutorialBasicOperationsTitle => '기본 사칙연산';

  @override
  String get tutorialBasicOperationsDescription =>
      '+, -, ×, ÷ 키를 사용하여 계산식을 입력하는 방법을 먼저 살펴봅니다.';

  @override
  String get tutorialExponentsTitle => '지수와 거듭제곱 입력';

  @override
  String get tutorialExponentsDescription =>
      'x^y 키를 사용해 지수를 입력하세요. x^2 또는 2^(x+1)과 같은 식을 만들 수 있습니다.';

  @override
  String get tutorialSquareRootTitle => '제곱근 입력';

  @override
  String get tutorialSquareRootDescription =>
      '√ 키로 제곱근을 입력하세요. √(9)처럼 입력할 수 있습니다.';

  @override
  String get tutorialFractionsTitle => '분수 입력';

  @override
  String get tutorialFractionsDescription =>
      'a/b 키를 사용하여 분수를 입력하세요. 분자와 분모를 쉼표로 구분합니다.';

  @override
  String get tutorialSummationTitle => '시그마(Σ) 입력';

  @override
  String get tutorialSummationDescription =>
      'Σ 키를 사용해 총합을 입력하세요. Σ(i=1,5,i²)과 같은 간단한 식부터 시작합니다.';

  @override
  String get tutorialIntegralTitle => '적분 기호 입력';

  @override
  String get tutorialIntegralDescription =>
      '∫ 키를 사용해 적분을 입력하세요. 하한, 상한, 피적분함수, 변수 순으로 입력합니다.';

  @override
  String get tutorialTrigonometricTitle => '삼각함수 입력';

  @override
  String get tutorialTrigonometricDescription =>
      'sin, cos, tan 키로 삼각함수를 입력하세요.';

  @override
  String get tutorialCompletionTitle => '튜토리얼 완료';

  @override
  String get tutorialCompletionDescription =>
      '축하합니다! 튜토리얼이 완료되었습니다. 이제 MathStep의 기본 사용법을 익혔습니다.';

  @override
  String get tutorialHelpGuidanceTitle => 'HELP 버튼으로 자세한 내용 확인';

  @override
  String get tutorialHelpGuidanceDescription =>
      '튜토리얼 완료 수고하셨습니다! 기본적인 조작을 마스터했습니다. 우측 상단의 HELP 버튼을 눌러 더 자세한 기호 입력 방법과 고급 기능에 대해 확인할 수 있습니다.';

  @override
  String tutorialStepIndicator(int current, int total) {
    return '단계 $current / $total';
  }

  @override
  String get tutorialKeySequenceLabel => '키 순서:';

  @override
  String get tutorialSkipButton => '건너뛰기';

  @override
  String get tutorialPreviousButton => '이전';

  @override
  String get tutorialNextButton => '다음';

  @override
  String get tutorialCompleteButton => '완료';
}
