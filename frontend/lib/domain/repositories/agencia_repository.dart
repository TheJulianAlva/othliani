import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
// Importamos las entidades que acabamos de crear:
import '../entities/dashboard_data.dart';
import '../entities/viaje.dart';
import '../entities/guia.dart';
import '../entities/log_auditoria.dart';

abstract class AgenciaRepository {
  // Dashboard
  Future<Either<Failure, DashboardData>> getDashboardData();

  // Métodos Tipados (Ya no usamos 'dynamic')
  Future<Either<Failure, List<Viaje>>> getListaViajes();
  Future<Either<Failure, Viaje>> getDetalleViaje(String id);
  Future<Either<Failure, List<Guia>>> getListaGuias();
  Future<Either<Failure, List<LogAuditoria>>> getAuditLogs();
}
