import 'package:quest_on/domain/entities/goal.dart';

/// ©\ ¸¬ Ôðð
class GoalTree {
  final String id;
  final String userId;
  final String visionId;
  final List<Goal> goals;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const GoalTree({
    required this.id,
    required this.userId,
    required this.visionId,
    required this.goals,
    required this.createdAt,
    this.updatedAt,
  });

  List<Goal> get longTermGoals => goals.where((g) =>
    g.timeframe == GoalTimeframe.longTerm && g.isRoot).toList();

  List<Goal> get midTermGoals => goals.where((g) =>
    g.timeframe == GoalTimeframe.midTerm && g.isRoot).toList();

  List<Goal> get shortTermGoals => goals.where((g) =>
    g.timeframe == GoalTimeframe.shortTerm && g.isRoot).toList();

  List<Goal> getChildGoals(String parentId) =>
    goals.where((g) => g.parentGoalId == parentId).toList();

  int get activeGoalsCount => goals.where((g) => g.isActive).length;
  int get completedGoalsCount => goals.where((g) => g.isCompleted).length;
  double get completionRate => goals.isEmpty ? 0.0 : completedGoalsCount / goals.length;

  GoalTree copyWith({
    String? id,
    String? userId,
    String? visionId,
    List<Goal>? goals,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GoalTree(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      visionId: visionId ?? this.visionId,
      goals: goals ?? this.goals,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
