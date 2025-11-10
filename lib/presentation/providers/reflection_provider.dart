import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_on/data/repositories/reflection_repository.dart';
import 'package:quest_on/data/services/ai/openai_service.dart';
import 'package:quest_on/domain/entities/reflection.dart';
import 'package:quest_on/presentation/providers/vision_v2_provider.dart';

// Provider: ReflectionRepository
final reflectionRepositoryProvider = Provider<ReflectionRepository>((ref) {
  return ReflectionRepository();
});

// StateNotifierProvider: Reflection 관리
final reflectionNotifierProvider =
    StateNotifierProvider<ReflectionNotifier, AsyncValue<List<Reflection>>>(
        (ref) {
  return ReflectionNotifier(
    ref.read(reflectionRepositoryProvider),
    ref.read(openAIServiceProvider),
  );
});

/// Reflection 관리 Notifier
class ReflectionNotifier extends StateNotifier<AsyncValue<List<Reflection>>> {
  final ReflectionRepository _reflectionRepository;
  final OpenAIService _openAIService;

  ReflectionNotifier(this._reflectionRepository, this._openAIService)
      : super(const AsyncValue.data([]));

  /// Reflection 목록 로드
  Future<void> loadReflections({
    ReflectionType? type,
    int limit = 10,
  }) async {
    state = const AsyncValue.loading();
    try {
      final reflections = await _reflectionRepository.getReflections(
        type: type,
        limit: limit,
      );
      state = AsyncValue.data(reflections);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// 특정 기간의 Reflection 가져오기
  Future<Reflection?> getReflection({
    required ReflectionType type,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      return await _reflectionRepository.getReflection(
        type: type,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Reflection 생성 (AI 코칭 메시지 포함)
  Future<Reflection> createReflectionWithAI({
    required ReflectionType type,
    required DateTime startDate,
    required DateTime endDate,
    required int totalQuests,
    required int completedQuests,
    required String userThoughts,
    required String visionNote,
  }) async {
    try {
      // AI 코칭 메시지 생성
      final achievementRate =
          totalQuests > 0 ? (completedQuests / totalQuests) * 100 : 0;

      final aiCoachingMessage = await _openAIService.generateCoachingMessage(
        visionNote: visionNote,
        achievementRate: achievementRate,
        totalQuests: totalQuests,
        completedQuests: completedQuests,
        userThoughts: userThoughts,
      );

      // Reflection 생성
      final reflection = await _reflectionRepository.createReflection(
        type: type,
        startDate: startDate,
        endDate: endDate,
        totalQuests: totalQuests,
        completedQuests: completedQuests,
        userThoughts: userThoughts,
        aiCoachingMessage: aiCoachingMessage,
      );

      // 목록 다시 로드
      await loadReflections();

      return reflection;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Reflection 생성 (AI 없이)
  Future<Reflection> createReflection({
    required ReflectionType type,
    required DateTime startDate,
    required DateTime endDate,
    required int totalQuests,
    required int completedQuests,
    String? userThoughts,
  }) async {
    try {
      final reflection = await _reflectionRepository.createReflection(
        type: type,
        startDate: startDate,
        endDate: endDate,
        totalQuests: totalQuests,
        completedQuests: completedQuests,
        userThoughts: userThoughts,
      );

      // 목록 다시 로드
      await loadReflections();

      return reflection;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Reflection 수정
  Future<void> updateReflection({
    required String id,
    String? userThoughts,
    String? aiCoachingMessage,
  }) async {
    try {
      await _reflectionRepository.updateReflection(
        id: id,
        userThoughts: userThoughts,
        aiCoachingMessage: aiCoachingMessage,
      );
      // 목록 다시 로드
      await loadReflections();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Reflection 삭제
  Future<void> deleteReflection(String id) async {
    try {
      await _reflectionRepository.deleteReflection(id);
      // 목록 다시 로드
      await loadReflections();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// 최근 Reflection 가져오기
  Future<Reflection?> getLatestReflection() async {
    try {
      return await _reflectionRepository.getLatestReflection();
    } catch (e) {
      rethrow;
    }
  }
}
