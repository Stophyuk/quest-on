import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quest_on/data/models/user_stats_model.dart';

/// 사용자 통계 Remote DataSource
///
/// Supabase user_stats 테이블과 통신
class UserStatsRemoteDataSource {
  final SupabaseClient _supabase;

  UserStatsRemoteDataSource({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// 사용자 통계 조회
  Future<UserStatsModel?> getUserStats(String userId) async {
    try {
      final response = await _supabase
          .from('user_stats')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;

      return UserStatsModel.fromJson(response);
    } catch (e) {
      throw Exception('사용자 통계 조회 중 오류가 발생했습니다: $e');
    }
  }

  /// 사용자 통계 생성 (초기화)
  /// upsert를 사용하여 중복 생성 방지
  Future<UserStatsModel> createUserStats(UserStatsModel stats) async {
    try {
      final response = await _supabase
          .from('user_stats')
          .upsert(stats.toJson())
          .select()
          .single();

      return UserStatsModel.fromJson(response);
    } catch (e) {
      throw Exception('사용자 통계 생성 중 오류가 발생했습니다: $e');
    }
  }

  /// 사용자 통계 업데이트
  Future<void> updateUserStats(UserStatsModel stats) async {
    try {
      await _supabase
          .from('user_stats')
          .update(stats.toJson())
          .eq('user_id', stats.userId);
    } catch (e) {
      throw Exception('사용자 통계 업데이트 중 오류가 발생했습니다: $e');
    }
  }

  /// 사용자 통계 스트림 (실시간 업데이트)
  Stream<UserStatsModel?> watchUserStats(String userId) {
    return _supabase
        .from('user_stats')
        .stream(primaryKey: ['user_id'])
        .eq('user_id', userId)
        .map((data) {
      if (data.isEmpty) return null;
      return UserStatsModel.fromJson(data.first);
    });
  }
}
