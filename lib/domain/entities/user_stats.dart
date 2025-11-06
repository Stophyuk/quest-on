/// 사용자 통계 (레벨, 경험치)
class UserStats {
  final String userId;
  final int level;
  final int currentExp; // 현재 레벨에서의 경험치
  final int totalExp; // 누적 총 경험치
  final DateTime updatedAt;

  const UserStats({
    required this.userId,
    required this.level,
    required this.currentExp,
    required this.totalExp,
    required this.updatedAt,
  });

  /// 다음 레벨까지 필요한 경험치
  int get expToNextLevel {
    return _calculateExpForLevel(level + 1) - totalExp;
  }

  /// 현재 레벨에서의 진행률 (0.0 ~ 1.0)
  double get levelProgress {
    final currentLevelTotalExp = _calculateExpForLevel(level);
    final nextLevelTotalExp = _calculateExpForLevel(level + 1);
    final expInCurrentLevel = totalExp - currentLevelTotalExp;
    final expNeededForLevel = nextLevelTotalExp - currentLevelTotalExp;

    if (expNeededForLevel == 0) return 1.0;

    return (expInCurrentLevel / expNeededForLevel).clamp(0.0, 1.0);
  }

  /// 레벨별 필요 총 경험치 계산
  ///
  /// 레벨 1: 0 EXP
  /// 레벨 2: 100 EXP
  /// 레벨 3: 250 EXP (100 + 150)
  /// 레벨 4: 450 EXP (250 + 200)
  /// 레벨 5: 700 EXP (450 + 250)
  /// ...
  /// 공식: sum(50 * n) for n in 1..level-1
  static int _calculateExpForLevel(int level) {
    if (level <= 1) return 0;

    int totalExp = 0;
    for (int i = 1; i < level; i++) {
      totalExp += 50 * i; // 레벨당 필요 경험치가 50씩 증가
    }
    return totalExp;
  }

  /// 총 경험치로부터 레벨 계산
  static int calculateLevelFromTotalExp(int totalExp) {
    int level = 1;
    while (_calculateExpForLevel(level + 1) <= totalExp) {
      level++;
    }
    return level;
  }

  /// 경험치 추가 후 새로운 UserStats 반환
  UserStats addExp(int expToAdd) {
    final newTotalExp = totalExp + expToAdd;
    final newLevel = calculateLevelFromTotalExp(newTotalExp);
    final newCurrentExp = newTotalExp - _calculateExpForLevel(newLevel);

    return UserStats(
      userId: userId,
      level: newLevel,
      currentExp: newCurrentExp,
      totalExp: newTotalExp,
      updatedAt: DateTime.now(),
    );
  }

  /// 레벨업 여부 확인
  bool isLevelUp(UserStats newStats) {
    return newStats.level > level;
  }

  /// 레벨 타이틀 (표시용)
  String get levelTitle {
    if (level < 5) return '초보 모험가';
    if (level < 10) return '견습 모험가';
    if (level < 20) return '숙련 모험가';
    if (level < 30) return '베테랑 모험가';
    if (level < 50) return '마스터 모험가';
    if (level < 75) return '전설의 모험가';
    return '신화의 모험가';
  }
}
