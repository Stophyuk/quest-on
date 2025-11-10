import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quest_on/data/models/vision_model.dart';
import 'package:quest_on/domain/entities/vision.dart';

/// Vision 데이터 저장소
class VisionRepository {
  final SupabaseClient _supabase;

  VisionRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// 현재 사용자의 Vision 가져오기
  Future<Vision?> getCurrentVision() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('visions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;

      return VisionModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Failed to fetch vision: $e');
    }
  }

  /// Vision 생성
  Future<Vision> createVision({
    required Map<String, String> answers,
    required String visionNote,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final model = VisionModel(
        id: '',
        userId: userId,
        answers: answers,
        visionNote: visionNote,
        createdAt: DateTime.now(),
      );

      final response = await _supabase
          .from('visions')
          .insert(model.toInsertJson())
          .select()
          .single();

      return VisionModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Failed to create vision: $e');
    }
  }

  /// Vision 수정
  Future<Vision> updateVision({
    required String id,
    required Map<String, String> answers,
    required String visionNote,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final model = VisionModel(
        id: id,
        userId: userId,
        answers: answers,
        visionNote: visionNote,
        createdAt: DateTime.now(),
      );

      final response = await _supabase
          .from('visions')
          .update(model.toUpdateJson())
          .eq('id', id)
          .eq('user_id', userId)
          .select()
          .single();

      return VisionModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Failed to update vision: $e');
    }
  }

  /// Vision 삭제
  Future<void> deleteVision(String id) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from('visions')
          .delete()
          .eq('id', id)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to delete vision: $e');
    }
  }

  /// 사용자가 Vision을 가지고 있는지 확인
  Future<bool> hasVision() async {
    try {
      final vision = await getCurrentVision();
      return vision != null;
    } catch (e) {
      return false;
    }
  }
}
