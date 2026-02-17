import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../features/agencia/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/agencia/dashboard/domain/entities/dashboard_data.dart';

class GetDashboardData {
  final DashboardRepository repository;

  GetDashboardData(this.repository);

  Future<Either<Failure, DashboardData>> call() async {
    return await repository.getDashboardData();
  }
}
