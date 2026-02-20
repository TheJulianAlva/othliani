import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/guia/auth/data/datasources/guia_auth_local_data_source.dart';
import 'package:frontend/features/guia/auth/data/datasources/guia_auth_remote_data_source.dart';
import 'package:frontend/features/guia/auth/data/datasources/guia_subscription_remote_data_source.dart';
import 'package:frontend/features/guia/auth/domain/entities/guia_user.dart';
import 'package:frontend/features/guia/auth/domain/repositories/guia_auth_repository.dart';
import 'package:frontend/features/guia/auth/domain/usecases/register_guia_usecase.dart';
import 'package:frontend/features/guia/auth/domain/usecases/activate_subscription_guia_usecase.dart';

class GuiaAuthRepositoryImpl implements GuiaAuthRepository {
  final GuiaAuthRemoteDataSource remoteDataSource;
  final GuiaAuthLocalDataSource localDataSource;
  final GuiaSubscriptionRemoteDataSource subscriptionDataSource;

  GuiaAuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.subscriptionDataSource,
  });

  // ── Auth ─────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, GuiaUser>> login(String email, String password) async {
    try {
      final userModel = await remoteDataSource.login(email, password);
      await localDataSource.cacheGuiaUser(userModel);
      return Right(userModel);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, GuiaUser?>> checkAuthStatus() async {
    try {
      final userModel = await localDataSource.getLastGuiaUser();
      return Right(userModel);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearGuiaUser();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  // ── Onboarding ───────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> completeOnboarding() async {
    try {
      await localDataSource.cacheOnboardingStatus();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkOnboardingStatus() async {
    try {
      final status = await localDataSource.getOnboardingStatus();
      return Right(status);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  // ── B2C Registration Flow ────────────────────────────────────────────────

  @override
  Future<Either<Failure, GuiaUser>> register(RegisterGuiaParams params) async {
    try {
      final userModel = await subscriptionDataSource.register(params);
      return Right(userModel);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifyEmailCode(String codigo) async {
    try {
      await subscriptionDataSource.verifyEmailCode(codigo);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> activateSubscription(
    ActivateSubscriptionGuiaParams params,
  ) async {
    try {
      await subscriptionDataSource.activateSubscription(params);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // ── B2B Agency flow ─────────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> verifyAgencyFolio(String folio) async {
    try {
      await remoteDataSource.verifyFolio(folio);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, GuiaUser>> loginWithAgencyAccess(
    String folio,
    String phone,
  ) async {
    try {
      final userModel = await remoteDataSource.loginWithAgencyAccess(
        folio,
        phone,
      );
      await localDataSource.cacheGuiaUser(userModel);
      return Right(userModel);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
