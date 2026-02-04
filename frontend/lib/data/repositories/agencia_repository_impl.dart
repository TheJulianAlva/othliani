import 'package:dartz/dartz.dart';
import '../../domain/repositories/agencia_repository.dart';
import '../../domain/entities/dashboard_data.dart';
import '../datasources/agencia_mock_data_source.dart';
import '../../core/error/failures.dart';
import '../../core/mock/mock_models.dart';
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
      return Right(result.map(_mapLogToEntity).toList());
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

  // Mapper for LogAuditoria (still needed since MockLog is used)
  LogAuditoria _mapLogToEntity(MockLog model) {
    // Basic parsing for "YYYY-MM-DD HH:mm".
    // If format changes, this might break, but good for now.
    DateTime fecha;
    try {
      // Assuming Mock uses "2026-01-25 10:42"
      fecha =
          DateTime.tryParse('${model.fecha.replaceAll(' ', 'T')}:00') ??
          DateTime.now();
      // .replaceAll to make it ISO-8601 like: 2026-01-25T10:42:00
    } catch (e) {
      fecha = DateTime.now();
    }

    return LogAuditoria(
      id: model.id,
      fecha: fecha,
      nivel: model.nivel,
      actor: model.actor,
      accion: model.accion,
    );
  }
}
