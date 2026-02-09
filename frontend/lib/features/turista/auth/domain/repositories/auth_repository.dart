import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/turista/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, User>> register(
    String name,
    String email,
    String password,
  );
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);
  Future<Either<Failure, void>> logout();

  Future<Either<Failure, User?>> checkAuthStatus();
  Future<Either<Failure, void>> completeOnboarding();
  Future<Either<Failure, bool>> checkOnboardingStatus();
}
