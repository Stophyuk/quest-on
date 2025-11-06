/// 퀘스트 엔티티
class Quest {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final QuestCategory category;
  final QuestDifficulty difficulty;
  final QuestCondition targetCondition; // 목표 컨디션
  final int targetCount; // 목표 횟수
  final int currentCount; // 현재 달성 횟수
  final bool isCompleted;
  final int expReward; // 완료 시 경험치 보상
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? deletedAt;

  const Quest({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.category,
    required this.difficulty,
    required this.targetCondition,
    required this.targetCount,
    this.currentCount = 0,
    this.isCompleted = false,
    required this.expReward,
    required this.createdAt,
    this.completedAt,
    this.deletedAt,
  });

  /// 진행률 계산 (0.0 ~ 1.0)
  double get progress {
    if (targetCount == 0) return 0.0;
    return (currentCount / targetCount).clamp(0.0, 1.0);
  }

  /// 진행률 퍼센트 (0 ~ 100)
  int get progressPercent {
    return (progress * 100).round();
  }

  /// 남은 횟수
  int get remainingCount {
    return (targetCount - currentCount).clamp(0, targetCount);
  }

  /// 활성 상태인지 (삭제되지 않고 완료되지 않은 상태)
  bool get isActive {
    return deletedAt == null && !isCompleted;
  }
}

/// 퀘스트 카테고리
enum QuestCategory {
  health('건강', '💪'),
  study('공부', '📚'),
  work('업무', '💼'),
  hobby('취미', '🎨'),
  relationship('관계', '👥'),
  growth('성장', '🌱'),
  other('기타', '📌');

  final String label;
  final String emoji;

  const QuestCategory(this.label, this.emoji);
}

/// 퀘스트 난이도
enum QuestDifficulty {
  easy('쉬움', 1, 10),
  normal('보통', 2, 20),
  hard('어려움', 3, 30),
  veryHard('매우 어려움', 4, 50);

  final String label;
  final int level;
  final int baseExp; // 기본 경험치

  const QuestDifficulty(this.label, this.level, this.baseExp);

  /// 난이도에 따른 경험치 계산
  int calculateExp(int targetCount) {
    return baseExp * targetCount;
  }
}

/// 컨디션 (목표 조정 기준)
enum QuestCondition {
  veryBad('최악', 0.3), // 목표의 30%
  bad('나쁨', 0.5), // 목표의 50%
  normal('보통', 0.7), // 목표의 70%
  good('좋음', 1.0), // 목표의 100%
  veryGood('최고', 1.2); // 목표의 120%

  final String label;
  final double multiplier; // 목표 조정 배수

  const QuestCondition(this.label, this.multiplier);

  /// 컨디션에 따른 조정된 목표 계산
  int adjustTarget(int baseTarget) {
    return (baseTarget * multiplier).round().clamp(1, baseTarget * 2);
  }
}
