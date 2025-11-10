import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quest_on/data/models/goal_model.dart';
import 'package:quest_on/data/models/goal_tree_model.dart';
import 'package:quest_on/domain/entities/goal.dart';
import 'package:quest_on/domain/entities/goal_tree.dart';

/// Goal 데이터 저장소
class GoalRepository {
  final SupabaseClient _supabase;

  GoalRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// 현재 사용자의 Goal Tree 가져오기
  Future<GoalTree?> getCurrentGoalTree() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      // Goal Tree 조회
      final treeResponse = await _supabase
          .from('goal_trees')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (treeResponse == null) return null;

      // 해당 Goal Tree의 모든 Goals 조회
      final goalsResponse = await _supabase
          .from('goals')
          .select()
          .eq('goal_tree_id', treeResponse['id'])
          .order('order_index', ascending: true);

      final goals = (goalsResponse as List)
          .map((json) => GoalModel.fromJson(json).toEntity())
          .toList();

      return GoalTreeModel.fromJson(treeResponse, goals).toEntity();
    } catch (e) {
      throw Exception('Failed to fetch goal tree: $e');
    }
  }

  /// Goal Tree 생성
  Future<GoalTree> createGoalTree({
    required String visionId,
    required List<Goal> goals,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Goal Tree 생성
      final treeModel = GoalTreeModel(
        id: '',
        userId: userId,
        visionId: visionId,
        goals: [],
        createdAt: DateTime.now(),
      );

      final treeResponse = await _supabase
          .from('goal_trees')
          .insert(treeModel.toInsertJson())
          .select()
          .single();

      final goalTreeId = treeResponse['id'] as String;

      // Goals 생성
      final createdGoals = <Goal>[];
      for (var goal in goals) {
        final goalModel = GoalModel(
          id: '',
          userId: userId,
          goalTreeId: goalTreeId,
          parentGoalId: goal.parentGoalId,
          title: goal.title,
          description: goal.description,
          timeframe: goal.timeframe,
          orderIndex: goal.orderIndex,
          isCompleted: false,
          targetDate: goal.targetDate,
          createdAt: DateTime.now(),
        );

        final goalResponse = await _supabase
            .from('goals')
            .insert(goalModel.toInsertJson())
            .select()
            .single();

        createdGoals.add(GoalModel.fromJson(goalResponse).toEntity());
      }

      return GoalTreeModel.fromJson(treeResponse, createdGoals).toEntity();
    } catch (e) {
      throw Exception('Failed to create goal tree: $e');
    }
  }

  /// Goal 추가
  Future<Goal> addGoal({
    required String goalTreeId,
    String? parentGoalId,
    required String title,
    String? description,
    required GoalTimeframe timeframe,
    DateTime? targetDate,
    int orderIndex = 0,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final model = GoalModel(
        id: '',
        userId: userId,
        goalTreeId: goalTreeId,
        parentGoalId: parentGoalId,
        title: title,
        description: description,
        timeframe: timeframe,
        orderIndex: orderIndex,
        isCompleted: false,
        targetDate: targetDate,
        createdAt: DateTime.now(),
      );

      final response = await _supabase
          .from('goals')
          .insert(model.toInsertJson())
          .select()
          .single();

      return GoalModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Failed to add goal: $e');
    }
  }

  /// Goal 수정
  Future<Goal> updateGoal({
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
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final model = GoalModel(
        id: id,
        userId: userId,
        goalTreeId: '',
        title: title,
        description: description,
        timeframe: timeframe,
        orderIndex: orderIndex,
        isCompleted: isCompleted,
        targetDate: targetDate,
        createdAt: DateTime.now(),
        completedAt: completedAt,
      );

      final response = await _supabase
          .from('goals')
          .update(model.toUpdateJson())
          .eq('id', id)
          .eq('user_id', userId)
          .select()
          .single();

      return GoalModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Failed to update goal: $e');
    }
  }

  /// Goal 완료 토글
  Future<Goal> toggleGoalCompletion(String id, bool isCompleted) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('goals')
          .update({
            'is_completed': isCompleted,
            'completed_at': isCompleted ? DateTime.now().toIso8601String() : null,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .eq('user_id', userId)
          .select()
          .single();

      return GoalModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Failed to toggle goal completion: $e');
    }
  }

  /// Goal 삭제
  Future<void> deleteGoal(String id) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from('goals')
          .delete()
          .eq('id', id)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to delete goal: $e');
    }
  }

  /// 사용자가 Goal Tree를 가지고 있는지 확인
  Future<bool> hasGoalTree() async {
    try {
      final goalTree = await getCurrentGoalTree();
      return goalTree != null;
    } catch (e) {
      return false;
    }
  }
}
