import '../../domain/entities/incident_log.dart';
import '../../domain/repositories/caja_negra_repository.dart';
import '../datasources/caja_negra_local_datasource.dart';

class CajaNegraRepositoryImpl implements CajaNegraRepository {
  final CajaNegraLocalDataSource localDataSource;

  CajaNegraRepositoryImpl({required this.localDataSource});

  @override
  Future<void> registrarEvento(IncidentLog evento) async {
    await localDataSource.registrarEvento(evento);
  }

  @override
  Future<List<IncidentLog>> obtenerEvidencia() async {
    return await localDataSource.obtenerEvidencia();
  }

  @override
  Future<void> limpiarCajaNegraLocal() async {
    await localDataSource.limpiarCajaNegraLocal();
  }
}
