import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/core/usecase/usecase.dart';
import 'package:frontend/features/guia/auth/domain/entities/guia_user.dart';
import 'package:frontend/features/guia/auth/domain/repositories/guia_auth_repository.dart';

class CheckAuthStatusGuiaUseCase implements UseCase<GuiaUser?, NoParams> {
  final GuiaAuthRepository repository;

  CheckAuthStatusGuiaUseCase(this.repository);

  @override
  Future<Either<Failure, GuiaUser?>> call(NoParams params) async {
    return await repository.checkAuthStatus();
  }
}
