/// Œà Ôðð
class Reflection {
  final String id;
  final String userId;
  final ReflectionType type;
  final DateTime startDate;
  final DateTime endDate;
  final int totalQuests;
  final int completedQuests;
  final String? userThoughts;
  final String? aiCoachingMessage;
  final DateTime createdAt;

  const Reflection({
    required this.id,
    required this.userId,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.totalQuests,
    required this.completedQuests,
    this.userThoughts,
    this.aiCoachingMessage,
    required this.createdAt,
  });

  double get achievementRate {
    if (totalQuests == 0) return 0.0;
    return completedQuests / totalQuests;
  }

  int get achievementPercent => (achievementRate * 100).round();

  bool get hasCoaching => aiCoachingMessage != null && aiCoachingMessage!.isNotEmpty;

  Reflection copyWith({
    String? id,
    String? userId,
    ReflectionType? type,
    DateTime? startDate,
    DateTime? endDate,
    int? totalQuests,
    int? completedQuests,
    String? userThoughts,
    String? aiCoachingMessage,
    DateTime? createdAt,
  }) {
    return Reflection(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalQuests: totalQuests ?? this.totalQuests,
      completedQuests: completedQuests ?? this.completedQuests,
      userThoughts: userThoughts ?? this.userThoughts,
      aiCoachingMessage: aiCoachingMessage ?? this.aiCoachingMessage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum ReflectionType {
  weekly('ü', Duration(days: 7)),
  monthly('Ô', Duration(days: 30));

  const ReflectionType(this.label, this.duration);

  final String label;
  final Duration duration;
}
