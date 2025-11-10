import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quest_on/data/models/reflection_model.dart';
import 'package:quest_on/domain/entities/reflection.dart';

/// Reflection 데이터 저장소
class ReflectionRepository {
  final SupabaseClient _supabase;

  ReflectionRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// 특정 기간의 Reflection 가져오기
  Future<Reflection?> getReflection({
    required ReflectionType type,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('reflections')
          .select()
          .eq('user_id', userId)
          .eq('type', type.name)
          .gte('start_date', startDate.toIso8601String())
          .lte('end_date', endDate.toIso8601String())
          .maybeSingle();

      if (response == null) return null;

      return ReflectionModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Failed to fetch reflection: $e');
    }
  }

  /// 모든 Reflection 목록 가져오기
  Future<List<Reflection>> getReflections({
    ReflectionType? type,
    int limit = 10,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      var query = _supabase
          .from('reflections')
          .select()
          .eq('user_id', userId);

      if (type != null) {
        query = query.eq('type', type.name);
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => ReflectionModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch reflections: $e');
    }
  }

  /// Reflection 생성
  Future<Reflection> createReflection({
    required ReflectionType type,
    required DateTime startDate,
    required DateTime endDate,
    required int totalQuests,
    required int completedQuests,
    String? userThoughts,
    String? aiCoachingMessage,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final model = ReflectionModel(
        id: '',
        userId: userId,
        type: type,
        startDate: startDate,
        endDate: endDate,
        totalQuests: totalQuests,
        completedQuests: completedQuests,
        userThoughts: userThoughts,
        aiCoachingMessage: aiCoachingMessage,
        createdAt: DateTime.now(),
      );

      final response = await _supabase
          .from('reflections')
          .insert(model.toInsertJson())
          .select()
          .single();

      return ReflectionModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Failed to create reflection: $e');
    }
  }

  /// Reflection 수정 (사용자의 생각과 AI 코칭 메시지만 수정 가능)
  Future<Reflection> updateReflection({
    required String id,
    String? userThoughts,
    String? aiCoachingMessage,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final model = ReflectionModel(
        id: id,
        userId: userId,
        type: ReflectionType.weekly,
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        totalQuests: 0,
        completedQuests: 0,
        userThoughts: userThoughts,
        aiCoachingMessage: aiCoachingMessage,
        createdAt: DateTime.now(),
      );

      final response = await _supabase
          .from('reflections')
          .update(model.toUpdateJson())
          .eq('id', id)
          .eq('user_id', userId)
          .select()
          .single();

      return ReflectionModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Failed to update reflection: $e');
    }
  }

  /// Reflection 삭제
  Future<void> deleteReflection(String id) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from('reflections')
          .delete()
          .eq('id', id)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to delete reflection: $e');
    }
  }

  /// 최근 Reflection 가져오기
  Future<Reflection?> getLatestReflection() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('reflections')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;

      return ReflectionModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Failed to fetch latest reflection: $e');
    }
  }
}
