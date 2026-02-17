import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/core/usecase/usecase.dart';
import 'package:frontend/features/turista/auth/domain/repositories/auth_repository.dart';

class ResendEmailVerificationUseCase implements UseCase<void, String> {
  final AuthRepository repository;

  ResendEmailVerificationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String email) async {
    return await repository.resendEmailVerification(email);
  }
}
