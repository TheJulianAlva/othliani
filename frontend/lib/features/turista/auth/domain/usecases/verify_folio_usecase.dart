import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/core/usecase/usecase.dart';
import 'package:frontend/features/turista/auth/domain/repositories/auth_repository.dart';

class VerifyFolioUseCase implements UseCase<bool, String> {
  final AuthRepository repository;

  VerifyFolioUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(String folio) async {
    return await repository.verifyFolio(folio);
  }
}
