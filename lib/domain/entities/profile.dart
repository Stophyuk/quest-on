/// 사용자 프로필 엔티티 (비전 설문 데이터)
class Profile {
  final String userId;
  final String name;
  final List<String> values; // 가치관 (최대 3개)
  final String goal; // 목표
  final List<String> reasons; // 이유 (최대 3개)
  final String? visionNote; // AI 생성 코칭 노트
  final Map<String, dynamic>? goalTree; // AI 생성 로드맵
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Profile({
    required this.userId,
    required this.name,
    required this.values,
    required this.goal,
    required this.reasons,
    this.visionNote,
    this.goalTree,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Profile && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() {
    return 'Profile(userId: $userId, name: $name, goal: $goal)';
  }
}
