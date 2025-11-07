import 'package:supabase_flutter/supabase_flutter.dart';

/// AI 기능 Remote Data Source
class AiRemoteDataSource {
  final SupabaseClient _supabaseClient;

  AiRemoteDataSource([SupabaseClient? supabaseClient])
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  /// AI 퀘스트 추천 받기
  Future<Map<String, dynamic>> getSuggestedQuests({
    required String currentWeekGoal,
    String? condition,
  }) async {
    try {
      print('🤖 AI 퀘스트 추천 요청 중...');
      print('  - 주차 목표: $currentWeekGoal');
      print('  - 컨디션: ${condition ?? "보통"}');

      final response = await _supabaseClient.functions.invoke(
        'suggest-quests',
        body: {
          'currentWeekGoal': currentWeekGoal,
          'condition': condition ?? '보통',
        },
      );

      if (response.status != 200) {
        throw Exception('AI 추천 실패: ${response.status}');
      }

      final data = response.data as Map<String, dynamic>;
      print('✅ AI 추천 완료: ${data['suggestions']?.length ?? 0}개 퀘스트');

      return data;
    } catch (e) {
      print('❌ AI 추천 에러: $e');
      rethrow;
    }
  }
}
