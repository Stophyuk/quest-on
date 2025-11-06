import 'package:quest_on/domain/entities/profile.dart';
import 'package:quest_on/domain/repositories/vision_repository.dart';
import 'package:quest_on/data/datasources/remote/vision_remote_datasource.dart';
import 'package:quest_on/data/models/profile_model.dart';

/// Vision Repository 구현체
class VisionRepositoryImpl implements VisionRepository {
  final VisionRemoteDataSource _remoteDataSource;

  VisionRepositoryImpl({
    required VisionRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Profile> createProfile({
    required String userId,
    required String name,
    required List<String> values,
    required String goal,
    required List<String> reasons,
  }) async {
    return await _remoteDataSource.createProfile(
      userId: userId,
      name: name,
      values: values,
      goal: goal,
      reasons: reasons,
    );
  }

  @override
  Future<Profile?> getProfile(String userId) async {
    return await _remoteDataSource.getProfile(userId);
  }

  @override
  Future<void> updateProfile(Profile profile) async {
    if (profile is! ProfileModel) {
      throw Exception('Profile must be ProfileModel');
    }
    await _remoteDataSource.updateProfile(profile);
  }

  @override
  Future<String> generateVisionNote(Profile profile) async {
    if (profile is! ProfileModel) {
      throw Exception('Profile must be ProfileModel');
    }
    return await _remoteDataSource.generateVisionNote(profile);
  }

  @override
  Future<Map<String, dynamic>> generateGoalTree({
    required String visionNote,
    required String goal,
  }) async {
    return await _remoteDataSource.generateGoalTree(
      visionNote: visionNote,
      goal: goal,
    );
  }

  @override
  Future<void> saveVisionNote({
    required String userId,
    required String visionNote,
  }) async {
    await _remoteDataSource.saveVisionNote(
      userId: userId,
      visionNote: visionNote,
    );
  }

  @override
  Future<void> saveGoalTree({
    required String userId,
    required Map<String, dynamic> goalTree,
  }) async {
    await _remoteDataSource.saveGoalTree(
      userId: userId,
      goalTree: goalTree,
    );
  }
}
