import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/turista/profile/data/datasources/profile_local_data_source.dart';
import 'package:frontend/features/turista/profile/data/models/user_profile_model.dart';
import 'package:frontend/features/turista/profile/domain/entities/user_profile.dart';
import 'package:frontend/features/turista/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource localDataSource;

  ProfileRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, UserProfile>> getProfile() async {
    try {
      final profile = await localDataSource.getProfile();
      return Right(profile);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateProfile(
    UserProfile profile,
  ) async {
    try {
      final model = UserProfileModel(
        name: profile.name,
        email: profile.email,
        avatarUrl: profile.avatarUrl,
      );
      await localDataSource.cacheProfile(model);
      return Right(profile);
    } catch (e) {
      return Left(CacheFailure());
    }
  }
}
