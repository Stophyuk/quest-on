import 'package:quest_on/domain/entities/quest.dart';

/// 퀘스트 데이터 모델
class QuestModel extends Quest {
  const QuestModel({
    required super.id,
    required super.userId,
    required super.title,
    super.description,
    required super.category,
    required super.difficulty,
    required super.targetCondition,
    required super.targetCount,
    super.currentCount,
    super.isCompleted,
    required super.expReward,
    required super.createdAt,
    super.completedAt,
    super.deletedAt,
  });

  /// Supabase JSON에서 모델 생성
  factory QuestModel.fromJson(Map<String, dynamic> json) {
    return QuestModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: QuestCategory.values.firstWhere(
        (e) => e.name == json['category'] as String,
        orElse: () => QuestCategory.other,
      ),
      difficulty: QuestDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'] as String,
        orElse: () => QuestDifficulty.normal,
      ),
      targetCondition: QuestCondition.values.firstWhere(
        (e) => e.name == json['target_condition'] as String,
        orElse: () => QuestCondition.normal,
      ),
      targetCount: json['target_count'] as int,
      currentCount: json['current_count'] as int? ?? 0,
      isCompleted: json['is_completed'] as bool? ?? false,
      expReward: json['exp_reward'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  /// 모델을 JSON으로 변환 (INSERT용)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'title': title,
      'description': description,
      'category': category.name,
      'difficulty': difficulty.name,
      'target_condition': targetCondition.name,
      'target_count': targetCount,
      'current_count': currentCount,
      'is_completed': isCompleted,
      'exp_reward': expReward,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// 모델을 JSON으로 변환 (UPDATE용)
  Map<String, dynamic> toUpdateJson() {
    return {
      'title': title,
      'description': description,
      'category': category.name,
      'difficulty': difficulty.name,
      'target_condition': targetCondition.name,
      'target_count': targetCount,
      'current_count': currentCount,
      'is_completed': isCompleted,
      'exp_reward': expReward,
      'completed_at': completedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  /// 진행 상황 업데이트 (currentCount 증가)
  QuestModel incrementProgress() {
    final newCount = currentCount + 1;
    final isNowCompleted = newCount >= targetCount;

    return QuestModel(
      id: id,
      userId: userId,
      title: title,
      description: description,
      category: category,
      difficulty: difficulty,
      targetCondition: targetCondition,
      targetCount: targetCount,
      currentCount: newCount,
      isCompleted: isNowCompleted,
      expReward: expReward,
      createdAt: createdAt,
      completedAt: isNowCompleted ? DateTime.now() : completedAt,
      deletedAt: deletedAt,
    );
  }

  /// 컨디션 변경 시 목표 재조정
  QuestModel adjustTargetByCondition(QuestCondition newCondition) {
    // 기본 목표는 'good' 컨디션 기준
    final baseTarget = (targetCount / targetCondition.multiplier).round();
    final newTarget = newCondition.adjustTarget(baseTarget);

    return QuestModel(
      id: id,
      userId: userId,
      title: title,
      description: description,
      category: category,
      difficulty: difficulty,
      targetCondition: newCondition,
      targetCount: newTarget,
      currentCount: currentCount,
      isCompleted: isCompleted,
      expReward: expReward,
      createdAt: createdAt,
      completedAt: completedAt,
      deletedAt: deletedAt,
    );
  }

  /// 소프트 삭제
  QuestModel softDelete() {
    return QuestModel(
      id: id,
      userId: userId,
      title: title,
      description: description,
      category: category,
      difficulty: difficulty,
      targetCondition: targetCondition,
      targetCount: targetCount,
      currentCount: currentCount,
      isCompleted: isCompleted,
      expReward: expReward,
      createdAt: createdAt,
      completedAt: completedAt,
      deletedAt: DateTime.now(),
    );
  }

  /// 엔티티로 변환
  Quest toEntity() {
    return Quest(
      id: id,
      userId: userId,
      title: title,
      description: description,
      category: category,
      difficulty: difficulty,
      targetCondition: targetCondition,
      targetCount: targetCount,
      currentCount: currentCount,
      isCompleted: isCompleted,
      expReward: expReward,
      createdAt: createdAt,
      completedAt: completedAt,
      deletedAt: deletedAt,
    );
  }
}
