import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/app_constants.dart';

/// 繝ｪ繝ｯ繝ｼ繝牙ｺ・相繧堤ｮ｡逅・☆繧九し繝ｼ繝薙せ
class RewardAdService {
  static final RewardAdService _instance = RewardAdService._internal();
  factory RewardAdService() => _instance;
  RewardAdService._internal();

  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;
  bool _isLoading = false;
  bool _isDisposed = false;
  Completer<void>? _loadCompleter;
  Timer? _loadTimeoutTimer;

  /// 蠎・相縺瑚ｪｭ縺ｿ霎ｼ縺ｾ繧後※縺・ｋ縺九←縺・°
  bool get isAdLoaded => _isAdLoaded;

  /// 蠎・相繧定ｪｭ縺ｿ霎ｼ縺ｿ荳ｭ縺九←縺・°
  bool get isLoading => _isLoading;

  /// 繝ｪ繝ｯ繝ｼ繝牙ｺ・相繧定ｪｭ縺ｿ霎ｼ繧
  Future<void> loadRewardedAd() async {
    if (_isDisposed) {
      debugPrint('RewardAdService: Service is disposed, cannot load ad');
      return;
    }

    if (_isLoading || _isAdLoaded) {
      debugPrint(
        'RewardAdService: Already loading or loaded. isLoading: $_isLoading, isAdLoaded: $_isAdLoaded',
      );
      return;
    }

    _isLoading = true;
    debugPrint('RewardAdService: ========== STARTING AD LOAD ==========');
    debugPrint('RewardAdService: Loading rewarded ad...');
    debugPrint('RewardAdService: Ad Unit ID: ${_getAdUnitId()}');
    debugPrint('RewardAdService: Debug mode: $kDebugMode');
    debugPrint('RewardAdService: Platform: ${Platform.operatingSystem}');

    final completer = Completer<void>();
    _loadCompleter = completer;
    _startLoadTimeoutTimer();

    try {
      _loadRewardedAdInternal();
    } catch (error, stackTrace) {
      debugPrint('RewardAdService: Error starting rewarded ad load: $error');
      debugPrint('$stackTrace');
      _isAdLoaded = false;
      _isLoading = false;
      _cancelLoadTimeoutTimer();
      _completeLoadWithError(error);
    }

    try {
      await completer.future;
    } catch (error) {
      debugPrint('RewardAdService: ========== EXCEPTION IN AD LOAD ==========');
      debugPrint('RewardAdService: Exception type: ${error.runtimeType}');
      debugPrint('RewardAdService: Exception message: $error');

      if (error is TimeoutException) {
        debugPrint(
          'RewardAdService: Ad loading timeout. Current state - isLoading: $_isLoading, isAdLoaded: $_isAdLoaded',
        );
      } else if (error is StateError) {
        debugPrint(
          'RewardAdService: Ad loading was force stopped or service disposed.',
        );
      }
    } finally {
      _cancelLoadTimeoutTimer();
      _loadCompleter = null;
    }
  }

  void _completeLoadSuccessfully() {
    if (_loadCompleter != null && !_loadCompleter!.isCompleted) {
      _loadCompleter!.complete();
    }
  }

  void _completeLoadWithError(Object error) {
    if (_loadCompleter != null && !_loadCompleter!.isCompleted) {
      _loadCompleter!.completeError(error);
    }
  }

  void _startLoadTimeoutTimer() {
    _cancelLoadTimeoutTimer();
    _loadTimeoutTimer = Timer(const Duration(seconds: 15), () {
      _loadTimeoutTimer = null;
      if (_loadCompleter == null || _loadCompleter!.isCompleted) {
        return;
      }

      debugPrint('RewardAdService: ========== AD LOAD TIMEOUT ==========');
      debugPrint('RewardAdService: Timeout after 15 seconds');
      _isLoading = false;
      _isAdLoaded = false;
      final timeoutException = TimeoutException(
        'Ad loading timeout',
        const Duration(seconds: 15),
      );
      _completeLoadWithError(timeoutException);

      Future.delayed(const Duration(seconds: 3), () {
        if (!_isAdLoaded && !_isLoading && !_isDisposed) {
          debugPrint('RewardAdService: Retrying ad load after timeout...');
          loadRewardedAd();
        }
      });
    });
  }

  void _cancelLoadTimeoutTimer() {
    _loadTimeoutTimer?.cancel();
    _loadTimeoutTimer = null;
  }

  void _loadRewardedAdInternal() {
    debugPrint('RewardAdService: Calling RewardedAd.load()...');

    RewardedAd.load(
      adUnitId: _getAdUnitId(),
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint(
            'RewardAdService: ========== AD LOADED SUCCESSFULLY ==========',
          );
          debugPrint('RewardAdService: Ad ID: ${ad.adUnitId}');
          debugPrint(
            'RewardAdService: Ad Response ID: ${ad.responseInfo?.responseId}',
          );
          debugPrint(
            'RewardAdService: Ad Network: ${ad.responseInfo?.mediationAdapterClassName}',
          );
          _cancelLoadTimeoutTimer();
          _rewardedAd = ad;
          _isAdLoaded = true;
          _isLoading = false;
          _setFullScreenContentCallback();
          _completeLoadSuccessfully();
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardAdService: ========== AD LOAD FAILED ==========');
          debugPrint('RewardAdService: Error code: ${error.code}');
          debugPrint('RewardAdService: Error message: ${error.message}');
          debugPrint('RewardAdService: Error domain: ${error.domain}');
          debugPrint(
            'RewardAdService: Response ID: ${error.responseInfo?.responseId}',
          );
          debugPrint(
            'RewardAdService: Mediation Adapter: ${error.responseInfo?.mediationAdapterClassName}',
          );
          debugPrint(
            'RewardAdService: Adapter Responses: ${error.responseInfo?.adapterResponses?.length}',
          );
          _cancelLoadTimeoutTimer();
          _rewardedAd = null;
          _isAdLoaded = false;
          _isLoading = false;

          if (!_isDisposed && error.code == 0) {
            debugPrint('RewardAdService: Retrying in 5 seconds...');
            Future.delayed(const Duration(seconds: 5), () {
              if (!_isAdLoaded && !_isLoading && !_isDisposed) {
                loadRewardedAd();
              }
            });
          } else {
            debugPrint(
              'RewardAdService: Not retrying due to error code: ${error.code}',
            );
          }

          _completeLoadWithError(error);
        },
      ),
    );
  }

  /// 繝ｪ繝ｯ繝ｼ繝牙ｺ・相繧定｡ｨ遉ｺ縺吶ｋ
  Future<bool> showRewardedAd() async {
    if (!_isAdLoaded || _rewardedAd == null) {
      debugPrint('RewardAdService: No ad loaded');
      return false;
    }

    try {
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          debugPrint(
            'RewardAdService: User earned reward: ${reward.amount} ${reward.type}',
          );
        },
      );
      return true;
    } catch (e) {
      debugPrint('RewardAdService: Error showing rewarded ad: $e');
      return false;
    }
  }

  /// 蠎・相繧堤ｴ譽・☆繧・
  void dispose() {
    debugPrint('RewardAdService: Disposing service...');
    _isDisposed = true;
    forceStopLoading();
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isAdLoaded = false;
    _isLoading = false;
  }

  /// 蠑ｷ蛻ｶ逧・↓隱ｭ縺ｿ霎ｼ縺ｿ繧貞●豁｢縺吶ｋ
  void forceStopLoading() {
    debugPrint('RewardAdService: Force stopping ad loading...');
    _cancelLoadTimeoutTimer();
    if (_loadCompleter != null && !_loadCompleter!.isCompleted) {
      _completeLoadWithError(StateError('Ad load force stopped'));
    }
    _loadCompleter = null;
    _isLoading = false;
    _isAdLoaded = false;
  }

  /// 繝輔Ν繧ｹ繧ｯ繝ｪ繝ｼ繝ｳ繧ｳ繝ｳ繝・Φ繝・さ繝ｼ繝ｫ繝舌ャ繧ｯ繧定ｨｭ螳・
  void _setFullScreenContentCallback() {
    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('RewardAdService: Ad showed full screen content');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('RewardAdService: Ad dismissed full screen content');
        ad.dispose();
        _rewardedAd = null;
        _isAdLoaded = false;
        // 谺｡縺ｮ蠎・相繧剃ｺ句燕隱ｭ縺ｿ霎ｼ縺ｿ
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint(
          'RewardAdService: Ad failed to show full screen content: $error',
        );
        ad.dispose();
        _rewardedAd = null;
        _isAdLoaded = false;
      },
    );
  }

  /// 繝励Λ繝・ヨ繝輔か繝ｼ繝縺ｫ蠢懊§縺溷ｺ・相繝ｦ繝九ャ繝・D繧貞叙蠕・
  String _getAdUnitId() {
    // 繝・せ繝育畑繧貞ｼｷ蛻ｶ菴ｿ逕ｨ・域悽逡ｪ逕ｨ縺ｯ繧ｳ繝｡繝ｳ繝医い繧ｦ繝茨ｼ・
    return AppConstants.testRewardedAdUnitId;

    // 譛ｬ逡ｪ逕ｨ縺ｫ蛻・ｊ譖ｿ縺医ｋ蝣ｴ蜷医・莉･荳九・繧ｳ繝｡繝ｳ繝医ｒ螟悶☆
    // if (kDebugMode) {
    //   return AppConstants.testRewardedAdUnitId;
    // }
    // return AppConstants.productionRewardedAdUnitId;
  }
}

/// 繝ｪ繝ｯ繝ｼ繝牙ｺ・相縺ｮ迥ｶ諷九ｒ邂｡逅・☆繧九・繝ｭ繝舌う繝繝ｼ
class RewardAdNotifier extends ChangeNotifier {
  final RewardAdService _adService = RewardAdService();

  bool get isAdLoaded => _adService.isAdLoaded;
  bool get isLoading => _adService.isLoading;

  /// 蠎・相繧定ｪｭ縺ｿ霎ｼ繧
  Future<void> loadAd() async {
    final future = _adService.loadRewardedAd();
    if (_adService.isLoading) {
      notifyListeners();
    }
    await future;
    notifyListeners();
  }

  /// 蠎・相繧定｡ｨ遉ｺ縺吶ｋ
  Future<bool> showAd() async {
    final success = await _adService.showRewardedAd();
    notifyListeners();
    return success;
  }

  /// 蠑ｷ蛻ｶ逧・↓隱ｭ縺ｿ霎ｼ縺ｿ繧貞●豁｢縺吶ｋ
  void forceStopLoading() {
    _adService.forceStopLoading();
    notifyListeners();
  }

  @override
  void dispose() {
    _adService.dispose();
    super.dispose();
  }
}
