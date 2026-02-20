import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/core/usecase/usecase.dart';
import 'package:frontend/features/guia/auth/domain/repositories/guia_auth_repository.dart';

/// Guarda en SharedPreferences que el guía completó el onboarding,
/// añadiendo el método al repositorio de autenticación existente.
class CompleteOnboardingGuiaUseCase implements UseCase<void, NoParams> {
  final GuiaAuthRepository repository;

  CompleteOnboardingGuiaUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.completeOnboarding();
  }
}

class CheckOnboardingGuiaUseCase implements UseCase<bool, NoParams> {
  final GuiaAuthRepository repository;

  CheckOnboardingGuiaUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.checkOnboardingStatus();
  }
}
