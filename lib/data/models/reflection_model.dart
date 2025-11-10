import 'package:quest_on/domain/entities/reflection.dart';

/// Œà pt0 ¨x
class ReflectionModel extends Reflection {
  const ReflectionModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.startDate,
    required super.endDate,
    required super.totalQuests,
    required super.completedQuests,
    super.userThoughts,
    super.aiCoachingMessage,
    required super.createdAt,
  });

  /// Supabase JSONÐ ¨x Ý1
  factory ReflectionModel.fromJson(Map<String, dynamic> json) {
    return ReflectionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: ReflectionType.values.firstWhere(
        (e) => e.name == json['type'] as String,
        orElse: () => ReflectionType.weekly,
      ),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      totalQuests: json['total_quests'] as int,
      completedQuests: json['completed_quests'] as int,
      userThoughts: json['user_thoughts'] as String?,
      aiCoachingMessage: json['ai_coaching_message'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// ¨xD JSON<\ ÀX (INSERT©)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'type': type.name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'total_quests': totalQuests,
      'completed_quests': completedQuests,
      'user_thoughts': userThoughts,
      'ai_coaching_message': aiCoachingMessage,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// ¨xD JSON<\ ÀX (UPDATE©)
  Map<String, dynamic> toUpdateJson() {
    return {
      'user_thoughts': userThoughts,
      'ai_coaching_message': aiCoachingMessage,
    };
  }

  /// Ôðð\ ÀX
  Reflection toEntity() {
    return Reflection(
      id: id,
      userId: userId,
      type: type,
      startDate: startDate,
      endDate: endDate,
      totalQuests: totalQuests,
      completedQuests: completedQuests,
      userThoughts: userThoughts,
      aiCoachingMessage: aiCoachingMessage,
      createdAt: createdAt,
    );
  }
}
