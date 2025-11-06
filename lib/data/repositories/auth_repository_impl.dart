import 'package:quest_on/domain/entities/user.dart';
import 'package:quest_on/domain/repositories/auth_repository.dart';
import 'package:quest_on/data/datasources/remote/auth_remote_datasource.dart';

/// Auth Repository 구현체
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<User?> getCurrentUser() async {
    return await _remoteDataSource.getCurrentUser();
  }

  @override
  Stream<User?> get authStateChanges => _remoteDataSource.authStateChanges;

  @override
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _remoteDataSource.signInWithEmail(
      email: email,
      password: password,
    );
  }

  @override
  Future<User> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    return await _remoteDataSource.signUpWithEmail(
      email: email,
      password: password,
      name: name,
    );
  }

  @override
  Future<void> signOut() async {
    await _remoteDataSource.signOut();
  }

  @override
  Future<void> resetPassword({required String email}) async {
    await _remoteDataSource.resetPassword(email: email);
  }

  @override
  Future<void> updateProfile({String? name}) async {
    await _remoteDataSource.updateProfile(name: name);
  }
}
