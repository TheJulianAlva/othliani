import 'package:dartz/dartz.dart';
import '../../domain/repositories/agencia_repository.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../datasources/agencia_mock_data_source.dart';
import '../../core/error/failures.dart';

class AgenciaRepositoryImpl implements AgenciaRepository {
  final AgenciaDataSource dataSource;

  AgenciaRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, DashboardStats>> getDashboardStats() async {
    try {
      final result = await dataSource.getStats();
      return Right(result); // ¡Éxito! Devolvemos el lado DERECHO
    } catch (e) {
      return Left(ServerFailure()); // ¡Error! Devolvemos el lado IZQUIERDO
    }
  }
}
