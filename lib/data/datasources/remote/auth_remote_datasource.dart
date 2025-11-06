import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quest_on/data/models/user_model.dart';

/// 인증 Remote DataSource
///
/// Supabase Auth API와 직접 통신
class AuthRemoteDataSource {
  final SupabaseClient _supabase;

  AuthRemoteDataSource({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// 현재 로그인된 사용자 가져오기
  Future<UserModel?> getCurrentUser() async {
    final supabaseUser = _supabase.auth.currentUser;
    if (supabaseUser == null) return null;
    return UserModel.fromSupabaseUser(supabaseUser);
  }

  /// 인증 상태 변경 스트림
  Stream<UserModel?> get authStateChanges {
    return _supabase.auth.onAuthStateChange.map((data) {
      final supabaseUser = data.session?.user;
      if (supabaseUser == null) return null;
      return UserModel.fromSupabaseUser(supabaseUser);
    });
  }

  /// 이메일/비밀번호로 로그인
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('로그인에 실패했습니다.');
      }

      return UserModel.fromSupabaseUser(response.user!);
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('로그인 중 오류가 발생했습니다: $e');
    }
  }

  /// 이메일/비밀번호로 회원가입
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: name != null ? {'name': name} : null,
      );

      if (response.user == null) {
        throw Exception('회원가입에 실패했습니다.');
      }

      return UserModel.fromSupabaseUser(response.user!);
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('회원가입 중 오류가 발생했습니다: $e');
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('로그아웃 중 오류가 발생했습니다: $e');
    }
  }

  /// 비밀번호 재설정 이메일 보내기
  Future<void> resetPassword({required String email}) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('비밀번호 재설정 이메일 전송 중 오류가 발생했습니다: $e');
    }
  }

  /// 사용자 프로필 업데이트
  Future<void> updateProfile({String? name}) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;

      await _supabase.auth.updateUser(
        UserAttributes(data: updates),
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('프로필 업데이트 중 오류가 발생했습니다: $e');
    }
  }

  /// AuthException 처리
  Exception _handleAuthException(AuthException e) {
    // 디버깅용 로그
    print('AuthException: ${e.message}, statusCode: ${e.statusCode}');

    // 에러 메시지 우선 확인
    final message = e.message.toLowerCase();

    if (message.contains('invalid login credentials') ||
        message.contains('invalid email or password')) {
      return Exception('이메일 또는 비밀번호가 올바르지 않습니다.');
    }

    if (message.contains('user already registered') ||
        message.contains('email already registered')) {
      return Exception('이미 등록된 이메일입니다.');
    }

    if (message.contains('email not confirmed')) {
      return Exception('이메일 인증이 필요합니다. 메일함을 확인해주세요.');
    }

    if (message.contains('password') && message.contains('weak')) {
      return Exception('비밀번호는 최소 6자 이상이어야 합니다.');
    }

    // statusCode로 처리
    if (e.statusCode != null) {
      switch (e.statusCode) {
        case '400':
          return Exception('입력 정보를 확인해주세요.');
        case '422':
          return Exception('이미 등록된 이메일입니다.');
        case '429':
          return Exception('너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해주세요.');
      }
    }

    // 기본 메시지
    return Exception(e.message.isNotEmpty ? e.message : '인증 중 오류가 발생했습니다.');
  }
}
