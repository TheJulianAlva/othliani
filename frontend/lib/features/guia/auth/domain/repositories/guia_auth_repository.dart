import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/guia/auth/domain/entities/guia_user.dart';

abstract class GuiaAuthRepository {
  Future<Either<Failure, GuiaUser>> login(String email, String password);
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);
  Future<Either<Failure, GuiaUser?>> checkAuthStatus();
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, void>> completeOnboarding();
  Future<Either<Failure, bool>> checkOnboardingStatus();
}
