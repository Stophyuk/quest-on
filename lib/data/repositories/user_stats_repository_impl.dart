import 'package:quest_on/domain/entities/user_stats.dart';
import 'package:quest_on/domain/repositories/user_stats_repository.dart';
import 'package:quest_on/data/datasources/remote/user_stats_remote_datasource.dart';
import 'package:quest_on/data/models/user_stats_model.dart';

/// 사용자 통계 Repository 구현
class UserStatsRepositoryImpl implements UserStatsRepository {
  final UserStatsRemoteDataSource _remoteDataSource;

  UserStatsRepositoryImpl({
    required UserStatsRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<UserStats?> getUserStats(String userId) async {
    try {
      return await _remoteDataSource.getUserStats(userId);
    } catch (e) {
      throw Exception('사용자 통계 조회 실패: $e');
    }
  }

  @override
  Future<UserStats> createUserStats(String userId) async {
    try {
      final stats = UserStatsModel.initial(userId, 'Player', '🐰');
      return await _remoteDataSource.createUserStats(stats);
    } catch (e) {
      throw Exception('사용자 통계 생성 실패: $e');
    }
  }

  @override
  Future<UserStats> createUserStatsWithProfile({
    required String userId,
    required String nickname,
    required String character,
  }) async {
    try {
      final stats = UserStatsModel.initial(userId, nickname, character);
      return await _remoteDataSource.createUserStats(stats);
    } catch (e) {
      throw Exception('사용자 통계 생성 실패: $e');
    }
  }

  @override
  Future<UserStats> addExp({
    required String userId,
    required int expToAdd,
  }) async {
    try {
      // 현재 통계 조회
      UserStatsModel stats = await _remoteDataSource.getUserStats(userId) ??
          await createUserStats(userId) as UserStatsModel;

      // 경험치 추가
      final updatedStats = stats.addExp(expToAdd);

      // 업데이트
      await _remoteDataSource.updateUserStats(updatedStats);

      return updatedStats;
    } catch (e) {
      throw Exception('경험치 추가 실패: $e');
    }
  }

  @override
  Future<void> updateUserStats(UserStats stats) async {
    try {
      final statsModel = stats is UserStatsModel
          ? stats
          : UserStatsModel.fromEntity(stats);

      await _remoteDataSource.updateUserStats(statsModel);
    } catch (e) {
      throw Exception('사용자 통계 업데이트 실패: $e');
    }
  }

  @override
  Stream<UserStats?> watchUserStats(String userId) {
    try {
      return _remoteDataSource.watchUserStats(userId);
    } catch (e) {
      throw Exception('사용자 통계 스트림 생성 실패: $e');
    }
  }
}
