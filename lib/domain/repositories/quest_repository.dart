import 'package:quest_on/domain/entities/quest.dart';

/// 퀘스트 Repository 인터페이스
abstract class QuestRepository {
  /// 퀘스트 생성
  Future<Quest> createQuest({
    required String userId,
    required String title,
    String? description,
    required QuestCategory category,
    required QuestDifficulty difficulty,
    required QuestCondition targetCondition,
    required int targetCount,
  });

  /// 퀘스트 조회 (단일)
  Future<Quest?> getQuest(String questId);

  /// 사용자의 모든 활성 퀘스트 조회
  Future<List<Quest>> getActiveQuests(String userId);

  /// 사용자의 완료된 퀘스트 조회
  Future<List<Quest>> getCompletedQuests(String userId);

  /// 사용자의 모든 퀘스트 조회 (활성 + 완료)
  Future<List<Quest>> getAllQuests(String userId);

  /// 퀘스트 업데이트
  Future<void> updateQuest(Quest quest);

  /// 퀘스트 진행 (+1)
  Future<Quest> incrementQuestProgress(String questId);

  /// 컨디션 변경 시 목표 재조정
  Future<Quest> adjustQuestTarget({
    required String questId,
    required QuestCondition newCondition,
  });

  /// 퀘스트 완료 처리
  Future<Quest> completeQuest(String questId);

  /// 퀘스트 삭제 (소프트 삭제)
  Future<void> deleteQuest(String questId);

  /// 퀘스트 스트림 (실시간 업데이트)
  Stream<List<Quest>> watchActiveQuests(String userId);

  /// 오늘 완료한 퀘스트 수
  Future<int> getTodayCompletedCount(String userId);

  /// 주간 완료 통계
  Future<Map<String, int>> getWeeklyStats(String userId);
}
