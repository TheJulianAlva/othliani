import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/dashboard_stats.dart';

abstract class AgenciaRepository {
  // Retorna un FALLO (Izquierda) o un ÉXITO (Derecha)
  Future<Either<Failure, DashboardStats>> getDashboardStats();
}
