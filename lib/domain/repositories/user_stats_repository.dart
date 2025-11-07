import 'package:quest_on/domain/entities/user_stats.dart';

/// 사용자 통계 Repository 인터페이스
abstract class UserStatsRepository {
  /// 사용자 통계 조회
  Future<UserStats?> getUserStats(String userId);

  /// 사용자 통계 생성 (초기화)
  Future<UserStats> createUserStats(String userId);

  /// 사용자 통계 생성 (온보딩용 - 닉네임/캐릭터 포함)
  Future<UserStats> createUserStatsWithProfile({
    required String userId,
    required String nickname,
    required String character,
  });

  /// 경험치 추가
  Future<UserStats> addExp({
    required String userId,
    required int expToAdd,
  });

  /// 사용자 통계 업데이트
  Future<void> updateUserStats(UserStats stats);

  /// 사용자 통계 스트림 (실시간 업데이트)
  Stream<UserStats?> watchUserStats(String userId);
}
