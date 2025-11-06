/// Quest ON 앱 전역 상수
class AppConstants {
  // 앱 정보
  static const String appName = 'Quest ON';
  static const String appVersion = '1.0.0';

  // 컨디션 레벨
  static const int conditionBest = 1; // 최상
  static const int conditionGood = 2; // 좋음
  static const int conditionNormal = 3; // 보통
  static const int conditionBad = 4; // 나쁨
  static const int conditionWorst = 5; // 최악

  static const Map<int, String> conditionLabels = {
    1: '최상',
    2: '좋음',
    3: '보통',
    4: '나쁨',
    5: '최악',
  };

  static const Map<int, String> conditionEmojis = {
    1: '😄',
    2: '🙂',
    3: '😐',
    4: '😔',
    5: '😫',
  };

  // 퀘스트 카테고리
  static const String categoryHealth = '건강';
  static const String categoryStudy = '학습';
  static const String categoryWork = '업무';
  static const String categoryHobby = '취미';
  static const String categoryRelationship = '관계';
  static const String categoryOther = '기타';

  static const List<String> categories = [
    categoryHealth,
    categoryStudy,
    categoryWork,
    categoryHobby,
    categoryRelationship,
    categoryOther,
  ];

  // 경험치 및 레벨
  static const int baseExp = 10; // 기본 경험치
  static const int expPerLevel = 100; // 레벨당 필요 경험치
  static const int maxLevel = 100; // 최대 레벨

  // 포인트 시스템
  static const int pointsPerQuest = 10; // 퀘스트 완료 시 포인트
  static const int pointsPerStreak = 5; // 연속 달성 보너스 포인트

  // UI 상수
  static const double borderRadius = 12.0;
  static const double spacing = 16.0;
  static const double cardElevation = 2.0;

  // 알림 설정
  static const int dailyReminderHour = 9; // 오전 9시
  static const int eveningReminderHour = 20; // 오후 8시

  // 로컬 저장소 키
  static const String keyUser = 'user';
  static const String keyQuests = 'quests';
  static const String keyProfile = 'profile';
  static const String keyTheme = 'theme';
  static const String keyNotifications = 'notifications';

  // 광고 ID (테스트)
  static const String adBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String adInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String adRewardedId = 'ca-app-pub-3940256099942544/5224354917';

  // 구독 상품 ID
  static const String subscriptionPlusMonthly = 'quest_on_plus_monthly';
  static const String subscriptionProMonthly = 'quest_on_pro_monthly';
}
