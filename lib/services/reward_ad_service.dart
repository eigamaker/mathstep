import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../constants/app_constants.dart';

class RewardAdService {
  static final RewardAdService _instance = RewardAdService._internal();
  factory RewardAdService() => _instance;
  RewardAdService._internal();

  RewardedAd? _rewardedAd;
  bool _isLoading = false;
  bool _isDisposed = false;
  Completer<void>? _loadingCompleter;
  Timer? _loadTimeoutTimer;
  Timer? _scheduledRetryTimer;
  VoidCallback? _onStateChanged;

  bool get isAdLoaded => !_isDisposed && _rewardedAd != null;
  bool get isLoading => _isLoading;

  void setOnStateChanged(VoidCallback? callback) {
    _onStateChanged = callback;
  }

  void _notifyStateChanged() {
    _onStateChanged?.call();
  }

  Future<void> loadRewardedAd({bool forceReload = false}) async {
    if (_isDisposed) {
      debugPrint('RewardAdService: Service disposed. Skipping load.');
      return;
    }

    if (_rewardedAd != null && !forceReload) {
      debugPrint('RewardAdService: Ad already available. Skipping load.');
      return;
    }

    if (_isLoading) {
      debugPrint('RewardAdService: Load already in progress. Waiting for completion.');
      try {
        await _loadingCompleter?.future;
      } catch (error) {
        debugPrint('RewardAdService: Previous load finished with error: $error');
      }

      if (_isDisposed) {
        return;
      }

      if (_rewardedAd != null && !forceReload) {
        debugPrint('RewardAdService: Ad became available while waiting.');
        return;
      }

      debugPrint('RewardAdService: Retrying rewarded ad load.');
    }

    if (forceReload) {
      _disposeAd();
    }

    _scheduledRetryTimer?.cancel();
    _scheduledRetryTimer = null;

    _isLoading = true;
    _notifyStateChanged();

    debugPrint('RewardAdService: Starting rewarded ad load.');
    debugPrint('RewardAdService: Ad Unit ID: ${_getAdUnitId()}');
    debugPrint('RewardAdService: Platform: ${Platform.operatingSystem}');
    debugPrint('RewardAdService: Debug mode: $kDebugMode');
    debugPrint('RewardAdService: Is simulator: ${Platform.isIOS && Platform.environment['SIMULATOR_DEVICE_NAME'] != null}');

    final completer = Completer<void>();
    _loadingCompleter = completer;
    _startLoadTimeoutTimer(completer);

    try {
      RewardedAd.load(
        adUnitId: _getAdUnitId(),
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            if (_shouldIgnoreLoadCallback(completer)) {
              debugPrint('RewardAdService: Loaded ad ignored (stale or disposed).');
              ad.dispose();
              return;
            }

            debugPrint('RewardAdService: Rewarded ad loaded successfully.');
            _cancelLoadTimeoutTimer();
            _rewardedAd = ad;
            _isLoading = false;
            _loadingCompleter = null;
            _notifyStateChanged();
            completer.complete();
          },
          onAdFailedToLoad: (error) {
            if (_shouldIgnoreLoadCallback(completer)) {
              debugPrint('RewardAdService: Ignoring stale load failure.');
              return;
            }

            debugPrint(
              'RewardAdService: Failed to load rewarded ad. Code: ${error.code}, '
              'Message: ${error.message}, Domain: ${error.domain}',
            );
            _cancelLoadTimeoutTimer();
            _isLoading = false;
            _rewardedAd = null;
            _loadingCompleter = null;
            _notifyStateChanged();
            completer.completeError(error);
            _scheduleRetry();
          },
        ),
      );

      await completer.future;
    } catch (error, stackTrace) {
      _cancelLoadTimeoutTimer();
      if (_loadingCompleter == completer) {
        _loadingCompleter = null;
      }
      _isLoading = false;
      _rewardedAd = null;
      _notifyStateChanged();
      _scheduleRetry();
      debugPrint('RewardAdService: Exception while loading rewarded ad: $error');
      debugPrint('$stackTrace');
    }
  }

  Future<bool> showRewardedAd() async {
    if (_isDisposed) {
      debugPrint('RewardAdService: Service disposed. Cannot show ad.');
      return false;
    }

    if (_rewardedAd == null) {
      debugPrint('RewardAdService: No ad preloaded. Attempting to load before show.');
      try {
        await loadRewardedAd();
      } catch (error) {
        debugPrint('RewardAdService: Preload before show failed: $error');
      }
    }

    final ad = _rewardedAd;
    if (ad == null) {
      debugPrint('RewardAdService: Show aborted. Ad unavailable after load attempt.');
      return false;
    }

    _rewardedAd = null;
    _notifyStateChanged();

    final resultCompleter = Completer<bool>();
    var rewardEarned = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('RewardAdService: Ad showed full screen content.');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('RewardAdService: Ad dismissed full screen content.');
        ad.dispose();
        if (!resultCompleter.isCompleted) {
          resultCompleter.complete(rewardEarned);
        }
        if (!_isDisposed) {
          loadRewardedAd();
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('RewardAdService: Ad failed to show full screen content: $error');
        ad.dispose();
        if (!resultCompleter.isCompleted) {
          resultCompleter.complete(false);
        }
        if (!_isDisposed) {
          loadRewardedAd();
        }
      },
    );

    try {
      await ad.show(
        onUserEarnedReward: (ad, reward) {
          debugPrint('RewardAdService: User earned reward: ${reward.amount} ${reward.type}');
          rewardEarned = true;
        },
      );
    } catch (error, stackTrace) {
      debugPrint('RewardAdService: Error while showing rewarded ad: $error');
      debugPrint('$stackTrace');
      ad.dispose();
      if (!resultCompleter.isCompleted) {
        resultCompleter.complete(false);
      }
      if (!_isDisposed) {
        loadRewardedAd();
      }
    }

    return resultCompleter.future;
  }

  void forceStopLoading() {
    if (!_isLoading) {
      _scheduledRetryTimer?.cancel();
      _scheduledRetryTimer = null;
      return;
    }

    debugPrint('RewardAdService: Force stopping current ad load.');
    _cancelLoadTimeoutTimer();
    _scheduledRetryTimer?.cancel();
    _scheduledRetryTimer = null;
    final completer = _loadingCompleter;
    _loadingCompleter = null;
    _isLoading = false;
    _notifyStateChanged();
    completer?.completeError(StateError('Ad load cancelled'));
  }

  void dispose() {
    if (_isDisposed) {
      return;
    }

    debugPrint('RewardAdService: Disposing service.');
    _isDisposed = true;
    forceStopLoading();
    _disposeAd();
    _onStateChanged = null;
  }

  bool _shouldIgnoreLoadCallback(Completer<void> completer) {
    return _isDisposed || _loadingCompleter != completer;
  }

  void _startLoadTimeoutTimer(Completer<void> completer) {
    _cancelLoadTimeoutTimer();
    _loadTimeoutTimer = Timer(const Duration(seconds: 30), () {
      if (_shouldIgnoreLoadCallback(completer)) {
        return;
      }

      debugPrint('RewardAdService: Rewarded ad load timed out.');
      _cancelLoadTimeoutTimer();
      _isLoading = false;
      _loadingCompleter = null;
      _disposeAd();
      _notifyStateChanged();
      completer.completeError(
        TimeoutException('Rewarded ad load timed out', const Duration(seconds: 30)),
      );
      _scheduleRetry();
    });
  }

  void _cancelLoadTimeoutTimer() {
    _loadTimeoutTimer?.cancel();
    _loadTimeoutTimer = null;
  }

  void _scheduleRetry() {
    if (_isDisposed) {
      return;
    }

    _scheduledRetryTimer?.cancel();
    _scheduledRetryTimer = Timer(const Duration(seconds: 5), () {
      _scheduledRetryTimer = null;
      if (_isDisposed || _isLoading || _rewardedAd != null) {
        return;
      }
      loadRewardedAd();
    });
  }

  void _disposeAd() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }

  String _getAdUnitId() {
    return AppConstants.getRewardedAdUnitId();
  }
}

class RewardAdNotifier extends ChangeNotifier {
  final RewardAdService _adService = RewardAdService();

  RewardAdNotifier() {
    _adService.setOnStateChanged(() {
      notifyListeners();
    });
  }

  bool get isAdLoaded => _adService.isAdLoaded;
  bool get isLoading => _adService.isLoading;

  Future<void> loadAd({bool forceReload = false}) async {
    await _adService.loadRewardedAd(forceReload: forceReload);
  }

  Future<bool> showAd() async {
    return _adService.showRewardedAd();
  }

  void forceStopLoading() {
    _adService.forceStopLoading();
  }

  @override
  void dispose() {
    _adService.setOnStateChanged(null);
    _adService.dispose();
    super.dispose();
  }
}
