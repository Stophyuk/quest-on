import 'package:quest_on/domain/entities/quest.dart';
import 'package:quest_on/domain/repositories/quest_repository.dart';
import 'package:quest_on/data/datasources/remote/quest_remote_datasource.dart';
import 'package:quest_on/data/models/quest_model.dart';

/// 퀘스트 Repository 구현
class QuestRepositoryImpl implements QuestRepository {
  final QuestRemoteDataSource _remoteDataSource;

  QuestRepositoryImpl({
    required QuestRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Quest> createQuest({
    required String userId,
    required String title,
    String? description,
    required QuestCategory category,
    required QuestDifficulty difficulty,
    required QuestCondition targetCondition,
    required int targetCount,
  }) async {
    try {
      // 난이도에 따른 경험치 계산
      final expReward = difficulty.calculateExp(targetCount);

      final quest = QuestModel(
        id: '', // Supabase에서 자동 생성
        userId: userId,
        title: title,
        description: description,
        category: category,
        difficulty: difficulty,
        targetCondition: targetCondition,
        targetCount: targetCount,
        currentCount: 0,
        isCompleted: false,
        expReward: expReward,
        createdAt: DateTime.now(),
      );

      return await _remoteDataSource.createQuest(quest);
    } catch (e) {
      throw Exception('퀘스트 생성 실패: $e');
    }
  }

  @override
  Future<Quest?> getQuest(String questId) async {
    try {
      return await _remoteDataSource.getQuest(questId);
    } catch (e) {
      throw Exception('퀘스트 조회 실패: $e');
    }
  }

  @override
  Future<List<Quest>> getActiveQuests(String userId) async {
    try {
      return await _remoteDataSource.getActiveQuests(userId);
    } catch (e) {
      throw Exception('활성 퀘스트 조회 실패: $e');
    }
  }

  @override
  Future<List<Quest>> getCompletedQuests(String userId) async {
    try {
      return await _remoteDataSource.getCompletedQuests(userId);
    } catch (e) {
      throw Exception('완료된 퀘스트 조회 실패: $e');
    }
  }

  @override
  Future<List<Quest>> getAllQuests(String userId) async {
    try {
      return await _remoteDataSource.getAllQuests(userId);
    } catch (e) {
      throw Exception('퀘스트 조회 실패: $e');
    }
  }

  @override
  Future<void> updateQuest(Quest quest) async {
    try {
      final questModel = quest is QuestModel
          ? quest
          : QuestModel(
              id: quest.id,
              userId: quest.userId,
              title: quest.title,
              description: quest.description,
              category: quest.category,
              difficulty: quest.difficulty,
              targetCondition: quest.targetCondition,
              targetCount: quest.targetCount,
              currentCount: quest.currentCount,
              isCompleted: quest.isCompleted,
              expReward: quest.expReward,
              createdAt: quest.createdAt,
              completedAt: quest.completedAt,
              deletedAt: quest.deletedAt,
            );

      await _remoteDataSource.updateQuest(questModel);
    } catch (e) {
      throw Exception('퀘스트 업데이트 실패: $e');
    }
  }

  @override
  Future<Quest> incrementQuestProgress(String questId) async {
    try {
      final quest = await _remoteDataSource.getQuest(questId);
      if (quest == null) {
        throw Exception('퀘스트를 찾을 수 없습니다');
      }

      final updatedQuest = quest.incrementProgress();
      await _remoteDataSource.updateQuest(updatedQuest);

      return updatedQuest;
    } catch (e) {
      throw Exception('퀘스트 진행 업데이트 실패: $e');
    }
  }

  @override
  Future<Quest> adjustQuestTarget({
    required String questId,
    required QuestCondition newCondition,
  }) async {
    try {
      final quest = await _remoteDataSource.getQuest(questId);
      if (quest == null) {
        throw Exception('퀘스트를 찾을 수 없습니다');
      }

      final adjustedQuest = quest.adjustTargetByCondition(newCondition);
      await _remoteDataSource.updateQuest(adjustedQuest);

      return adjustedQuest;
    } catch (e) {
      throw Exception('퀘스트 목표 조정 실패: $e');
    }
  }

  @override
  Future<Quest> completeQuest(String questId) async {
    try {
      final quest = await _remoteDataSource.getQuest(questId);
      if (quest == null) {
        throw Exception('퀘스트를 찾을 수 없습니다');
      }

      final completedQuest = QuestModel(
        id: quest.id,
        userId: quest.userId,
        title: quest.title,
        description: quest.description,
        category: quest.category,
        difficulty: quest.difficulty,
        targetCondition: quest.targetCondition,
        targetCount: quest.targetCount,
        currentCount: quest.targetCount, // 목표 달성
        isCompleted: true,
        expReward: quest.expReward,
        createdAt: quest.createdAt,
        completedAt: DateTime.now(),
        deletedAt: quest.deletedAt,
      );

      await _remoteDataSource.updateQuest(completedQuest);

      return completedQuest;
    } catch (e) {
      throw Exception('퀘스트 완료 처리 실패: $e');
    }
  }

  @override
  Future<void> deleteQuest(String questId) async {
    try {
      await _remoteDataSource.deleteQuest(questId);
    } catch (e) {
      throw Exception('퀘스트 삭제 실패: $e');
    }
  }

  @override
  Stream<List<Quest>> watchActiveQuests(String userId) {
    try {
      return _remoteDataSource.watchActiveQuests(userId);
    } catch (e) {
      throw Exception('퀘스트 스트림 생성 실패: $e');
    }
  }

  @override
  Future<int> getTodayCompletedCount(String userId) async {
    try {
      return await _remoteDataSource.getTodayCompletedCount(userId);
    } catch (e) {
      throw Exception('오늘 완료 통계 조회 실패: $e');
    }
  }

  @override
  Future<Map<String, int>> getWeeklyStats(String userId) async {
    try {
      return await _remoteDataSource.getWeeklyStats(userId);
    } catch (e) {
      throw Exception('주간 통계 조회 실패: $e');
    }
  }
}
