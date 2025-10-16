import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localization/localization_extensions.dart';

const String tutorialActionShowSolutionId = 'show_solution';

enum TutorialStepMode { info, practice }

class TutorialKeyHint {
  const TutorialKeyHint({required this.label, required this.value});

  final String label;
  final String value;
}

class TutorialFollowUpAction {
  const TutorialFollowUpAction({
    required this.id,
    required this.title,
    required this.description,
  });

  final String id;
  final String title;
  final String description;
}

class TutorialStep {
  const TutorialStep({
    required this.id,
    required this.mode,
    required this.title,
    required this.description,
    this.targetKey = '',
    this.keySequence = const <TutorialKeyHint>[],
    this.exampleExpression = '',
    this.targetPosition,
    this.highlightRadius = 60.0,
    this.expectedInput,
    this.autoAdvanceOnComplete = false,
    this.clearInputOnEnter = false,
    this.clearInputOnComplete = false,
    this.followUpAction,
  });

  final String id;
  final TutorialStepMode mode;
  final String title;
  final String description;
  final String targetKey;
  final List<TutorialKeyHint> keySequence;
  final String exampleExpression;
  final Offset? targetPosition;
  final double highlightRadius;
  final String? expectedInput;
  final bool autoAdvanceOnComplete;
  final bool clearInputOnEnter;
  final bool clearInputOnComplete;
  final TutorialFollowUpAction? followUpAction;
}

class TutorialState {
  const TutorialState({
    this.isActive = false,
    this.currentStepIndex = 0,
    this.isCompleted = false,
    this.isSkipped = false,
    this.isDisabled = false,
    this.practiceCompleted = false,
    this.awaitingActionId,
    this.inputClearRequest = 0,
    this.practiceKeyProgress = 0,
  });

  final bool isActive;
  final int currentStepIndex;
  final bool isCompleted;
  final bool isSkipped;
  final bool isDisabled;
  final bool practiceCompleted;
  final String? awaitingActionId;
  final int inputClearRequest;
  final int practiceKeyProgress;

  TutorialState copyWith({
    bool? isActive,
    int? currentStepIndex,
    bool? isCompleted,
    bool? isSkipped,
    bool? isDisabled,
    bool? practiceCompleted,
    Object? awaitingActionId = _sentinel,
    int? inputClearRequest,
    int? practiceKeyProgress,
  }) {
    final String? resolvedActionId = identical(awaitingActionId, _sentinel)
        ? this.awaitingActionId
        : awaitingActionId as String?;

    return TutorialState(
      isActive: isActive ?? this.isActive,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      isCompleted: isCompleted ?? this.isCompleted,
      isSkipped: isSkipped ?? this.isSkipped,
      isDisabled: isDisabled ?? this.isDisabled,
      practiceCompleted: practiceCompleted ?? this.practiceCompleted,
      awaitingActionId: resolvedActionId,
      inputClearRequest: inputClearRequest ?? this.inputClearRequest,
      practiceKeyProgress: practiceKeyProgress ?? this.practiceKeyProgress,
    );
  }

  static const _sentinel = Object();
}

class TutorialNotifier extends StateNotifier<TutorialState> {
  TutorialNotifier() : super(const TutorialState()) {
    _loadTutorialSettingsSync();
  }

  bool _isInitialized = false;
  Timer? _pendingAutoAdvanceTimer;

  static const String _tutorialDisabledKey = 'tutorial_disabled';
  static const String _tutorialCompletedKey = 'tutorial_completed';

  static List<TutorialStep> _tutorialSteps = <TutorialStep>[];

  bool get isInitialized => _isInitialized;

  void _loadTutorialSettingsSync() {
    state = state.copyWith(
      isDisabled: false,
      isCompleted: false,
      practiceCompleted: false,
      awaitingActionId: null,
      practiceKeyProgress: 0,
    );
    _isInitialized = true;
  }

  Future<void> loadTutorialSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isDisabled = prefs.getBool(_tutorialDisabledKey) ?? false;
    final isCompleted = prefs.getBool(_tutorialCompletedKey) ?? false;

    state = state.copyWith(
      isDisabled: isDisabled,
      isCompleted: isCompleted,
      practiceCompleted: false,
      awaitingActionId: null,
      practiceKeyProgress: 0,
    );
  }

  Future<void> _saveTutorialSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialDisabledKey, state.isDisabled);
    await prefs.setBool(_tutorialCompletedKey, state.isCompleted);
  }

  void initializeSteps(BuildContext context) {
    if (_tutorialSteps.isNotEmpty) return;

    final l10n = context.l10n;
    final localeName = l10n.localeName;

    _tutorialSteps = <TutorialStep>[
      TutorialStep(
        id: 'welcome',
        mode: TutorialStepMode.info,
        title: l10n.tutorialWelcomeTitle,
        description: l10n.tutorialWelcomeDescription,
      ),
      TutorialStep(
        id: 'summation_overview',
        mode: TutorialStepMode.info,
        title: l10n.tutorialSummationTitle,
        description: l10n.tutorialSummationDescription,
        exampleExpression: '\\sum_{i=1}^{n} \\frac{\\sqrt{i^2+1}}{i}',
      ),
      TutorialStep(
        id: 'summation_practice',
        mode: TutorialStepMode.practice,
        title: _composePracticeTitle(localeName, l10n.tutorialSummationTitle),
        description: l10n.tutorialSummationDescription,
        keySequence: const <TutorialKeyHint>[
          TutorialKeyHint(label: 'Σ', value: 'sum('),
          TutorialKeyHint(label: 'i', value: 'i'),
          TutorialKeyHint(label: '=', value: '='),
          TutorialKeyHint(label: '1', value: '1'),
          TutorialKeyHint(label: ',', value: ','),
          TutorialKeyHint(label: 'n', value: 'n'),
          TutorialKeyHint(label: ',', value: ','),
          TutorialKeyHint(label: '√', value: 'sqrt('),
          TutorialKeyHint(label: 'i', value: 'i'),
          TutorialKeyHint(label: '^', value: '^'),
          TutorialKeyHint(label: '2', value: '2'),
          TutorialKeyHint(label: '+', value: '+'),
          TutorialKeyHint(label: '1', value: '1'),
          TutorialKeyHint(label: ')', value: ')'),
          TutorialKeyHint(label: '/', value: '/'),
          TutorialKeyHint(label: 'i', value: 'i'),
          TutorialKeyHint(label: ')', value: ')'),
        ],
        exampleExpression: '\\sum_{i=1}^{n} \\frac{\\sqrt{i^2+1}}{i}',
        expectedInput: 'sum(i=1,n,sqrt(i^2+1)/i)',
        clearInputOnEnter: true,
        clearInputOnComplete: true,
        autoAdvanceOnComplete: false,
      ),
      TutorialStep(
        id: 'integral_overview',
        mode: TutorialStepMode.info,
        title: l10n.tutorialIntegralTitle,
        description: l10n.tutorialIntegralDescription,
        exampleExpression:
            '\\int_{0}^{\\pi/2} \\frac{\\sin^2(x) \\cdot e^x}{x+1} \\, dx',
      ),
      TutorialStep(
        id: 'integral_practice',
        mode: TutorialStepMode.practice,
        title: _composePracticeTitle(localeName, l10n.tutorialIntegralTitle),
        description: l10n.tutorialIntegralDescription,
        keySequence: const <TutorialKeyHint>[
          TutorialKeyHint(label: '∫', value: 'integral('),
          TutorialKeyHint(label: '0', value: '0'),
          TutorialKeyHint(label: ',', value: ','),
          TutorialKeyHint(label: 'π', value: 'pi'),
          TutorialKeyHint(label: '/', value: '/'),
          TutorialKeyHint(label: '2', value: '2'),
          TutorialKeyHint(label: ',', value: ','),
          TutorialKeyHint(label: 'sin', value: 'sin('),
          TutorialKeyHint(label: 'x', value: 'x'),
          TutorialKeyHint(label: ')', value: ')'),
          TutorialKeyHint(label: '^', value: '^'),
          TutorialKeyHint(label: '2', value: '2'),
          TutorialKeyHint(label: '*', value: '*'),
          TutorialKeyHint(label: 'e', value: 'e'),
          TutorialKeyHint(label: '^', value: '^'),
          TutorialKeyHint(label: 'x', value: 'x'),
          TutorialKeyHint(label: '/', value: '/'),
          TutorialKeyHint(label: '(', value: '('),
          TutorialKeyHint(label: 'x', value: 'x'),
          TutorialKeyHint(label: '+', value: '+'),
          TutorialKeyHint(label: '1', value: '1'),
          TutorialKeyHint(label: ')', value: ')'),
          TutorialKeyHint(label: ',', value: ','),
          TutorialKeyHint(label: 'x', value: 'x'),
          TutorialKeyHint(label: ')', value: ')'),
        ],
        exampleExpression:
            '\\int_{0}^{\\pi/2} \\frac{\\sin^2(x) \\cdot e^x}{x+1} \\, dx',
        expectedInput: 'integral(0,pi/2,sin(x)^2*e^x/(x+1),x)',
        clearInputOnEnter: true,
        autoAdvanceOnComplete: false,
        followUpAction: _createShowSolutionAction(localeName),
      ),
      TutorialStep(
        id: 'completion',
        mode: TutorialStepMode.info,
        title: l10n.tutorialCompletionTitle,
        description: l10n.tutorialCompletionDescription,
      ),
    ];
  }

  void startTutorial(BuildContext context) {
    if (state.isDisabled) return;

    initializeSteps(context);
    _cancelPendingAutoAdvance();

    state = state.copyWith(
      isActive: true,
      isCompleted: false,
      isSkipped: false,
      practiceCompleted: false,
      awaitingActionId: null,
      practiceKeyProgress: 0,
    );

    if (_tutorialSteps.isNotEmpty) {
      _goToStep(0);
    }
  }

  void nextStep() {
    _cancelPendingAutoAdvance();

    if (state.currentStepIndex >= _tutorialSteps.length - 1) {
      completeTutorial();
      return;
    }

    _goToStep(state.currentStepIndex + 1);
  }

  void previousStep() {
    _cancelPendingAutoAdvance();

    if (state.currentStepIndex <= 0) {
      return;
    }

    _goToStep(state.currentStepIndex - 1);
  }

  void skipTutorial() {
    _cancelPendingAutoAdvance();

    state = state.copyWith(
      isActive: false,
      isSkipped: true,
      isCompleted: false,
      practiceCompleted: false,
      awaitingActionId: null,
      practiceKeyProgress: 0,
    );
    _saveTutorialSettings();
  }

  void completeTutorial() {
    _cancelPendingAutoAdvance();

    state = state.copyWith(
      isActive: false,
      isCompleted: true,
      isSkipped: false,
      practiceCompleted: false,
      awaitingActionId: null,
      practiceKeyProgress: 0,
    );
    _saveTutorialSettings();
  }

  void toggleTutorial() {
    state = state.copyWith(isDisabled: !state.isDisabled);
    _saveTutorialSettings();
  }

  void handleExpressionChange(String expression) {
    if (!state.isActive) {
      return;
    }

    final current = currentStep;
    if (current == null) {
      return;
    }

    final normalizedInput = _normalizeExpression(expression);

    if (current.mode != TutorialStepMode.practice) {
      if (!state.practiceCompleted && state.practiceKeyProgress != 0) {
        state = state.copyWith(practiceKeyProgress: 0);
      }
      return;
    }

    final expectedInput = current.expectedInput;
    if (expectedInput == null || expectedInput.isEmpty) {
      if (!state.practiceCompleted && state.practiceKeyProgress != 0) {
        state = state.copyWith(practiceKeyProgress: 0);
      }
      return;
    }

    final normalizedExpected = _normalizeExpression(expectedInput);

    if (normalizedInput.isEmpty) {
      if (!state.practiceCompleted && state.practiceKeyProgress != 0) {
        state = state.copyWith(practiceKeyProgress: 0);
      }
      return;
    }

    if (!normalizedExpected.startsWith(normalizedInput)) {
      return;
    }

    if (!state.practiceCompleted) {
      final int completedKeys = _calculateCompletedKeyCount(
        current,
        normalizedInput,
      ).clamp(0, current.keySequence.length).toInt();
      if (completedKeys != state.practiceKeyProgress) {
        state = state.copyWith(practiceKeyProgress: completedKeys);
      }
    }

    if (state.practiceCompleted || state.awaitingActionId != null) {
      return;
    }

    if (normalizedInput == normalizedExpected) {
      _onPracticeCompleted(current);
    }
  }

  void completeFollowUpAction(String actionId) {
    if (state.awaitingActionId != actionId) {
      return;
    }

    _cancelPendingAutoAdvance();
    state = state.copyWith(awaitingActionId: null, practiceCompleted: false);

    nextStep();
  }

  bool get isAwaitingShowSolutionAction =>
      state.awaitingActionId == tutorialActionShowSolutionId;

  TutorialStep? get currentStep {
    if (state.currentStepIndex < 0 ||
        state.currentStepIndex >= _tutorialSteps.length) {
      return null;
    }
    return _tutorialSteps[state.currentStepIndex];
  }

  List<TutorialStep> get allSteps => _tutorialSteps;

  bool get canStartTutorial =>
      !state.isDisabled && !state.isActive && !state.isCompleted;

  bool get isInProgress =>
      state.isActive && !state.isCompleted && !state.isSkipped;

  void _onPracticeCompleted(TutorialStep step) {
    if (state.practiceCompleted) {
      if (step.followUpAction != null &&
          state.awaitingActionId != step.followUpAction!.id) {
        state = state.copyWith(awaitingActionId: step.followUpAction!.id);
      }
      return;
    }

    _cancelPendingAutoAdvance();
    state = state.copyWith(
      practiceCompleted: true,
      practiceKeyProgress: step.keySequence.length,
    );

    if (step.clearInputOnComplete) {
      state = state.copyWith(inputClearRequest: state.inputClearRequest + 1);
    }

    if (step.followUpAction != null) {
      state = state.copyWith(awaitingActionId: step.followUpAction!.id);
      return;
    }

    if (step.autoAdvanceOnComplete) {
      _scheduleAutoAdvance();
    }
  }

  void _goToStep(int index) {
    if (_tutorialSteps.isEmpty) return;

    final clampedIndex = index.clamp(0, _tutorialSteps.length - 1);
    state = state.copyWith(
      currentStepIndex: clampedIndex,
      practiceCompleted: false,
      awaitingActionId: null,
      practiceKeyProgress: 0,
    );

    final step = _tutorialSteps[clampedIndex];
    if (step.clearInputOnEnter) {
      state = state.copyWith(inputClearRequest: state.inputClearRequest + 1);
    }
  }

  void _scheduleAutoAdvance() {
    _cancelPendingAutoAdvance();
    _pendingAutoAdvanceTimer = Timer(const Duration(milliseconds: 600), () {
      _pendingAutoAdvanceTimer = null;
      if (!state.isActive) {
        return;
      }
      if (state.awaitingActionId != null) {
        return;
      }
      nextStep();
    });
  }

  void _cancelPendingAutoAdvance() {
    _pendingAutoAdvanceTimer?.cancel();
    _pendingAutoAdvanceTimer = null;
  }

  int _calculateCompletedKeyCount(TutorialStep step, String normalizedInput) {
    int completed = 0;
    int consumedLength = 0;

    for (final hint in step.keySequence) {
      final value = _normalizeExpression(hint.value);
      final targetLength = consumedLength + value.length;

      if (normalizedInput.length >= targetLength) {
        completed++;
        consumedLength = targetLength;
      } else {
        break;
      }
    }

    return completed;
  }

  String _normalizeExpression(String value) {
    return value.replaceAll(RegExp(r'\s+'), '');
  }

  @override
  void dispose() {
    _cancelPendingAutoAdvance();
    super.dispose();
  }
}

final tutorialProvider = StateNotifierProvider<TutorialNotifier, TutorialState>(
  (ref) {
    return TutorialNotifier();
  },
);

final currentTutorialStepProvider = Provider<TutorialStep?>((ref) {
  final tutorialState = ref.watch(tutorialProvider);
  final tutorialNotifier = ref.read(tutorialProvider.notifier);

  if (!tutorialState.isActive) {
    return null;
  }

  final steps = tutorialNotifier.allSteps;
  final index = tutorialState.currentStepIndex;

  if (index >= 0 && index < steps.length) {
    return steps[index];
  }

  return null;
});

String _composePracticeTitle(String localeName, String baseTitle) {
  return '$baseTitle - ${_practiceSuffix(localeName)}';
}

String _practiceSuffix(String localeName) {
  switch (localeName) {
    case 'ja':
      return '練習';
    case 'ko':
      return '연습';
    case 'zh_TW':
      return '練習';
    case 'zh_CN':
      return '练习';
    case 'zh':
      return '练习';
    default:
      return 'Practice';
  }
}

TutorialFollowUpAction _createShowSolutionAction(String localeName) {
  return TutorialFollowUpAction(
    id: tutorialActionShowSolutionId,
    title: _showSolutionTitle(localeName),
    description: _showSolutionDescription(localeName),
  );
}

String _showSolutionTitle(String localeName) {
  switch (localeName) {
    case 'ja':
      return '解答を生成してみましょう';
    case 'ko':
      return '풀이를 생성해 봅시다';
    case 'zh_TW':
      return '生成解題步驟';
    case 'zh_CN':
      return '生成解题步骤';
    case 'zh':
      return '生成解题步骤';
    default:
      return 'Generate the solution';
  }
}

String _showSolutionDescription(String localeName) {
  switch (localeName) {
    case 'ja':
      return '下部の「Show solution」ボタンをタップして、MathStep に解答を生成させましょう。';
    case 'ko':
      return '아래의 "Show solution" 버튼을 눌러 MathStep이 풀이를 만들어 보도록 하세요.';
    case 'zh_TW':
      return '點擊下方的「Show solution」按鈕，讓 MathStep 產生解題步驟。';
    case 'zh_CN':
      return '点击下方的“Show solution”按钮，让 MathStep 生成解题步骤。';
    case 'zh':
      return '点击下方的“Show solution”按钮，让 MathStep 生成解题步骤。';
    default:
      return 'Tap the "Show solution" button below to let MathStep create the step-by-step answer.';
  }
}
