/// 사용자 엔티티 (도메인 레이어)
class User {
  final String id;
  final String email;
  final String? name;
  final DateTime createdAt;
  final DateTime? lastSignInAt;

  const User({
    required this.id,
    required this.email,
    this.name,
    required this.createdAt,
    this.lastSignInAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User && other.id == id && other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode;

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name)';
  }
}
