import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/dashboard_stats.dart';
import '../repositories/agencia_repository.dart';

class GetDashboardStats {
  final AgenciaRepository repository;

  GetDashboardStats(this.repository);

  Future<Either<Failure, DashboardStats>> call() async {
    return await repository.getDashboardStats();
  }
}
