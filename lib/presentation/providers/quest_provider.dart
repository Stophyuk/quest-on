import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_on/domain/entities/quest.dart';
import 'package:quest_on/domain/repositories/quest_repository.dart';
import 'package:quest_on/data/datasources/remote/quest_remote_datasource.dart';
import 'package:quest_on/data/repositories/quest_repository_impl.dart';
import 'package:quest_on/presentation/providers/user_stats_provider.dart';
import 'package:quest_on/data/services/quest_widget_service.dart';

/// Quest Remote DataSource Provider
final questRemoteDataSourceProvider = Provider<QuestRemoteDataSource>((ref) {
  return QuestRemoteDataSource();
});

/// Quest Repository Provider
final questRepositoryProvider = Provider<QuestRepository>((ref) {
  return QuestRepositoryImpl(
    remoteDataSource: ref.read(questRemoteDataSourceProvider),
  );
});

/// 활성 퀘스트 스트림 Provider
final activeQuestsStreamProvider =
    StreamProvider.family<List<Quest>, String>((ref, userId) {
  final repository = ref.watch(questRepositoryProvider);
  return repository.watchActiveQuests(userId);
});

/// 활성 퀘스트 Provider (비동기)
final activeQuestsProvider =
    FutureProvider.family<List<Quest>, String>((ref, userId) async {
  final repository = ref.watch(questRepositoryProvider);
  return repository.getActiveQuests(userId);
});

/// 완료된 퀘스트 Provider
final completedQuestsProvider =
    FutureProvider.family<List<Quest>, String>((ref, userId) async {
  final repository = ref.watch(questRepositoryProvider);
  return repository.getCompletedQuests(userId);
});

/// 오늘 완료한 퀘스트 수 Provider
final todayCompletedCountProvider =
    FutureProvider.family<int, String>((ref, userId) async {
  final repository = ref.watch(questRepositoryProvider);
  return repository.getTodayCompletedCount(userId);
});

/// 주간 통계 Provider
final weeklyStatsProvider =
    FutureProvider.family<Map<String, int>, String>((ref, userId) async {
  final repository = ref.watch(questRepositoryProvider);
  return repository.getWeeklyStats(userId);
});

/// Quest Notifier (상태 관리)
class QuestNotifier extends StateNotifier<AsyncValue<List<Quest>>> {
  final QuestRepository _repository;
  final Ref _ref;
  String? _currentUserId;

  QuestNotifier(this._repository, this._ref) : super(const AsyncValue.loading());

  /// 사용자 퀘스트 로드
  Future<void> loadQuests(String userId) async {
    _currentUserId = userId;
    state = const AsyncValue.loading();

    try {
      final quests = await _repository.getActiveQuests(userId);
      state = AsyncValue.data(quests);

      // 위젯 업데이트
      await _updateWidget(quests);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 위젯 업데이트 헬퍼 메서드
  Future<void> _updateWidget(List<Quest> quests) async {
    try {
      await QuestWidgetService.updateTodayQuests(quests);
    } catch (e) {
      // 위젯 업데이트 실패는 조용히 처리 (앱 기능에 영향 없음)
      print('위젯 업데이트 실패: $e');
    }
  }

  /// 퀘스트 생성
  Future<Quest> createQuest({
    required String userId,
    required String title,
    String? description,
    required QuestCategory category,
    required QuestDifficulty difficulty,
    required int targetCount,
  }) async {
    try {
      final quest = await _repository.createQuest(
        userId: userId,
        title: title,
        description: description,
        category: category,
        difficulty: difficulty,
        targetCount: targetCount,
      );

      // 상태 갱신
      await loadQuests(userId);

      return quest;
    } catch (e) {
      rethrow;
    }
  }

  /// 퀘스트 업데이트
  Future<void> updateQuest(Quest quest) async {
    try {
      await _repository.updateQuest(quest);

      // 상태 갱신
      if (_currentUserId != null) {
        await loadQuests(_currentUserId!);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 퀘스트 진행 (+1)
  Future<Quest> incrementQuestProgress(String questId) async {
    try {
      final updatedQuest = await _repository.incrementQuestProgress(questId);

      // 퀘스트 완료 시 경험치 보상
      if (updatedQuest.isCompleted) {
        await _ref
            .read(userStatsNotifierProvider.notifier)
            .addExp(updatedQuest.expReward);
      }

      // 상태 갱신
      if (_currentUserId != null) {
        await loadQuests(_currentUserId!);
      }

      return updatedQuest;
    } catch (e) {
      rethrow;
    }
  }

  /// 퀘스트 완료
  Future<Quest> completeQuest(String questId) async {
    try {
      // 완료 전 퀘스트 상태 확인
      final quests = state.value ?? [];
      final questBefore = quests.firstWhere((q) => q.id == questId);
      final wasAlreadyCompleted = questBefore.isCompleted;

      final completedQuest = await _repository.completeQuest(questId);

      // 이미 완료된 퀘스트가 아닐 때만 경험치 지급 (이중 지급 방지)
      if (!wasAlreadyCompleted && completedQuest.isCompleted) {
        final expToAdd = completedQuest.difficulty.baseExp;
        try {
          await _ref.read(userStatsNotifierProvider.notifier).addExp(expToAdd);
          print('✅ 퀘스트 완료 - 경험치 +$expToAdd (난이도: ${completedQuest.difficulty.label})');
        } catch (e) {
          print('❌ 경험치 추가 실패: $e');
          // 경험치 추가 실패해도 퀘스트 완료는 유지
        }
      }

      // 상태 갱신
      if (_currentUserId != null) {
        await loadQuests(_currentUserId!);
      }

      return completedQuest;
    } catch (e) {
      rethrow;
    }
  }

  /// 퀘스트 삭제
  Future<void> deleteQuest(String questId) async {
    try {
      await _repository.deleteQuest(questId);

      // 상태 갱신
      if (_currentUserId != null) {
        await loadQuests(_currentUserId!);
      }
    } catch (e) {
      rethrow;
    }
  }
}

/// Quest Notifier Provider
final questNotifierProvider =
    StateNotifierProvider<QuestNotifier, AsyncValue<List<Quest>>>((ref) {
  return QuestNotifier(ref.read(questRepositoryProvider), ref);
});
