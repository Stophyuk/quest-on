import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quest_on/data/models/profile_model.dart';

/// 비전 Remote DataSource
///
/// Supabase profiles 테이블 및 Edge Functions와 통신
class VisionRemoteDataSource {
  final SupabaseClient _supabase;

  VisionRemoteDataSource({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// 프로필 생성
  Future<ProfileModel> createProfile({
    required String userId,
    required String name,
    required List<String> values,
    required String goal,
    required List<String> reasons,
  }) async {
    try {
      final profile = ProfileModel(
        userId: userId,
        name: name,
        values: values,
        goal: goal,
        reasons: reasons,
        createdAt: DateTime.now(),
      );

      final response = await _supabase
          .from('profiles')
          .insert(profile.toInsertJson())
          .select()
          .single();

      return ProfileModel.fromJson(response);
    } catch (e) {
      throw Exception('프로필 생성 중 오류가 발생했습니다: $e');
    }
  }

  /// 프로필 조회
  Future<ProfileModel?> getProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;

      return ProfileModel.fromJson(response);
    } catch (e) {
      throw Exception('프로필 조회 중 오류가 발생했습니다: $e');
    }
  }

  /// 프로필 업데이트
  Future<void> updateProfile(ProfileModel profile) async {
    try {
      await _supabase
          .from('profiles')
          .update(profile.toUpdateJson())
          .eq('user_id', profile.userId);
    } catch (e) {
      throw Exception('프로필 업데이트 중 오류가 발생했습니다: $e');
    }
  }

  /// AI 코칭 노트 생성 (Supabase Edge Function 호출)
  Future<String> generateVisionNote(ProfileModel profile) async {
    try {
      final response = await _supabase.functions.invoke(
        'generate-vision-note',
        body: {
          'name': profile.name,
          'values': profile.values,
          'goal': profile.goal,
          'reasons': profile.reasons,
        },
      );

      if (response.data == null) {
        throw Exception('비전 노트 생성 실패');
      }

      final data = response.data as Map<String, dynamic>;
      return data['visionNote'] as String;
    } catch (e) {
      throw Exception('AI 코칭 생성 중 오류가 발생했습니다: $e');
    }
  }

  /// 로드맵 생성 (Supabase Edge Function 호출)
  Future<Map<String, dynamic>> generateGoalTree({
    required String visionNote,
    required String goal,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'generate-goal-tree',
        body: {
          'visionNote': visionNote,
          'goal': goal,
        },
      );

      if (response.data == null) {
        throw Exception('로드맵 생성 실패');
      }

      final data = response.data as Map<String, dynamic>;
      return data['goalTree'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('로드맵 생성 중 오류가 발생했습니다: $e');
    }
  }

  /// 프로필에 비전 노트 저장
  Future<void> saveVisionNote({
    required String userId,
    required String visionNote,
  }) async {
    try {
      await _supabase.from('profiles').update({
        'vision_note': visionNote,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId);
    } catch (e) {
      throw Exception('비전 노트 저장 중 오류가 발생했습니다: $e');
    }
  }

  /// 프로필에 로드맵 저장
  Future<void> saveGoalTree({
    required String userId,
    required Map<String, dynamic> goalTree,
  }) async {
    try {
      await _supabase.from('profiles').update({
        'goal_tree': goalTree,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('user_id', userId);
    } catch (e) {
      throw Exception('로드맵 저장 중 오류가 발생했습니다: $e');
    }
  }
}
