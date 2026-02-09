import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/core/usecase/usecase.dart';
import 'package:frontend/features/turista/profile/domain/entities/user_profile.dart';
import 'package:frontend/features/turista/profile/domain/repositories/profile_repository.dart';

class GetProfileUseCase implements UseCase<UserProfile, NoParams> {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(NoParams params) async {
    return await repository.getProfile();
  }
}
