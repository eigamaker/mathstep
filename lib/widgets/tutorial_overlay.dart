import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_colors.dart';
import '../localization/localization_extensions.dart';
import '../providers/tutorial_provider.dart';

class TutorialOverlay extends ConsumerWidget {
  const TutorialOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tutorialState = ref.watch(tutorialProvider);
    final step = ref.watch(currentTutorialStepProvider);

    if (!tutorialState.isActive || step == null) {
      return const SizedBox.shrink();
    }

    final bool isPracticeStep = step.mode == TutorialStepMode.practice;
    final bool isAwaitingAction =
        tutorialState.awaitingActionId == step.followUpAction?.id;
    final int completedKeys = isPracticeStep
        ? tutorialState.practiceKeyProgress.clamp(0, step.keySequence.length)
        : 0;

    // 画面の向きに応じてアライメントを調整
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
    
    final AlignmentGeometry alignment = isPracticeStep
        ? (isLandscape ? Alignment.centerLeft : Alignment.bottomCenter)
        : (isLandscape ? Alignment.centerRight : Alignment.topCenter);
    final EdgeInsets padding = isPracticeStep
        ? (isLandscape 
            ? const EdgeInsets.fromLTRB(16, 16, 0, 16)
            : const EdgeInsets.fromLTRB(16, 0, 16, 24))
        : (isLandscape
            ? const EdgeInsets.fromLTRB(0, 16, 16, 16)
            : const EdgeInsets.fromLTRB(16, 16, 16, 0));

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            ignoring: isPracticeStep || isAwaitingAction,
            child: Container(
              color: Colors.black.withValues(
                alpha: isPracticeStep ? 0.12 : 0.5,
              ),
            ),
          ),
        ),
        if (isPracticeStep && step.keySequence.isNotEmpty)
          _DraggablePracticeSequencePanel(
            step: step,
            completedKeys: completedKeys,
            showNextButton:
                tutorialState.practiceCompleted &&
                tutorialState.awaitingActionId == null &&
                !step.autoAdvanceOnComplete,
            onNextPressed: () =>
                ref.read(tutorialProvider.notifier).handleNextStepAction(),
          ),
        SafeArea(
          top: !isPracticeStep,
          bottom: isPracticeStep,
          child: Align(
            alignment: alignment,
            child: Padding(
              padding: padding,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: _TutorialCard(
                  step: step,
                  tutorialState: tutorialState,
                  completedKeys: completedKeys,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TutorialCard extends ConsumerWidget {
  const _TutorialCard({
    required this.step,
    required this.tutorialState,
    required this.completedKeys,
  });

  final TutorialStep step;
  final TutorialState tutorialState;
  final int completedKeys;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tutorialNotifier = ref.read(tutorialProvider.notifier);
    final totalSteps = tutorialNotifier.allSteps.length;
    final currentStepNumber = tutorialState.currentStepIndex + 1;
    final bool isFirstStep = tutorialState.currentStepIndex == 0;
    final bool isLastStep = tutorialState.currentStepIndex == totalSteps - 1;
    final bool isPracticeStep = step.mode == TutorialStepMode.practice;
    final bool hasFollowUpAction = step.followUpAction != null;
    final bool isAwaitingAction =
        tutorialState.awaitingActionId == step.followUpAction?.id;

    final List<Widget> children = <Widget>[];
    
    // ステップインジケーターはpractice modeでは表示しない
    if (!isPracticeStep) {
      children.addAll([
        _buildStepIndicator(context, currentStepNumber, totalSteps),
        const SizedBox(height: 16),
        Text(
          step.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
          textAlign: TextAlign.center,
        ),
      ]);
    } else {
      // practice modeではタイトルも非表示（キーシークエンスのみ表示）
    }

    if (!isPracticeStep && step.description.isNotEmpty) {
      children
        ..add(const SizedBox(height: 12))
        ..add(
          _buildDescriptionWithIcons(step.description),
        );
    }

    final bool showExampleExpression =
        step.exampleExpression.isNotEmpty &&
        !isPracticeStep; // practice modeでは例の式を表示しない

    if (showExampleExpression) {
      children
        ..add(const SizedBox(height: 16))
        ..add(_buildExampleExpression(step));
    }

    if (isPracticeStep &&
        !isAwaitingAction &&
        !tutorialState.practiceCompleted) {
      // practice modeでは、メッセージはドラッグ可能パネルに統合されているため、
      // ここでは何も表示しない（キーシーケンスパネルで表示）
    }

    if (isPracticeStep && tutorialState.practiceCompleted) {
      children
        ..add(const SizedBox(height: 12))
        ..add(
          _buildCompletionBanner(
            context,
            _practiceCompletionText(
              context,
              withFollowUpAction: hasFollowUpAction,
            ),
          ),
        );
    }

    if (isAwaitingAction && step.followUpAction != null) {
      children
        ..add(const SizedBox(height: 16))
        ..add(_buildActionBanner(step.followUpAction!));
      
      // 次に進むアクションの場合はボタンを表示
      if (step.followUpAction!.id == 'next_step') {
        children
          ..add(const SizedBox(height: 12))
          ..add(
            ElevatedButton(
              onPressed: () => ref.read(tutorialProvider.notifier).handleNextStepAction(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(step.followUpAction!.title),
            ),
          );
      }
    }

    // practice modeではアクションボタンを表示しない
    if (!isPracticeStep) {
      children.add(const SizedBox(height: 20));
      children.add(
        _buildActionButtons(
          context,
          tutorialNotifier,
          isFirstStep: isFirstStep,
          isLastStep: isLastStep,
          showNavigation: step.mode == TutorialStepMode.info,
        ),
      );
    }

    final Color cardColor = isPracticeStep
        ? AppColors.surface.withValues(alpha: 0.2)
        : AppColors.surface;

    return Card(
      elevation: isPracticeStep ? 4 : 8,
      color: cardColor,
      shadowColor: isPracticeStep
          ? AppColors.primary.withValues(alpha: 0.2)
          : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionWithIcons(String description) {
    // HELPボタンの説明文の場合、アイコンを表示
    if (description.contains('HELP') || description.contains('ヘルプ')) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.help_outline,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }
    
    // 通常の説明文
    return Text(
      description,
      style: const TextStyle(
        fontSize: 16,
        color: AppColors.textPrimary,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildStepIndicator(
    BuildContext context,
    int currentStepNumber,
    int totalSteps,
  ) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.tutorialStepIndicator(currentStepNumber, totalSteps),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: currentStepNumber / totalSteps,
          backgroundColor: AppColors.primaryContainer,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildExampleExpression(TutorialStep step) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Math.tex(
        step.exampleExpression,
        mathStyle: MathStyle.text,
        textStyle: const TextStyle(fontSize: 18, color: AppColors.primary),
        onErrorFallback: (_) => Text(
          step.exampleExpression,
          style: const TextStyle(
            fontSize: 18,
            fontFamily: 'monospace',
            color: AppColors.primary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }


  Widget _buildCompletionBanner(BuildContext context, String message) {
    return _InfoBanner(
      icon: Icons.check_circle,
      iconColor: AppColors.success,
      backgroundColor: AppColors.success.withValues(alpha: 0.12),
      textColor: AppColors.success,
      message: message,
    );
  }

  Widget _buildActionBanner(TutorialFollowUpAction action) {
    return _InfoBanner(
      icon: Icons.bolt,
      iconColor: AppColors.secondary,
      backgroundColor: AppColors.secondaryContainer,
      textColor: AppColors.secondary,
      message: '${action.title}\n${action.description}',
      textAlign: TextAlign.left,
    );
  }


  Widget _buildActionButtons(
    BuildContext context,
    TutorialNotifier tutorialNotifier, {
    required bool isFirstStep,
    required bool isLastStep,
    required bool showNavigation,
  }) {
    final l10n = context.l10n;
    final bool showPrevious = !isFirstStep;
    final bool showNext = showNavigation && !isLastStep;
    final bool showComplete = showNavigation && isLastStep;

    return Row(
      children: [
        TextButton(
          onPressed: tutorialNotifier.skipTutorial,
          child: Text(
            l10n.tutorialSkipButton,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        const Spacer(),
        if (showPrevious)
          TextButton(
            onPressed: tutorialNotifier.previousStep,
            child: Text(
              l10n.tutorialPreviousButton,
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
        if (showPrevious && (showNext || showComplete))
          const SizedBox(width: 8),
        if (showNext)
          ElevatedButton(
            onPressed: tutorialNotifier.nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(l10n.tutorialNextButton),
          ),
        if (showComplete)
          ElevatedButton(
            onPressed: tutorialNotifier.completeTutorial,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(l10n.tutorialCompleteButton),
          ),
      ],
    );
  }

  String _practiceCompletionText(
    BuildContext context, {
    required bool withFollowUpAction,
  }) {
    final locale = context.l10n.localeName;

    if (withFollowUpAction) {
      switch (locale) {
        case 'ja':
          return '入力完了です！続けて下の案内に従いましょう。';
        case 'ko':
          return '잘하셨어요! 아래 안내를 따라 계속 진행하세요.';
        case 'zh_TW':
          return '做得好！依照下方的說明繼續。';
        case 'zh_CN':
          return '做得好！按照下方的说明继续。';
        case 'zh':
          return '做得好！按照下方的说明继续。';
        default:
          return 'Great job! Follow the instructions below to continue.';
      }
    }

    switch (locale) {
      case 'ja':
        return 'ばっちりです！入力をいったんクリアして次のステップに進みます。';
      case 'ko':
        return '완벽해요! 입력을 지우고 다음 단계로 이동합니다.';
      case 'zh_TW':
        return '太好了！先清除輸入，再進入下一步。';
      case 'zh_CN':
        return '很好！我们会先清空输入，然后进入下一步。';
      case 'zh':
        return '很好！我们会先清空输入，然后进入下一步。';
      default:
        return 'Looks good! We’ll clear the input and move on to the next step.';
    }
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.textColor,
    required this.message,
    this.textAlign = TextAlign.left,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color textColor;
  final String message;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 14, color: textColor, height: 1.5),
              textAlign: textAlign,
            ),
          ),
        ],
      ),
    );
  }
}

class _PracticeSequencePanel extends StatelessWidget {
  const _PracticeSequencePanel({
    required this.step,
    required this.completedKeys,
    required this.showNextButton,
    this.onNextPressed,
  });

  final TutorialStep step;
  final int completedKeys;
  final bool showNextButton;
  final VoidCallback? onNextPressed;

  @override
  Widget build(BuildContext context) {
    if (step.keySequence.isEmpty) {
      return const SizedBox.shrink();
    }

    final int currentIndex = completedKeys.clamp(0, step.keySequence.length);
    final int remaining = (step.keySequence.length - completedKeys).clamp(0, step.keySequence.length);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // メッセージとキーシーケンスラベルを統合
          Row(
            children: [
              Icon(
                Icons.touch_app,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _practiceInstructionText(context),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          if (remaining > 0) ...[
            const SizedBox(height: 4),
            Text(
              _remainingKeysLabel(context, remaining),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 12),
          // キーシーケンス
          SizedBox(
            height: 48, // より高くして見やすく
            child: _buildScrollableKeySequence(step, currentIndex, completedKeys),
          ),
          if (showNextButton && onNextPressed != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: onNextPressed,
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: Text(
                  context.l10n.tutorialNextButton,
                  style: const TextStyle(fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScrollableKeySequence(
    TutorialStep step,
    int currentIndex,
    int completedKeys,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _ScrollController.controller,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(step.keySequence.length * 2 - 1, (index) {
              if (index.isOdd) {
                // 矢印を表示
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 18,
                    color: AppColors.primary.withValues(alpha: 0.7),
                  ),
                );
              }
              
              final keyIndex = index ~/ 2;
              final status = keyIndex < completedKeys
                  ? _KeyStepStatus.completed
                  : keyIndex == currentIndex
                  ? _KeyStepStatus.current
                  : _KeyStepStatus.upcoming;

              return _KeyStepChip(
                index: keyIndex,
                hint: step.keySequence[keyIndex],
                status: status,
                isCompact: false, // 通常サイズで見やすく
              );
            }),
          ),
        );
      },
    );
  }

  String _practiceInstructionText(BuildContext context) {
    switch (context.l10n.localeName) {
      case 'ja':
        return '表示されているキーの順番に下のキーパッドをタップして数式を入力してください。プレビューで確認してみましょう。';
      case 'ko':
        return '화면에 나온 순서대로 아래 키패드를 눌러 수식을 입력하세요. 미리보기에서 결과를 확인할 수 있습니다.';
      case 'zh_TW':
        return '依照顯示的順序點擊下方的鍵盤輸入公式，預覽會即時更新。';
      case 'zh_CN':
        return '按照显示的顺序点击下方的键盘输入公式，预览会实时更新。';
      case 'zh':
        return '按照显示的顺序点击下方的键盘输入公式，预览会实时更新。';
      default:
        return 'Tap the keys in the shown order on the keypad below. The preview updates as you go.';
    }
  }

  String _remainingKeysLabel(BuildContext context, int remaining) {
    switch (context.l10n.localeName) {
      case 'ja':
        return '残りキー数: $remaining';
      case 'ko':
        return '남은 키: $remaining';
      case 'zh_TW':
        return '剩餘按鍵：$remaining';
      case 'zh_CN':
        return '剩余按键：$remaining';
      case 'zh':
        return '剩余按键：$remaining';
      default:
        return 'Keys remaining: $remaining';
    }
  }
}

class _DraggablePracticeSequencePanel extends StatefulWidget {
  const _DraggablePracticeSequencePanel({
    required this.step,
    required this.completedKeys,
    required this.showNextButton,
    this.onNextPressed,
  });

  final TutorialStep step;
  final int completedKeys;
  final bool showNextButton;
  final VoidCallback? onNextPressed;

  @override
  State<_DraggablePracticeSequencePanel> createState() => _DraggablePracticeSequencePanelState();
}

class _DraggablePracticeSequencePanelState extends State<_DraggablePracticeSequencePanel> {
  Offset _position = const Offset(0, 0);
  bool _isDragging = false;
  late Size _screenSize;
  late double _panelHeight;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screenSize = MediaQuery.of(context).size;
    // パネルの高さを推定（メッセージ + キーシーケンス + ボタン）
    _panelHeight = 140.0;
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = _screenSize.width > _screenSize.height;
    
    // 画面の向きに応じて初期位置を調整
    final initialY = isLandscape 
        ? _screenSize.height / 2 - _panelHeight / 2  // 横向き：中央
        : _screenSize.height - _panelHeight - 200;   // 縦向き：下部
    
    return Positioned(
      left: isLandscape ? 16 + _position.dx : 16 + _position.dx,
      top: initialY + _position.dy,
      right: isLandscape ? null : 16 - _position.dx,
      width: isLandscape ? 300 : null, // 横向きの場合は固定幅
      child: GestureDetector(
        onPanStart: (details) {
          setState(() {
            _isDragging = true;
          });
        },
        onPanUpdate: (details) {
          setState(() {
            final newY = _position.dy + details.delta.dy;
            final newX = _position.dx + details.delta.dx;
            
            if (isLandscape) {
              // 横向きの場合：左右の制限を厳しく、上下の制限を緩く
              final minY = -(_screenSize.height - _panelHeight - 50);
              final maxY = _screenSize.height - _panelHeight - 50;
              final minX = -(_screenSize.width - 320); // パネル幅を考慮
              final maxX = _screenSize.width - 320;
              
              _position = Offset(
                newX.clamp(minX, maxX).toDouble(),
                newY.clamp(minY, maxY).toDouble(),
              );
            } else {
              // 縦向きの場合：従来の制限
              final minY = -(_screenSize.height - _panelHeight - 100);
              final maxY = _screenSize.height - _panelHeight - 100;
              final minX = -(_screenSize.width - 100);
              final maxX = _screenSize.width - 100;
              
              _position = Offset(
                newX.clamp(minX, maxX).toDouble(),
                newY.clamp(minY, maxY).toDouble(),
              );
            }
          });
        },
        onPanEnd: (details) {
          setState(() {
            _isDragging = false;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(_isDragging ? 1.05 : 1.0),
          child: _PracticeSequencePanel(
            step: widget.step,
            completedKeys: widget.completedKeys,
            showNextButton: widget.showNextButton,
            onNextPressed: widget.onNextPressed,
          ),
        ),
      ),
    );
  }
}

class _ScrollController {
  static ScrollController? _controller;
  
  static ScrollController get controller {
    _controller ??= ScrollController();
    return _controller!;
  }
  
}

enum _KeyStepStatus { completed, current, upcoming }

class _KeyStepChip extends StatelessWidget {
  const _KeyStepChip({
    required this.index,
    required this.hint,
    required this.status,
    this.isCompact = false,
  });

  final int index;
  final TutorialKeyHint hint;
  final _KeyStepStatus status;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    Color background;
    Color borderColor;
    Color textColor;

    switch (status) {
      case _KeyStepStatus.completed:
        background = AppColors.success.withValues(alpha: 0.15);
        borderColor = AppColors.success.withValues(alpha: 0.4);
        textColor = AppColors.success;
        break;
      case _KeyStepStatus.current:
        background = AppColors.secondary.withValues(alpha: 0.2);
        borderColor = AppColors.secondary;
        textColor = AppColors.secondary;
        break;
      case _KeyStepStatus.upcoming:
        background = AppColors.surface;
        borderColor = AppColors.border;
        textColor = AppColors.textSecondary;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: isCompact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(isCompact ? 16 : 18),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: status == _KeyStepStatus.current
            ? [
                BoxShadow(
                  color: borderColor.withValues(alpha: 0.4),
                  blurRadius: isCompact ? 6 : 12,
                  offset: const Offset(0, 3),
                ),
              ]
            : status == _KeyStepStatus.completed
            ? [
                BoxShadow(
                  color: borderColor.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Text(
        hint.label,
        style: TextStyle(
          fontSize: isCompact ? 12 : 18,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

