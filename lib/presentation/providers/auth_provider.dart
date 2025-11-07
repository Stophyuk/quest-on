import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_on/domain/entities/user.dart';
import 'package:quest_on/domain/repositories/auth_repository.dart';
import 'package:quest_on/data/repositories/auth_repository_impl.dart';
import 'package:quest_on/data/datasources/remote/auth_remote_datasource.dart';
import 'package:quest_on/presentation/providers/user_stats_provider.dart';

// Provider: AuthRemoteDataSource
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource();
});

// Provider: AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.read(authRemoteDataSourceProvider),
  );
});

// StreamProvider: 현재 사용자 인증 상태 스트림
final authStateProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

// StateNotifierProvider: 인증 상태 관리
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier(
    ref.read(authRepositoryProvider),
    ref,
  );
});

/// 인증 상태 관리 Notifier
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _authRepository;
  final Ref _ref;

  AuthNotifier(this._authRepository, this._ref)
      : super(const AsyncValue.loading()) {
    _init();
  }

  /// 초기화: 현재 사용자 확인
  Future<void> _init() async {
    try {
      final user = await _authRepository.getCurrentUser();
      state = AsyncValue.data(user);

      // 앱 재시작 시 로그인된 사용자가 있으면 UserStats 로드
      if (user != null) {
        _ref.read(userStatsNotifierProvider.notifier).loadUserStats(user.id);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 이메일/비밀번호로 로그인
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.signInWithEmail(
        email: email,
        password: password,
      );
      state = AsyncValue.data(user);

      // 로그인 성공 시 UserStats 로드
      if (user != null) {
        _ref.read(userStatsNotifierProvider.notifier).loadUserStats(user.id);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// 이메일/비밀번호로 회원가입
  /// 회원가입 성공 후 자동 로그인됨 (Supabase 기본 동작)
  /// Router가 UserStats 존재 여부를 확인하여 온보딩으로 리다이렉트
  Future<String> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );

      // 로그인된 상태로 설정 (Supabase가 자동으로 session 생성)
      state = AsyncValue.data(user);

      // 회원가입 성공 시 UserStats 로드
      _ref.read(userStatsNotifierProvider.notifier).loadUserStats(user.id);

      return user.id; // user ID 반환 (온보딩에서 사용)
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// 비밀번호 재설정
  Future<void> resetPassword({required String email}) async {
    try {
      await _authRepository.resetPassword(email: email);
    } catch (e) {
      rethrow;
    }
  }

  /// 프로필 업데이트
  Future<void> updateProfile({String? name}) async {
    try {
      await _authRepository.updateProfile(name: name);
      // 업데이트 후 사용자 정보 다시 가져오기
      await _init();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
