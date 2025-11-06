import 'dart:convert';
import 'package:quest_on/domain/entities/profile.dart';

/// 프로필 모델 (데이터 레이어)
class ProfileModel extends Profile {
  const ProfileModel({
    required super.userId,
    required super.name,
    required super.values,
    required super.goal,
    required super.reasons,
    super.visionNote,
    super.goalTree,
    required super.createdAt,
    super.updatedAt,
  });

  /// JSON에서 ProfileModel 생성
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['user_id'] as String,
      name: json['name'] as String,
      values: (json['values'] as List<dynamic>).cast<String>(),
      goal: json['goal'] as String,
      reasons: (json['reasons'] as List<dynamic>).cast<String>(),
      visionNote: json['vision_note'] as String?,
      goalTree: json['goal_tree'] != null
          ? (json['goal_tree'] is String
              ? jsonDecode(json['goal_tree'] as String)
              : json['goal_tree'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'values': values,
      'goal': goal,
      'reasons': reasons,
      'vision_note': visionNote,
      'goal_tree': goalTree,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Insert용 JSON (created_at 제외)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'name': name,
      'values': values,
      'goal': goal,
      'reasons': reasons,
      'vision_note': visionNote,
      'goal_tree': goalTree,
    };
  }

  /// Update용 JSON (user_id, created_at 제외)
  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'values': values,
      'goal': goal,
      'reasons': reasons,
      'vision_note': visionNote,
      'goal_tree': goalTree,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// ProfileModel 복사
  ProfileModel copyWith({
    String? userId,
    String? name,
    List<String>? values,
    String? goal,
    List<String>? reasons,
    String? visionNote,
    Map<String, dynamic>? goalTree,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      values: values ?? this.values,
      goal: goal ?? this.goal,
      reasons: reasons ?? this.reasons,
      visionNote: visionNote ?? this.visionNote,
      goalTree: goalTree ?? this.goalTree,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
