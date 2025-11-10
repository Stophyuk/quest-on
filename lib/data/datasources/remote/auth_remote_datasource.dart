import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao; // 구글 로그인만 사용
// import 'package:flutter_naver_login/flutter_naver_login.dart'; // 패키지 호환성 문제
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

  /// Google 로그인
  Future<UserModel> signInWithGoogle() async {
    try {
      // Google Sign-In 시작
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: '884314617277-bco9flhfdaj716atou6kj34k2r1nc64q.apps.googleusercontent.com',
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google 로그인이 취소되었습니다.');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw Exception('Google 인증 토큰을 가져올 수 없습니다.');
      }

      // Supabase에 Google OAuth로 로그인
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user == null) {
        throw Exception('Google 로그인에 실패했습니다.');
      }

      return UserModel.fromSupabaseUser(response.user!);
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Google 로그인 중 오류가 발생했습니다: $e');
    }
  }

  /// 카카오 로그인 (비활성화 - Google 로그인만 사용)
  Future<UserModel> signInWithKakao() async {
    throw UnimplementedError('카카오 로그인은 현재 지원되지 않습니다.');
    // try {
    //   // 카카오 로그인 실행
    //   kakao.OAuthToken token;
    //   if (await kakao.isKakaoTalkInstalled()) {
    //     try {
    //       token = await kakao.UserApi.instance.loginWithKakaoTalk();
    //     } catch (error) {
    //       // 카카오톡 로그인 실패 시 웹 로그인으로 전환
    //       print('카카오톡 로그인 실패, 카카오 계정으로 로그인 시도: $error');
    //       token = await kakao.UserApi.instance.loginWithKakaoAccount();
    //     }
    //   } else {
    //     token = await kakao.UserApi.instance.loginWithKakaoAccount();
    //   }
    //
    //   // 카카오 사용자 정보 가져오기
    //   final kakao.User user = await kakao.UserApi.instance.me();
    //
    //   // Supabase에 카카오 토큰으로 로그인
    //   // Note: Supabase에서 카카오 OAuth를 지원하지 않으므로,
    //   // 임시로 이메일 기반 계정 생성 또는 Custom Token 방식 사용 필요
    //   // 여기서는 이메일이 있는 경우 이메일로 로그인/가입 처리
    //   final email = user.kakaoAccount?.email;
    //   if (email == null || email.isEmpty) {
    //     throw Exception('카카오 계정에서 이메일 정보를 가져올 수 없습니다. 이메일 제공 동의가 필요합니다.');
    //   }
    //
    //   // TODO: 실제 프로덕션에서는 백엔드에서 Custom Token을 발급받아 로그인하는 방식 권장
    //   // 현재는 임시로 이메일 기반 로그인/가입 처리
    //   try {
    //     // 기존 사용자 로그인 시도 (비밀번호는 카카오 ID를 해시한 값 사용)
    //     final password = 'kakao_${user.id}';
    //     final response = await _supabase.auth.signInWithPassword(
    //       email: email,
    //       password: password,
    //     );
    //     return UserModel.fromSupabaseUser(response.user!);
    //   } catch (e) {
    //     // 사용자가 없으면 회원가입
    //     final password = 'kakao_${user.id}';
    //     final response = await _supabase.auth.signUp(
    //       email: email,
    //       password: password,
    //       data: {
    //         'name': user.kakaoAccount?.profile?.nickname ?? '카카오 사용자',
    //         'provider': 'kakao',
    //       },
    //     );
    //
    //     if (response.user == null) {
    //       throw Exception('카카오 로그인에 실패했습니다.');
    //     }
    //
    //     return UserModel.fromSupabaseUser(response.user!);
    //   }
    // } catch (e) {
    //   throw Exception('카카오 로그인 중 오류가 발생했습니다: $e');
    // }
  }

  /// 네이버 로그인 (임시 비활성화 - 패키지 호환성 문제)
  Future<UserModel> signInWithNaver() async {
    throw UnimplementedError('네이버 로그인은 현재 지원되지 않습니다.');
    // try {
    //   // 네이버 로그인 실행
    //   final NaverLoginResult result = await FlutterNaverLogin.logIn();
    //
    //   if (result.status != NaverLoginStatus.loggedIn) {
    //     throw Exception('네이버 로그인이 취소되었습니다.');
    //   }
    //
    //   // 네이버 사용자 정보 가져오기
    //   final NaverAccountResult account = await FlutterNaverLogin.currentAccount();
    //   final email = account.email;
    //
    //   if (email == null || email.isEmpty) {
    //     throw Exception('네이버 계정에서 이메일 정보를 가져올 수 없습니다.');
    //   }
    //
    //   // TODO: 실제 프로덕션에서는 백엔드에서 Custom Token을 발급받아 로그인하는 방식 권장
    //   // 현재는 임시로 이메일 기반 로그인/가입 처리
    //   try {
    //     // 기존 사용자 로그인 시도
    //     final password = 'naver_${account.id}';
    //     final response = await _supabase.auth.signInWithPassword(
    //       email: email,
    //       password: password,
    //     );
    //     return UserModel.fromSupabaseUser(response.user!);
    //   } catch (e) {
    //     // 사용자가 없으면 회원가입
    //     final password = 'naver_${account.id}';
    //     final response = await _supabase.auth.signUp(
    //       email: email,
    //       password: password,
    //       data: {
    //         'name': account.name ?? '네이버 사용자',
    //         'provider': 'naver',
    //       },
    //     );
    //
    //     if (response.user == null) {
    //       throw Exception('네이버 로그인에 실패했습니다.');
    //     }
    //
    //     return UserModel.fromSupabaseUser(response.user!);
    //   }
    // } catch (e) {
    //   throw Exception('네이버 로그인 중 오류가 발생했습니다: $e');
    // }
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
