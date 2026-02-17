import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/core/usecase/usecase.dart';
import 'package:frontend/features/turista/auth/domain/repositories/auth_repository.dart';

class CheckOnboardingStatusUseCase implements UseCase<bool, NoParams> {
  final AuthRepository repository;

  CheckOnboardingStatusUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.checkOnboardingStatus();
  }
}
