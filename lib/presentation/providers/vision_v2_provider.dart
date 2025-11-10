import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_on/data/repositories/vision_repository.dart';
import 'package:quest_on/data/services/ai/openai_service.dart';
import 'package:quest_on/domain/entities/vision.dart';

// Provider: OpenAI Service
final openAIServiceProvider = Provider<OpenAIService>((ref) {
  return OpenAIService();
});

// Provider: VisionRepository
final visionRepositoryProvider = Provider<VisionRepository>((ref) {
  return VisionRepository();
});

// StateNotifierProvider: Vision 관리
final visionNotifierProvider =
    StateNotifierProvider<VisionNotifier, AsyncValue<Vision?>>((ref) {
  return VisionNotifier(
    ref.read(visionRepositoryProvider),
    ref.read(openAIServiceProvider),
  );
});

/// Vision 관리 Notifier (새 버전)
class VisionNotifier extends StateNotifier<AsyncValue<Vision?>> {
  final VisionRepository _visionRepository;
  final OpenAIService _openAIService;

  VisionNotifier(this._visionRepository, this._openAIService)
      : super(const AsyncValue.data(null));

  /// Vision 로드
  Future<void> loadVision() async {
    state = const AsyncValue.loading();
    try {
      final vision = await _visionRepository.getCurrentVision();
      state = AsyncValue.data(vision);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Vision 생성 (질문 답변만 저장, 비전 노트는 나중에 생성)
  Future<Vision> createVision({
    required Map<String, String> answers,
  }) async {
    state = const AsyncValue.loading();
    try {
      final vision = await _visionRepository.createVision(
        answers: answers,
        visionNote: '', // 비전 노트는 아직 생성되지 않음
      );
      state = AsyncValue.data(vision);
      return vision;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// AI 비전 노트 생성 (OpenAI 사용)
  Future<Vision> generateVisionNote(String visionId) async {
    try {
      final currentVision = state.value;
      if (currentVision == null) {
        throw Exception('Vision not found');
      }

      // OpenAI로 비전 노트 생성 (30초 소요)
      final visionNote = await _openAIService.generateVisionNote(
        currentVision.answers,
      );

      // 비전 노트 업데이트
      final updatedVision = await _visionRepository.updateVision(
        id: visionId,
        answers: currentVision.answers,
        visionNote: visionNote,
      );

      state = AsyncValue.data(updatedVision);
      return updatedVision;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Vision 수정
  Future<Vision> updateVision({
    required String id,
    required Map<String, String> answers,
    required String visionNote,
  }) async {
    state = const AsyncValue.loading();
    try {
      final vision = await _visionRepository.updateVision(
        id: id,
        answers: answers,
        visionNote: visionNote,
      );
      state = AsyncValue.data(vision);
      return vision;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Vision 삭제
  Future<void> deleteVision(String id) async {
    state = const AsyncValue.loading();
    try {
      await _visionRepository.deleteVision(id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Vision 존재 여부 확인
  Future<bool> hasVision() async {
    try {
      return await _visionRepository.hasVision();
    } catch (e) {
      return false;
    }
  }
}
