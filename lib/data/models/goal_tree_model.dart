import 'package:quest_on/domain/entities/goal_tree.dart';
import 'package:quest_on/domain/entities/goal.dart';
import 'package:quest_on/data/models/goal_model.dart';

/// ©\ ¸¬ pt0 ¨x
class GoalTreeModel extends GoalTree {
  const GoalTreeModel({
    required super.id,
    required super.userId,
    required super.visionId,
    required super.goals,
    required super.createdAt,
    super.updatedAt,
  });

  /// Supabase JSONÐ ¨x Ý1
  factory GoalTreeModel.fromJson(Map<String, dynamic> json, List<Goal> goals) {
    return GoalTreeModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      visionId: json['vision_id'] as String,
      goals: goals,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// ¨xD JSON<\ ÀX (INSERT©)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'vision_id': visionId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// ¨xD JSON<\ ÀX (UPDATE©)
  Map<String, dynamic> toUpdateJson() {
    return {
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Ôðð\ ÀX
  GoalTree toEntity() {
    return GoalTree(
      id: id,
      userId: userId,
      visionId: visionId,
      goals: goals,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
