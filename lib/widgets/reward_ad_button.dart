import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../localization/localization_extensions.dart';
import '../providers/reward_ad_provider.dart';
import '../services/reward_ad_service.dart';
import '../constants/app_colors.dart';
import '../providers/tutorial_provider.dart';

class RewardAdButton extends ConsumerStatefulWidget {
  const RewardAdButton({
    super.key,
    required this.onRewardEarned,
    this.isLoading = false,
  });

  final VoidCallback onRewardEarned;
  final bool isLoading;

  @override
  ConsumerState<RewardAdButton> createState() => _RewardAdButtonState();
}

class _RewardAdButtonState extends ConsumerState<RewardAdButton> {
  bool _isShowingAd = false;

  @override
  Widget build(BuildContext context) {
    final adState = ref.watch(rewardAdStateProvider);
    final adNotifier = ref.read(rewardAdProvider);

    return SizedBox(
      width: double.infinity,
      height: 56, // 他のフィールドと統一
      child: ElevatedButton.icon(
        onPressed: _isShowingAd || widget.isLoading
            ? null
            : () => _showRewardAd(adNotifier),
        icon: _getButtonIcon(adState),
        label: Text(
          _getButtonText(context, adState),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _getButtonColor(adState),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _getButtonIcon(RewardAdState adState) {
    if (_isShowingAd || widget.isLoading || adState.isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (adState.isAdLoaded) {
      return const Icon(Icons.play_arrow, size: 24);
    }

    return const Icon(Icons.download, size: 24);
  }

  String _getButtonText(BuildContext context, RewardAdState adState) {
    final l10n = context.l10n;

    if (_isShowingAd) {
      return l10n.rewardAdShowingMessage;
    }

    if (widget.isLoading) {
      return l10n.homeGenerating;
    }

    if (adState.isLoading) {
      return l10n.adLoadingMessage;
    }

    if (adState.isAdLoaded) {
      return l10n.rewardAdButtonReady;
    }

    return l10n.adLoadingMessage;
  }

  Color _getButtonColor(RewardAdState adState) {
    if (_isShowingAd || widget.isLoading || adState.isLoading) {
      return AppColors.neutral;
    }

    if (adState.isAdLoaded) {
      return AppColors.primary;
    }

    return AppColors.warning;
  }

  Future<void> _showRewardAd(RewardAdNotifier adNotifier) async {
    if (_isShowingAd || widget.isLoading) {
      debugPrint(
        'RewardAdButton: Cannot show ad - _isShowingAd: $_isShowingAd, isLoading: ${widget.isLoading}',
      );
      return;
    }

    final tutorialNotifier = ref.read(tutorialProvider.notifier);
    if (tutorialNotifier.isAwaitingShowSolutionAction) {
      debugPrint(
        'RewardAdButton: Tutorial mode detected, skipping ad and generating solution directly.',
      );
      widget.onRewardEarned();
      _showSuccessSnackBar(context.l10n.adRewardMessage);
      tutorialNotifier.completeFollowUpAction(tutorialActionShowSolutionId);
      return;
    }

    debugPrint('RewardAdButton: Starting to show reward ad...');
    setState(() => _isShowingAd = true);

    try {
      if (!adNotifier.isAdLoaded) {
        debugPrint('RewardAdButton: Ad not loaded, loading ad...');
        await adNotifier.loadAd();
      }

      if (!mounted) {
        debugPrint('RewardAdButton: Widget not mounted after loading');
        return;
      }

      if (!adNotifier.isAdLoaded) {
        debugPrint('RewardAdButton: Ad still not loaded after loading attempt');
        _showErrorSnackBar(context.l10n.adLoadFailedMessage);
        return;
      }

      debugPrint('RewardAdButton: Ad loaded, showing ad...');
      final rewarded = await adNotifier.showAd();
      if (!mounted) return;

      debugPrint('RewardAdButton: Ad shown, rewarded: $rewarded');
      if (rewarded) {
        _showSuccessSnackBar(context.l10n.adRewardMessage);
        widget.onRewardEarned();
      } else {
        _showErrorSnackBar(context.l10n.adNotReadyMessage);
      }
    } catch (error) {
      debugPrint('RewardAdButton: Error while showing ad: $error');
      if (!mounted) return;
      _showErrorSnackBar(context.l10n.adLoadFailedMessage);
    } finally {
      debugPrint('RewardAdButton: Ad showing process completed');
      if (mounted) {
        setState(() => _isShowingAd = false);
      } else {
        _isShowingAd = false;
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
