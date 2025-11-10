import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// 광고 서비스
///
/// Google Mobile Ads를 사용하여 배너, 전면, 보상형 광고를 관리합니다.
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _isInitialized = false;
  bool _isPremium = false; // 프리미엄 사용자 여부

  // 테스트 광고 단위 ID (실제 배포 시 변경 필요)
  static const String _bannerAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/6300978111' // 테스트 ID
      : 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY'; // 실제 ID로 교체

  static const String _interstitialAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/1033173712' // 테스트 ID
      : 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY'; // 실제 ID로 교체

  static const String _rewardedAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/5224354917' // 테스트 ID
      : 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY'; // 실제 ID로 교체

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  /// 광고 SDK 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;

      if (kDebugMode) {
        print('[AdService] Google Mobile Ads 초기화 완료');
      }

      // 전면 광고 미리 로드
      _loadInterstitialAd();
    } catch (e) {
      if (kDebugMode) {
        print('[AdService] 광고 초기화 실패: $e');
      }
    }
  }

  /// 프리미엄 상태 설정
  void setPremiumStatus(bool isPremium) {
    _isPremium = isPremium;
    if (kDebugMode) {
      print('[AdService] 프리미엄 상태: $isPremium');
    }
  }

  /// 프리미엄 사용자 여부
  bool get isPremium => _isPremium;

  /// 배너 광고 생성
  BannerAd? createBannerAd({
    required Function(Ad ad) onAdLoaded,
    required Function(Ad ad, LoadAdError error) onAdFailedToLoad,
  }) {
    if (_isPremium) {
      if (kDebugMode) {
        print('[AdService] 프리미엄 사용자 - 배너 광고 표시 안 함');
      }
      return null;
    }

    return BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          if (kDebugMode) {
            print('[AdService] 배너 광고 로드 성공');
          }
          onAdLoaded(ad);
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          if (kDebugMode) {
            print('[AdService] 배너 광고 로드 실패: $error');
          }
          ad.dispose();
          onAdFailedToLoad(ad, error);
        },
      ),
    );
  }

  /// 전면 광고 로드
  void _loadInterstitialAd() {
    if (_isPremium) return;

    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _interstitialAd!.setImmersiveMode(true);

          if (kDebugMode) {
            print('[AdService] 전면 광고 로드 성공');
          }
        },
        onAdFailedToLoad: (LoadAdError error) {
          if (kDebugMode) {
            print('[AdService] 전면 광고 로드 실패: $error');
          }
          _interstitialAd = null;
        },
      ),
    );
  }

  /// 전면 광고 표시
  Future<bool> showInterstitialAd() async {
    if (_isPremium) {
      if (kDebugMode) {
        print('[AdService] 프리미엄 사용자 - 전면 광고 표시 안 함');
      }
      return false;
    }

    if (_interstitialAd == null) {
      if (kDebugMode) {
        print('[AdService] 전면 광고가 아직 로드되지 않음');
      }
      _loadInterstitialAd();
      return false;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        if (kDebugMode) {
          print('[AdService] 전면 광고 표시됨');
        }
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        if (kDebugMode) {
          print('[AdService] 전면 광고 닫힘');
        }
        ad.dispose();
        _loadInterstitialAd(); // 다음 광고 미리 로드
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        if (kDebugMode) {
          print('[AdService] 전면 광고 표시 실패: $error');
        }
        ad.dispose();
        _loadInterstitialAd();
      },
    );

    await _interstitialAd!.show();
    _interstitialAd = null;
    return true;
  }

  /// 보상형 광고 로드
  Future<void> loadRewardedAd() async {
    if (_isPremium) return;

    await RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;

          if (kDebugMode) {
            print('[AdService] 보상형 광고 로드 성공');
          }
        },
        onAdFailedToLoad: (LoadAdError error) {
          if (kDebugMode) {
            print('[AdService] 보상형 광고 로드 실패: $error');
          }
          _rewardedAd = null;
        },
      ),
    );
  }

  /// 보상형 광고 표시
  Future<bool> showRewardedAd({
    required Function() onUserEarnedReward,
  }) async {
    if (_isPremium) {
      if (kDebugMode) {
        print('[AdService] 프리미엄 사용자 - 보상 자동 지급');
      }
      onUserEarnedReward();
      return true;
    }

    if (_rewardedAd == null) {
      if (kDebugMode) {
        print('[AdService] 보상형 광고가 아직 로드되지 않음');
      }
      await loadRewardedAd();
      return false;
    }

    bool rewardGranted = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) {
        if (kDebugMode) {
          print('[AdService] 보상형 광고 표시됨');
        }
      },
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        if (kDebugMode) {
          print('[AdService] 보상형 광고 닫힘');
        }
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd(); // 다음 광고 미리 로드
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        if (kDebugMode) {
          print('[AdService] 보상형 광고 표시 실패: $error');
        }
        ad.dispose();
        _rewardedAd = null;
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        if (kDebugMode) {
          print('[AdService] 보상 획득: ${reward.amount} ${reward.type}');
        }
        rewardGranted = true;
        onUserEarnedReward();
      },
    );

    _rewardedAd = null;
    return rewardGranted;
  }

  /// 광고 사용 가능 여부
  bool get isInterstitialAdReady => _interstitialAd != null;
  bool get isRewardedAdReady => _rewardedAd != null;

  /// 리소스 정리
  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
