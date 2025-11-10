import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Firebase Analytics 서비스
///
/// 앱의 모든 분석 이벤트를 관리합니다.
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  FirebaseAnalytics? _analytics;
  FirebaseAnalyticsObserver? _observer;

  /// Analytics 초기화
  Future<void> initialize() async {
    try {
      _analytics = FirebaseAnalytics.instance;
      _observer = FirebaseAnalyticsObserver(analytics: _analytics!);

      if (kDebugMode) {
        print('[Analytics] Firebase Analytics 초기화 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[Analytics] 초기화 실패: $e');
      }
    }
  }

  /// Analytics Observer (GoRouter용)
  FirebaseAnalyticsObserver? get observer => _observer;

  /// 화면 조회 이벤트
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics?.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );

      if (kDebugMode) {
        print('[Analytics] 화면 조회: $screenName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[Analytics] 화면 조회 로그 실패: $e');
      }
    }
  }

  /// 퀘스트 완료 이벤트
  Future<void> logQuestCompleted({
    required String questId,
    required String questTitle,
    required int difficulty,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'quest_completed',
        parameters: {
          'quest_id': questId,
          'quest_title': questTitle,
          'difficulty': difficulty,
        },
      );

      if (kDebugMode) {
        print('[Analytics] 퀘스트 완료: $questTitle');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[Analytics] 퀘스트 완료 로그 실패: $e');
      }
    }
  }

  /// 레벨업 이벤트
  Future<void> logLevelUp({
    required int level,
    required int totalExp,
  }) async {
    try {
      await _analytics?.logLevelUp(
        level: level,
        character: 'user',
      );

      await _analytics?.logEvent(
        name: 'level_up_detail',
        parameters: {
          'level': level,
          'total_exp': totalExp,
        },
      );

      if (kDebugMode) {
        print('[Analytics] 레벨업: Lv.$level (EXP: $totalExp)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[Analytics] 레벨업 로그 실패: $e');
      }
    }
  }

  /// 로그인 이벤트
  Future<void> logLogin({required String loginMethod}) async {
    try {
      await _analytics?.logLogin(loginMethod: loginMethod);

      if (kDebugMode) {
        print('[Analytics] 로그인: $loginMethod');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[Analytics] 로그인 로그 실패: $e');
      }
    }
  }

  /// 회원가입 이벤트
  Future<void> logSignUp({required String signUpMethod}) async {
    try {
      await _analytics?.logSignUp(signUpMethod: signUpMethod);

      if (kDebugMode) {
        print('[Analytics] 회원가입: $signUpMethod');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[Analytics] 회원가입 로그 실패: $e');
      }
    }
  }

  /// 퀘스트 생성 이벤트
  Future<void> logQuestCreated({
    required String questTitle,
    required int difficulty,
    bool isAIGenerated = false,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'quest_created',
        parameters: {
          'quest_title': questTitle,
          'difficulty': difficulty,
          'is_ai_generated': isAIGenerated,
        },
      );

      if (kDebugMode) {
        print('[Analytics] 퀘스트 생성: $questTitle (AI: $isAIGenerated)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[Analytics] 퀘스트 생성 로그 실패: $e');
      }
    }
  }

  /// 악세서리 구매 이벤트
  Future<void> logAccessoryPurchased({
    required String itemId,
    required String itemName,
    required int cost,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'accessory_purchased',
        parameters: {
          'item_id': itemId,
          'item_name': itemName,
          'cost': cost,
          'currency': 'gold',
        },
      );

      if (kDebugMode) {
        print('[Analytics] 악세서리 구매: $itemName ($cost 골드)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[Analytics] 악세서리 구매 로그 실패: $e');
      }
    }
  }

  /// 온보딩 완료 이벤트
  Future<void> logOnboardingCompleted() async {
    try {
      await _analytics?.logTutorialComplete();

      if (kDebugMode) {
        print('[Analytics] 온보딩 완료');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[Analytics] 온보딩 완료 로그 실패: $e');
      }
    }
  }

  /// 컨디션 설정 이벤트
  Future<void> logConditionSet({
    required String conditionType,
    required int value,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'condition_set',
        parameters: {
          'condition_type': conditionType,
          'value': value,
        },
      );

      if (kDebugMode) {
        print('[Analytics] 컨디션 설정: $conditionType = $value');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[Analytics] 컨디션 설정 로그 실패: $e');
      }
    }
  }

  /// 주간 리포트 조회 이벤트
  Future<void> logWeeklyReportViewed({
    required int weekNumber,
    required double achievementRate,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'weekly_report_viewed',
        parameters: {
          'week_number': weekNumber,
          'achievement_rate': achievementRate,
        },
      );

      if (kDebugMode) {
        print('[Analytics] 주간 리포트 조회: Week $weekNumber ($achievementRate%)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[Analytics] 주간 리포트 조회 로그 실패: $e');
      }
    }
  }

  /// 에러 이벤트
  Future<void> logError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'app_error',
        parameters: {
          'error_type': errorType,
          'error_message': errorMessage,
          if (stackTrace != null) 'stack_trace': stackTrace,
        },
      );

      if (kDebugMode) {
        print('[Analytics] 에러 발생: $errorType - $errorMessage');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[Analytics] 에러 로그 실패: $e');
      }
    }
  }

  /// 사용자 속성 설정
  Future<void> setUserProperties({
    required String userId,
    int? userLevel,
    int? totalQuests,
  }) async {
    try {
      await _analytics?.setUserId(id: userId);

      if (userLevel != null) {
        await _analytics?.setUserProperty(
          name: 'user_level',
          value: userLevel.toString(),
        );
      }

      if (totalQuests != null) {
        await _analytics?.setUserProperty(
          name: 'total_quests',
          value: totalQuests.toString(),
        );
      }

      if (kDebugMode) {
        print('[Analytics] 사용자 속성 설정: $userId (Lv.$userLevel, $totalQuests quests)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[Analytics] 사용자 속성 설정 실패: $e');
      }
    }
  }

  /// 커스텀 이벤트
  Future<void> logCustomEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics?.logEvent(
        name: eventName,
        parameters: parameters,
      );

      if (kDebugMode) {
        print('[Analytics] 커스텀 이벤트: $eventName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[Analytics] 커스텀 이벤트 로그 실패: $e');
      }
    }
  }
}
