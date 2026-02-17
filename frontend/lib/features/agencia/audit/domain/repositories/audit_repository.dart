import 'package:dartz/dartz.dart';
import '../../../../../../core/error/failures.dart';
import '../entities/log_auditoria.dart';

abstract class AuditRepository {
  Future<Either<Failure, List<LogAuditoria>>> getAuditLogs();
}
