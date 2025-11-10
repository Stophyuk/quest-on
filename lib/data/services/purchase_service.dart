import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:quest_on/data/services/ad_service.dart';

/// 인앱 구매 서비스
///
/// 프리미엄 구독 및 광고 제거 상품을 관리합니다.
class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _isInitialized = false;
  bool _isPremium = false;

  // 상품 ID (Google Play Console / App Store Connect에서 생성 필요)
  static const String premiumMonthly = 'quest_on_premium_monthly';
  static const String premiumYearly = 'quest_on_premium_yearly';
  static const String removeAds = 'quest_on_remove_ads';

  static const Set<String> _productIds = {
    premiumMonthly,
    premiumYearly,
    removeAds,
  };

  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];

  /// 인앱 구매 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 인앱 구매 사용 가능 여부 확인
      final bool available = await _iap.isAvailable();
      if (!available) {
        if (kDebugMode) {
          print('[PurchaseService] 인앱 구매를 사용할 수 없습니다');
        }
        return;
      }

      // 구매 스트림 구독
      _subscription = _iap.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: _onPurchaseDone,
        onError: _onPurchaseError,
      );

      // 상품 정보 로드
      await _loadProducts();

      // 이전 구매 복원
      await _restorePurchases();

      _isInitialized = true;

      if (kDebugMode) {
        print('[PurchaseService] 초기화 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[PurchaseService] 초기화 실패: $e');
      }
    }
  }

  /// 상품 정보 로드
  Future<void> _loadProducts() async {
    try {
      final ProductDetailsResponse response =
          await _iap.queryProductDetails(_productIds);

      if (response.notFoundIDs.isNotEmpty) {
        if (kDebugMode) {
          print('[PurchaseService] 찾을 수 없는 상품: ${response.notFoundIDs}');
        }
      }

      _products = response.productDetails;

      if (kDebugMode) {
        print('[PurchaseService] 로드된 상품: ${_products.length}개');
        for (var product in _products) {
          print('  - ${product.id}: ${product.title} (${product.price})');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[PurchaseService] 상품 로드 실패: $e');
      }
    }
  }

  /// 이전 구매 복원
  Future<void> _restorePurchases() async {
    try {
      await _iap.restorePurchases();

      if (kDebugMode) {
        print('[PurchaseService] 구매 복원 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[PurchaseService] 구매 복원 실패: $e');
      }
    }
  }

  /// 구매 업데이트 처리
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchase in purchaseDetailsList) {
      if (kDebugMode) {
        print('[PurchaseService] 구매 상태 업데이트: ${purchase.productID} - ${purchase.status}');
      }

      if (purchase.status == PurchaseStatus.pending) {
        // 구매 대기 중
        _showPendingUI();
      } else if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // 구매 완료 또는 복원됨
        _verifyAndDeliverProduct(purchase);
      } else if (purchase.status == PurchaseStatus.error) {
        // 구매 오류
        _handlePurchaseError(purchase);
      } else if (purchase.status == PurchaseStatus.canceled) {
        // 구매 취소
        if (kDebugMode) {
          print('[PurchaseService] 구매 취소: ${purchase.productID}');
        }
      }

      // 구매 완료 처리
      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  /// 구매 검증 및 상품 제공
  Future<void> _verifyAndDeliverProduct(PurchaseDetails purchase) async {
    // TODO: 실제 프로덕션에서는 서버에서 영수증 검증 필요
    // 여기서는 간단히 로컬에서 처리

    if (purchase.productID == premiumMonthly ||
        purchase.productID == premiumYearly ||
        purchase.productID == removeAds) {
      _isPremium = true;
      AdService().setPremiumStatus(true);

      if (kDebugMode) {
        print('[PurchaseService] 프리미엄 활성화: ${purchase.productID}');
      }

      // TODO: 서버에 프리미엄 상태 저장
    }
  }

  /// 구매 오류 처리
  void _handlePurchaseError(PurchaseDetails purchase) {
    if (kDebugMode) {
      print('[PurchaseService] 구매 오류: ${purchase.error?.message}');
    }
  }

  /// 구매 대기 UI 표시
  void _showPendingUI() {
    if (kDebugMode) {
      print('[PurchaseService] 구매 처리 중...');
    }
  }

  /// 구매 완료 콜백
  void _onPurchaseDone() {
    if (kDebugMode) {
      print('[PurchaseService] 구매 스트림 종료');
    }
  }

  /// 구매 오류 콜백
  void _onPurchaseError(dynamic error) {
    if (kDebugMode) {
      print('[PurchaseService] 구매 스트림 오류: $error');
    }
  }

  /// 상품 구매
  Future<bool> buyProduct(String productId) async {
    try {
      final product = _products.firstWhere(
        (p) => p.id == productId,
        orElse: () => throw Exception('상품을 찾을 수 없습니다: $productId'),
      );

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
      );

      bool success;
      if (productId == premiumMonthly || productId == premiumYearly) {
        // 구독 상품
        success = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        // 일회성 상품 (광고 제거)
        success = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      }

      if (kDebugMode) {
        print('[PurchaseService] 구매 요청: $productId - ${success ? "성공" : "실패"}');
      }

      return success;
    } catch (e) {
      if (kDebugMode) {
        print('[PurchaseService] 구매 실패: $e');
      }
      return false;
    }
  }

  /// 프리미엄 여부
  bool get isPremium => _isPremium;

  /// 사용 가능한 상품 목록
  List<ProductDetails> get products => _products;

  /// 월간 구독 상품
  ProductDetails? get premiumMonthlyProduct {
    try {
      return _products.firstWhere((p) => p.id == premiumMonthly);
    } catch (e) {
      return null;
    }
  }

  /// 연간 구독 상품
  ProductDetails? get premiumYearlyProduct {
    try {
      return _products.firstWhere((p) => p.id == premiumYearly);
    } catch (e) {
      return null;
    }
  }

  /// 광고 제거 상품
  ProductDetails? get removeAdsProduct {
    try {
      return _products.firstWhere((p) => p.id == removeAds);
    } catch (e) {
      return null;
    }
  }

  /// 리소스 정리
  void dispose() {
    _subscription?.cancel();
  }
}
