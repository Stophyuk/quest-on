import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_on/domain/entities/user_stats.dart';
import 'package:quest_on/domain/repositories/user_stats_repository.dart';
import 'package:quest_on/data/datasources/remote/user_stats_remote_datasource.dart';
import 'package:quest_on/data/repositories/user_stats_repository_impl.dart';

/// UserStats Remote DataSource Provider
final userStatsRemoteDataSourceProvider =
    Provider<UserStatsRemoteDataSource>((ref) {
  return UserStatsRemoteDataSource();
});

/// UserStats Repository Provider
final userStatsRepositoryProvider = Provider<UserStatsRepository>((ref) {
  return UserStatsRepositoryImpl(
    remoteDataSource: ref.read(userStatsRemoteDataSourceProvider),
  );
});

/// 사용자 통계 스트림 Provider
final userStatsStreamProvider =
    StreamProvider.family<UserStats?, String>((ref, userId) {
  final repository = ref.watch(userStatsRepositoryProvider);
  return repository.watchUserStats(userId);
});

/// 사용자 통계 Provider (비동기)
final userStatsProvider =
    FutureProvider.family<UserStats?, String>((ref, userId) async {
  final repository = ref.watch(userStatsRepositoryProvider);
  return repository.getUserStats(userId);
});

/// UserStats Notifier (상태 관리)
class UserStatsNotifier extends StateNotifier<AsyncValue<UserStats?>> {
  final UserStatsRepository _repository;
  String? _currentUserId;

  UserStatsNotifier(this._repository) : super(const AsyncValue.loading());

  /// 사용자 통계 로드
  Future<void> loadUserStats(String userId) async {
    _currentUserId = userId;
    state = const AsyncValue.loading();

    try {
      // 통계 조회, 없으면 생성
      final stats = await _repository.getUserStats(userId) ??
          await _repository.createUserStats(userId);

      state = AsyncValue.data(stats);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 경험치 추가
  Future<UserStats> addExp(int expToAdd) async {
    if (_currentUserId == null) {
      throw Exception('사용자 ID가 설정되지 않았습니다');
    }

    try {
      final oldStats = state.value;
      final newStats = await _repository.addExp(
        userId: _currentUserId!,
        expToAdd: expToAdd,
      );

      // 상태 업데이트
      state = AsyncValue.data(newStats);

      // 레벨업 체크
      if (oldStats != null && oldStats.isLevelUp(newStats)) {
        // 레벨업 발생!
        return newStats;
      }

      return newStats;
    } catch (e) {
      rethrow;
    }
  }

  /// 현재 레벨
  int get currentLevel {
    return state.value?.level ?? 1;
  }

  /// 다음 레벨까지 필요한 경험치
  int get expToNextLevel {
    return state.value?.expToNextLevel ?? 100;
  }

  /// 현재 레벨 진행률
  double get levelProgress {
    return state.value?.levelProgress ?? 0.0;
  }

  /// 레벨 타이틀
  String get levelTitle {
    return state.value?.levelTitle ?? '초보 모험가';
  }
}

/// UserStats Notifier Provider
final userStatsNotifierProvider =
    StateNotifierProvider<UserStatsNotifier, AsyncValue<UserStats?>>((ref) {
  return UserStatsNotifier(ref.read(userStatsRepositoryProvider));
});
