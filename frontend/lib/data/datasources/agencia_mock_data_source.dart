import 'package:othliani/features/agencia/shared/data/datasources/mock_agencia_datasource.dart';
import '../../features/agencia/dashboard/domain/entities/dashboard_data.dart';
import '../../features/agencia/trips/domain/entities/viaje.dart';
import '../../features/agencia/users/domain/entities/guia.dart';
import '../../features/agencia/users/domain/entities/turista.dart';
import 'package:othliani/features/agencia/shared/domain/entities/alerta.dart';
import '../../features/agencia/audit/domain/entities/log_auditoria.dart';

abstract class AgenciaDataSource {
  Future<DashboardData> getDashboardData();
  Future<List<Viaje>> getListaViajes();
  Future<Viaje?> getDetalleViaje(String id);
  Future<List<Guia>> getListaGuias();
  Future<List<LogAuditoria>> getAuditLogs();
  Future<List<Turista>> getTuristasByViajeId(String viajeId);
  Future<bool> simularDeleteViaje(String id);

  // New methods for User Management
  Future<List<Guia>> getGuias();
  Future<List<Turista>> getTuristas();
}

class AgenciaMockDataSourceImpl implements AgenciaDataSource {
  final MockAgenciaDataSource db;

  AgenciaMockDataSourceImpl(this.db);

  @override
  Future<DashboardData> getDashboardData() async {
    try {
      final data = await db.getDashboardFullData();
      final stats = data['stats'] as Map<String, dynamic>;

      return DashboardData(
        viajesActivos: stats['viajes_activos'] as int,
        viajesProgramados: stats['viajes_prog'] as int,
        turistasEnCampo: stats['turistas_campo'] as int,
        turistasSinRed: stats['turistas_sin_red'] as int,
        alertasCriticas: stats['alertas_criticas'] as int,
        guiasOffline: stats['guias_offline'] as int,
        guiasTotal: stats['guias_total'] as int,
        viajesEnMapa: data['active_trips'] as List<Viaje>,
        alertasRecientes: data['alertas_recientes'] as List<Alerta>,
      );
    } catch (e) {
      throw Exception('Error en base de datos simulada: $e');
    }
  }

  @override
  Future<List<Viaje>> getListaViajes() {
    return db.getAllViajes();
  }

  @override
  Future<Viaje?> getDetalleViaje(String id) {
    return db.getViajeById(id);
  }

  @override
  Future<List<Guia>> getListaGuias() {
    return db.getAllGuias();
  }

  @override
  Future<List<LogAuditoria>> getAuditLogs() {
    return db.getAuditLogs();
  }

  @override
  Future<List<Turista>> getTuristasByViajeId(String viajeId) {
    return db.getTuristasByViajeId(viajeId);
  }

  @override
  Future<bool> simularDeleteViaje(String id) {
    return db.simularDeleteViaje(id);
  }

  @override
  Future<List<Guia>> getGuias() {
    return db.getAllGuias();
  }

  @override
  Future<List<Turista>> getTuristas() {
    return db.getAllTuristas();
  }
}
