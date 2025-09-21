import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../providers/reward_ad_provider.dart';
import '../services/reward_ad_service.dart';

/// リワード広告を表示するボタン
class RewardAdButton extends ConsumerStatefulWidget {
  const RewardAdButton({
    super.key,
    required this.onRewardEarned,
    this.isLoading = false,
    this.buttonText = '解法を表示',
    this.loadingText = '生成中...',
  });

  final VoidCallback onRewardEarned;
  final bool isLoading;
  final String buttonText;
  final String loadingText;

  @override
  ConsumerState<RewardAdButton> createState() => _RewardAdButtonState();
}

class _RewardAdButtonState extends ConsumerState<RewardAdButton> {
  bool _isShowingAd = false;

  @override
  Widget build(BuildContext context) {
    final adState = ref.watch(rewardAdStateProvider);
    final adNotifier = ref.read(rewardAdProvider);

    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isShowingAd || widget.isLoading ? null : () => _showRewardAd(adNotifier),
        icon: _getButtonIcon(adState),
        label: Text(
          _getButtonText(adState),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
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
    if (_isShowingAd || widget.isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (adState.isLoading) {
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

  String _getButtonText(RewardAdState adState) {
    if (_isShowingAd) {
      return '広告を表示中...';
    }

    if (widget.isLoading) {
      return widget.loadingText;
    }

    if (adState.isLoading) {
      return AppConstants.adLoadingMessage;
    }

    if (adState.isAdLoaded) {
      return widget.buttonText;
    }

    return '広告を読み込み中...';
  }

  Color _getButtonColor(RewardAdState adState) {
    if (_isShowingAd || widget.isLoading || adState.isLoading) {
      return Colors.grey;
    }

    if (adState.isAdLoaded) {
      return Colors.blue;
    }

    return Colors.orange;
  }

  Future<void> _showRewardAd(RewardAdNotifier adNotifier) async {
    if (!adNotifier.isAdLoaded) {
      // 広告が読み込まれていない場合は読み込む
      await adNotifier.loadAd();
      if (!adNotifier.isAdLoaded) {
        // 広告の読み込みに失敗した場合は、直接報酬を付与
        _showErrorSnackBar('広告の読み込みに失敗しました。解法を表示します。');
        widget.onRewardEarned();
        return;
      }
    }

    setState(() => _isShowingAd = true);

    try {
      final success = await adNotifier.showAd();
      if (success) {
        _showSuccessSnackBar(AppConstants.adRewardMessage);
        widget.onRewardEarned();
      } else {
        // 広告の表示に失敗した場合は、直接報酬を付与
        _showErrorSnackBar('広告の表示に失敗しました。解法を表示します。');
        widget.onRewardEarned();
      }
    } catch (e) {
      // 例外が発生した場合は、直接報酬を付与
      _showErrorSnackBar('広告の表示に失敗しました。解法を表示します。');
      widget.onRewardEarned();
    } finally {
      setState(() => _isShowingAd = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
