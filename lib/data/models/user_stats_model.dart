import 'package:quest_on/domain/entities/user_stats.dart';

/// 사용자 통계 데이터 모델
class UserStatsModel extends UserStats {
  const UserStatsModel({
    required super.userId,
    required super.level,
    required super.currentExp,
    required super.totalExp,
    required super.updatedAt,
  });

  /// Supabase JSON에서 모델 생성
  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      userId: json['user_id'] as String,
      level: json['level'] as int? ?? 1,
      currentExp: json['current_exp'] as int? ?? 0,
      totalExp: json['total_exp'] as int? ?? 0,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  /// 모델을 JSON으로 변환 (INSERT/UPDATE용)
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'level': level,
      'current_exp': currentExp,
      'total_exp': totalExp,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 초기 UserStats 생성 (레벨 1, 경험치 0)
  factory UserStatsModel.initial(String userId) {
    return UserStatsModel(
      userId: userId,
      level: 1,
      currentExp: 0,
      totalExp: 0,
      updatedAt: DateTime.now(),
    );
  }

  /// UserStats 엔티티를 모델로 변환
  factory UserStatsModel.fromEntity(UserStats stats) {
    return UserStatsModel(
      userId: stats.userId,
      level: stats.level,
      currentExp: stats.currentExp,
      totalExp: stats.totalExp,
      updatedAt: stats.updatedAt,
    );
  }

  /// 엔티티로 변환
  UserStats toEntity() {
    return UserStats(
      userId: userId,
      level: level,
      currentExp: currentExp,
      totalExp: totalExp,
      updatedAt: updatedAt,
    );
  }

  /// 경험치 추가 후 새로운 모델 반환
  @override
  UserStatsModel addExp(int expToAdd) {
    final newStats = super.addExp(expToAdd);
    return UserStatsModel.fromEntity(newStats);
  }
}
