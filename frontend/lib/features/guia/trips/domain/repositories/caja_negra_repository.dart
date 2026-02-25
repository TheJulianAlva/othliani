import '../entities/incident_log.dart';

abstract class CajaNegraRepository {
  Future<void> registrarEvento(IncidentLog evento);
  Future<List<IncidentLog>> obtenerEvidencia();
  Future<void> limpiarCajaNegraLocal();
}
