import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/turista/profile/domain/entities/user_profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile>> getProfile();
  Future<Either<Failure, UserProfile>> updateProfile(UserProfile profile);
}
