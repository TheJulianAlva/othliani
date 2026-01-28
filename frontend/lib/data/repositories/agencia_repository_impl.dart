import 'package:dartz/dartz.dart';
import '../../domain/repositories/agencia_repository.dart';
import '../../domain/entities/dashboard_data.dart';
import '../datasources/agencia_mock_data_source.dart';
import '../../core/error/failures.dart';

class AgenciaRepositoryImpl implements AgenciaRepository {
  final AgenciaDataSource dataSource;

  AgenciaRepositoryImpl(this.dataSource);

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
