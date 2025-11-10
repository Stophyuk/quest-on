import 'package:quest_on/domain/entities/goal.dart';

/// ©\ pt0 ¨x
class GoalModel extends Goal {
  const GoalModel({
    required super.id,
    required super.userId,
    required super.goalTreeId,
    super.parentGoalId,
    required super.title,
    super.description,
    required super.timeframe,
    super.orderIndex,
    super.isCompleted,
    super.targetDate,
    required super.createdAt,
    super.completedAt,
    super.updatedAt,
  });

  /// Supabase JSONÐ ¨x Ý1
  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      goalTreeId: json['goal_tree_id'] as String,
      parentGoalId: json['parent_goal_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      timeframe: GoalTimeframe.values.firstWhere(
        (e) => e.name == json['timeframe'] as String,
        orElse: () => GoalTimeframe.shortTerm,
      ),
      orderIndex: json['order_index'] as int? ?? 0,
      isCompleted: json['is_completed'] as bool? ?? false,
      targetDate: json['target_date'] != null
          ? DateTime.parse(json['target_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// ¨xD JSON<\ ÀX (INSERT©)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'goal_tree_id': goalTreeId,
      'parent_goal_id': parentGoalId,
      'title': title,
      'description': description,
      'timeframe': timeframe.name,
      'order_index': orderIndex,
      'is_completed': isCompleted,
      'target_date': targetDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// ¨xD JSON<\ ÀX (UPDATE©)
  Map<String, dynamic> toUpdateJson() {
    return {
      'title': title,
      'description': description,
      'timeframe': timeframe.name,
      'order_index': orderIndex,
      'is_completed': isCompleted,
      'target_date': targetDate?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Ôðð\ ÀX
  Goal toEntity() {
    return Goal(
      id: id,
      userId: userId,
      goalTreeId: goalTreeId,
      parentGoalId: parentGoalId,
      title: title,
      description: description,
      timeframe: timeframe,
      orderIndex: orderIndex,
      isCompleted: isCompleted,
      targetDate: targetDate,
      createdAt: createdAt,
      completedAt: completedAt,
      updatedAt: updatedAt,
    );
  }
}
