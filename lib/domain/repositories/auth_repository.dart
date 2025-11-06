import 'package:quest_on/domain/entities/user.dart';

/// 인증 Repository 인터페이스 (도메인 레이어)
abstract class AuthRepository {
  /// 현재 로그인된 사용자 가져오기
  Future<User?> getCurrentUser();

  /// 현재 사용자 스트림 (실시간 인증 상태 감지)
  Stream<User?> get authStateChanges;

  /// 이메일/비밀번호로 로그인
  Future<User> signInWithEmail({
    required String email,
    required String password,
  });

  /// 이메일/비밀번호로 회원가입
  Future<User> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  });

  /// 로그아웃
  Future<void> signOut();

  /// 비밀번호 재설정 이메일 보내기
  Future<void> resetPassword({required String email});

  /// 사용자 프로필 업데이트
  Future<void> updateProfile({
    String? name,
  });
}
