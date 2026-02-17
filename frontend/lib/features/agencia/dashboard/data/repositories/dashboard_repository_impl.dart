import 'package:dartz/dartz.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../../../../../core/error/failures.dart';
import 'package:frontend/features/agencia/shared/data/datasources/agencia_datasource.dart';
import '../../domain/entities/dashboard_data.dart'; // Correct relative path

class DashboardRepositoryImpl implements DashboardRepository {
  final AgenciaDataSource dataSource;

  DashboardRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, DashboardData>> getDashboardData() async {
    try {
      final result = await dataSource.getDashboardData();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
