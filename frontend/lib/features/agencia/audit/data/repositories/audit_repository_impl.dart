import 'package:dartz/dartz.dart';
import '../../domain/repositories/audit_repository.dart';
import '../../../../../../core/error/failures.dart';
import 'package:frontend/features/agencia/shared/data/datasources/agencia_datasource.dart';
import '../../domain/entities/log_auditoria.dart';

class AuditRepositoryImpl implements AuditRepository {
  final AgenciaDataSource dataSource;

  AuditRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<LogAuditoria>>> getAuditLogs() async {
    try {
      final result = await dataSource.getAuditLogs();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
