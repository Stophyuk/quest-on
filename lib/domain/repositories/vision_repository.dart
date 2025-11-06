import 'package:quest_on/domain/entities/profile.dart';

/// 비전 Repository 인터페이스 (도메인 레이어)
abstract class VisionRepository {
  /// 프로필 생성
  Future<Profile> createProfile({
    required String userId,
    required String name,
    required List<String> values,
    required String goal,
    required List<String> reasons,
  });

  /// 프로필 조회
  Future<Profile?> getProfile(String userId);

  /// 프로필 업데이트
  Future<void> updateProfile(Profile profile);

  /// AI 코칭 노트 생성 (Supabase Edge Function 호출)
  Future<String> generateVisionNote(Profile profile);

  /// 로드맵 생성 (Supabase Edge Function 호출)
  Future<Map<String, dynamic>> generateGoalTree({
    required String visionNote,
    required String goal,
  });

  /// 프로필에 비전 노트 저장
  Future<void> saveVisionNote({
    required String userId,
    required String visionNote,
  });

  /// 프로필에 로드맵 저장
  Future<void> saveGoalTree({
    required String userId,
    required Map<String, dynamic> goalTree,
  });
}
