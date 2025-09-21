import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/reward_ad_service.dart';

/// リワード広告のプロバイダー
final rewardAdProvider = ChangeNotifierProvider<RewardAdNotifier>((ref) {
  return RewardAdNotifier();
});

/// リワード広告の状態を監視するプロバイダー
final rewardAdStateProvider = Provider<RewardAdState>((ref) {
  final notifier = ref.watch(rewardAdProvider);
  return RewardAdState(
    isAdLoaded: notifier.isAdLoaded,
    isLoading: notifier.isLoading,
  );
});

/// リワード広告の状態を表すクラス
class RewardAdState {
  final bool isAdLoaded;
  final bool isLoading;

  const RewardAdState({
    required this.isAdLoaded,
    required this.isLoading,
  });

  bool get canShowAd => isAdLoaded && !isLoading;
}
