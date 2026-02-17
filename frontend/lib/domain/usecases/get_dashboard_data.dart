import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/dashboard_data.dart';
import '../repositories/agencia_repository.dart';

class GetDashboardData {
  final AgenciaRepository repository;

  GetDashboardData(this.repository);

  Future<Either<Failure, DashboardData>> call() async {
    return await repository.getDashboardData();
  }
}
