import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_on/domain/entities/profile.dart';
import 'package:quest_on/domain/repositories/vision_repository.dart';
import 'package:quest_on/data/repositories/vision_repository_impl.dart';
import 'package:quest_on/data/datasources/remote/vision_remote_datasource.dart';

// Provider: VisionRemoteDataSource
final visionRemoteDataSourceProvider = Provider<VisionRemoteDataSource>((ref) {
  return VisionRemoteDataSource();
});

// Provider: VisionRepository
final visionRepositoryProvider = Provider<VisionRepository>((ref) {
  return VisionRepositoryImpl(
    remoteDataSource: ref.read(visionRemoteDataSourceProvider),
  );
});

// StateProvider: 현재 프로필 (캐시)
final currentProfileProvider = StateProvider<Profile?>((ref) => null);

// FutureProvider: 프로필 가져오기
final profileProvider =
    FutureProvider.family<Profile?, String>((ref, userId) async {
  final repository = ref.read(visionRepositoryProvider);
  final profile = await repository.getProfile(userId);

  // 캐시에 저장
  if (profile != null) {
    ref.read(currentProfileProvider.notifier).state = profile;
  }

  return profile;
});

// StateNotifierProvider: 비전 관리
final visionNotifierProvider =
    StateNotifierProvider<VisionNotifier, AsyncValue<Profile?>>((ref) {
  return VisionNotifier(ref.read(visionRepositoryProvider));
});

/// 비전 관리 Notifier
class VisionNotifier extends StateNotifier<AsyncValue<Profile?>> {
  final VisionRepository _visionRepository;

  VisionNotifier(this._visionRepository) : super(const AsyncValue.data(null));

  /// 프로필 생성
  Future<void> createProfile({
    required String userId,
    required String name,
    required List<String> values,
    required String goal,
    required List<String> reasons,
  }) async {
    state = const AsyncValue.loading();
    try {
      final profile = await _visionRepository.createProfile(
        userId: userId,
        name: name,
        values: values,
        goal: goal,
        reasons: reasons,
      );
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// 프로필 로드
  Future<void> loadProfile(String userId) async {
    state = const AsyncValue.loading();
    try {
      final profile = await _visionRepository.getProfile(userId);
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// AI 코칭 노트 생성
  Future<String> generateVisionNote() async {
    final currentProfile = state.value;
    if (currentProfile == null) {
      throw Exception('프로필이 없습니다');
    }

    try {
      final visionNote =
          await _visionRepository.generateVisionNote(currentProfile);

      // 프로필에 저장
      await _visionRepository.saveVisionNote(
        userId: currentProfile.userId,
        visionNote: visionNote,
      );

      // 상태 업데이트
      await loadProfile(currentProfile.userId);

      return visionNote;
    } catch (e) {
      rethrow;
    }
  }

  /// 로드맵 생성
  Future<Map<String, dynamic>> generateGoalTree() async {
    final currentProfile = state.value;
    if (currentProfile == null) {
      throw Exception('프로필이 없습니다');
    }

    if (currentProfile.visionNote == null) {
      throw Exception('비전 노트를 먼저 생성해주세요');
    }

    try {
      final goalTree = await _visionRepository.generateGoalTree(
        visionNote: currentProfile.visionNote!,
        goal: currentProfile.goal,
      );

      // 프로필에 저장
      await _visionRepository.saveGoalTree(
        userId: currentProfile.userId,
        goalTree: goalTree,
      );

      // 상태 업데이트
      await loadProfile(currentProfile.userId);

      return goalTree;
    } catch (e) {
      rethrow;
    }
  }
}
