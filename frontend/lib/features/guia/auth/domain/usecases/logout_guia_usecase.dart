import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/core/usecase/usecase.dart';
import 'package:frontend/features/guia/auth/domain/repositories/guia_auth_repository.dart';

class LogoutGuiaUseCase implements UseCase<void, NoParams> {
  final GuiaAuthRepository repository;

  LogoutGuiaUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.logout();
  }
}
