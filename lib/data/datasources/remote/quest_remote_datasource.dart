import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quest_on/data/models/quest_model.dart';

/// 퀘스트 Remote DataSource
///
/// Supabase quests 테이블과 통신
class QuestRemoteDataSource {
  final SupabaseClient _supabase;

  QuestRemoteDataSource({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// 퀘스트 생성
  Future<QuestModel> createQuest(QuestModel quest) async {
    try {
      final response = await _supabase
          .from('quests')
          .insert(quest.toInsertJson())
          .select()
          .single();

      return QuestModel.fromJson(response);
    } catch (e) {
      throw Exception('퀘스트 생성 중 오류가 발생했습니다: $e');
    }
  }

  /// 퀘스트 조회 (단일)
  Future<QuestModel?> getQuest(String questId) async {
    try {
      final response = await _supabase
          .from('quests')
          .select()
          .eq('id', questId)
          .maybeSingle();

      if (response == null) return null;

      return QuestModel.fromJson(response);
    } catch (e) {
      throw Exception('퀘스트 조회 중 오류가 발생했습니다: $e');
    }
  }

  /// 사용자의 활성 퀘스트 조회 (삭제되지 않고 완료되지 않은 퀘스트)
  Future<List<QuestModel>> getActiveQuests(String userId) async {
    try {
      final response = await _supabase
          .from('quests')
          .select()
          .eq('user_id', userId)
          .eq('is_completed', false)
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => QuestModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('활성 퀘스트 조회 중 오류가 발생했습니다: $e');
    }
  }

  /// 사용자의 완료된 퀘스트 조회
  Future<List<QuestModel>> getCompletedQuests(String userId) async {
    try {
      final response = await _supabase
          .from('quests')
          .select()
          .eq('user_id', userId)
          .eq('is_completed', true)
          .isFilter('deleted_at', null)
          .order('completed_at', ascending: false);

      return (response as List)
          .map((json) => QuestModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('완료된 퀘스트 조회 중 오류가 발생했습니다: $e');
    }
  }

  /// 사용자의 모든 퀘스트 조회 (삭제되지 않은 퀘스트)
  Future<List<QuestModel>> getAllQuests(String userId) async {
    try {
      final response = await _supabase
          .from('quests')
          .select()
          .eq('user_id', userId)
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => QuestModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('퀘스트 조회 중 오류가 발생했습니다: $e');
    }
  }

  /// 퀘스트 업데이트
  Future<void> updateQuest(QuestModel quest) async {
    try {
      await _supabase
          .from('quests')
          .update(quest.toUpdateJson())
          .eq('id', quest.id);
    } catch (e) {
      throw Exception('퀘스트 업데이트 중 오류가 발생했습니다: $e');
    }
  }

  /// 퀘스트 삭제 (소프트 삭제)
  Future<void> deleteQuest(String questId) async {
    try {
      await _supabase.from('quests').update({
        'deleted_at': DateTime.now().toIso8601String(),
      }).eq('id', questId);
    } catch (e) {
      throw Exception('퀘스트 삭제 중 오류가 발생했습니다: $e');
    }
  }

  /// 활성 퀘스트 스트림 (실시간 업데이트)
  Stream<List<QuestModel>> watchActiveQuests(String userId) {
    return _supabase
        .from('quests')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((data) => data
            .where((json) =>
                json['is_completed'] == false && json['deleted_at'] == null)
            .map((json) => QuestModel.fromJson(json))
            .toList());
  }

  /// 오늘 완료한 퀘스트 수 조회
  Future<int> getTodayCompletedCount(String userId) async {
    try {
      final today = DateTime.now();
      final startOfDay =
          DateTime(today.year, today.month, today.day).toIso8601String();
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59)
          .toIso8601String();

      final response = await _supabase
          .from('quests')
          .select('id')
          .eq('user_id', userId)
          .eq('is_completed', true)
          .gte('completed_at', startOfDay)
          .lte('completed_at', endOfDay)
          .count();

      return response.count;
    } catch (e) {
      throw Exception('오늘 완료 통계 조회 중 오류가 발생했습니다: $e');
    }
  }

  /// 주간 완료 통계 (최근 7일)
  Future<Map<String, int>> getWeeklyStats(String userId) async {
    try {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));

      final response = await _supabase
          .from('quests')
          .select('completed_at')
          .eq('user_id', userId)
          .eq('is_completed', true)
          .gte('completed_at', sevenDaysAgo.toIso8601String())
          .lte('completed_at', now.toIso8601String());

      // 날짜별로 그룹화
      final Map<String, int> stats = {};
      for (final item in response as List) {
        if (item['completed_at'] != null) {
          final date = DateTime.parse(item['completed_at'] as String);
          final dateKey =
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          stats[dateKey] = (stats[dateKey] ?? 0) + 1;
        }
      }

      return stats;
    } catch (e) {
      throw Exception('주간 통계 조회 중 오류가 발생했습니다: $e');
    }
  }
}
