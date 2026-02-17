import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/core/usecase/usecase.dart';
import 'package:frontend/features/turista/profile/domain/entities/user_profile.dart';
import 'package:frontend/features/turista/profile/domain/repositories/profile_repository.dart';

class UpdateProfileUseCase implements UseCase<UserProfile, UserProfile> {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(UserProfile params) async {
    return await repository.updateProfile(params);
  }
}
