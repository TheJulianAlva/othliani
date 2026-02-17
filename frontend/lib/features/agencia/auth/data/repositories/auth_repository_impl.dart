import 'package:dartz/dartz.dart';
import '../../../../../../core/error/failures.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  // Simulating a data source for now, or use shared preferences/api later

  @override
  Future<Either<Failure, AuthUser>> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    if (password == 'fail') {
      return Left(ServerFailure()); // Invalid credentials simulation
    }

    // Mock successful login
    return const Right(
      AuthUser(
        id: '1',
        email: 'admin@othliani.com',
        name: 'Admin Agencia',
        role: 'AGENCY_ADMIN',
      ),
    );
  }

  @override
  Future<Either<Failure, void>> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const Right(null);
  }

  @override
  Future<Either<Failure, AuthUser?>> getCurrentUser() async {
    return const Right(null);
  }
}
