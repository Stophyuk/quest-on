import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_on/data/repositories/goal_repository.dart';
import 'package:quest_on/data/services/ai/openai_service.dart';
import 'package:quest_on/domain/entities/goal.dart';
import 'package:quest_on/domain/entities/goal_tree.dart';
import 'package:quest_on/presentation/providers/vision_v2_provider.dart';

// Provider: GoalRepository
final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return GoalRepository();
});

// StateNotifierProvider: Goal Tree 관리
final goalTreeNotifierProvider =
    StateNotifierProvider<GoalTreeNotifier, AsyncValue<GoalTree?>>((ref) {
  return GoalTreeNotifier(
    ref.read(goalRepositoryProvider),
    ref.read(openAIServiceProvider),
  );
});

/// Goal Tree 관리 Notifier
class GoalTreeNotifier extends StateNotifier<AsyncValue<GoalTree?>> {
  final GoalRepository _goalRepository;
  final OpenAIService _openAIService;

  GoalTreeNotifier(this._goalRepository, this._openAIService)
      : super(const AsyncValue.data(null));

  /// Goal Tree 로드
  Future<void> loadGoalTree() async {
    state = const AsyncValue.loading();
    try {
      final goalTree = await _goalRepository.getCurrentGoalTree();
      state = AsyncValue.data(goalTree);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// AI Goal Tree 생성 (OpenAI 사용)
  Future<GoalTree> generateGoalTree({
    required String visionId,
    required String visionNote,
  }) async {
    state = const AsyncValue.loading();
    try {
      // OpenAI로 Goal Tree 생성
      final goalTreeJson = await _openAIService.generateGoalTree(visionNote);

      // TODO: JSON 파싱하여 Goal 리스트 생성
      // 임시로 빈 리스트 사용
      final goals = <Goal>[];

      // Goal Tree 저장
      final goalTree = await _goalRepository.createGoalTree(
        visionId: visionId,
        goals: goals,
      );

      state = AsyncValue.data(goalTree);
      return goalTree;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Goal Tree 생성 (수동)
  Future<GoalTree> createGoalTree({
    required String visionId,
    required List<Goal> goals,
  }) async {
    state = const AsyncValue.loading();
    try {
      final goalTree = await _goalRepository.createGoalTree(
        visionId: visionId,
        goals: goals,
      );
      state = AsyncValue.data(goalTree);
      return goalTree;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Goal 추가
  Future<void> addGoal({
    required String goalTreeId,
    String? parentGoalId,
    required String title,
    String? description,
    required GoalTimeframe timeframe,
    DateTime? targetDate,
    int orderIndex = 0,
  }) async {
    try {
      await _goalRepository.addGoal(
        goalTreeId: goalTreeId,
        parentGoalId: parentGoalId,
        title: title,
        description: description,
        timeframe: timeframe,
        targetDate: targetDate,
        orderIndex: orderIndex,
      );
      // Reload goal tree
      await loadGoalTree();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Goal 수정
  Future<void> updateGoal({
    required String id,
    required String title,
    String? description,
    required GoalTimeframe timeframe,
    required int orderIndex,
    required bool isCompleted,
    DateTime? targetDate,
    DateTime? completedAt,
  }) async {
    try {
      await _goalRepository.updateGoal(
        id: id,
        title: title,
        description: description,
        timeframe: timeframe,
        orderIndex: orderIndex,
        isCompleted: isCompleted,
        targetDate: targetDate,
        completedAt: completedAt,
      );
      // Reload goal tree
      await loadGoalTree();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Goal 완료 토글
  Future<void> toggleGoalCompletion(String id, bool isCompleted) async {
    try {
      await _goalRepository.toggleGoalCompletion(id, isCompleted);
      // Reload goal tree
      await loadGoalTree();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Goal 삭제
  Future<void> deleteGoal(String id) async {
    try {
      await _goalRepository.deleteGoal(id);
      // Reload goal tree
      await loadGoalTree();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Goal Tree 존재 여부 확인
  Future<bool> hasGoalTree() async {
    try {
      return await _goalRepository.hasGoalTree();
    } catch (e) {
      return false;
    }
  }
}
