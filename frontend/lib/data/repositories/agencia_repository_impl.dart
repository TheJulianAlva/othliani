import 'package:dartz/dartz.dart';
import '../../domain/repositories/agencia_repository.dart';
import '../../domain/entities/dashboard_data.dart';
import '../datasources/agencia_mock_data_source.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/viaje.dart';
import '../../domain/entities/guia.dart';
import '../../domain/entities/turista.dart';
import '../../domain/entities/log_auditoria.dart';

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

  @override
  Future<Either<Failure, List<Viaje>>> getListaViajes() async {
    try {
      final result = await dataSource.getListaViajes();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Viaje>> getDetalleViaje(String id) async {
    try {
      final result = await dataSource.getDetalleViaje(id);
      if (result != null) {
        return Right(result);
      } else {
        return Left(ServerFailure());
      }
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Guia>>> getListaGuias() async {
    try {
      final result = await dataSource.getListaGuias();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<LogAuditoria>>> getAuditLogs() async {
    try {
      final result = await dataSource.getAuditLogs();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Turista>>> getTuristasPorViaje(String id) async {
    try {
      final result = await dataSource.getTuristasByViajeId(id);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> cancelarViaje(String id) async {
    try {
      final result = await dataSource.simularDeleteViaje(id);
      if (result) {
        return const Right(null);
      } else {
        return Left(ServerFailure());
      }
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Turista>>> getListaClientes() async {
    try {
      final result = await dataSource.getTuristas();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
