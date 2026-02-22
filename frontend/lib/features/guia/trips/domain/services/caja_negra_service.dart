import 'package:frontend/features/guia/trips/domain/entities/incident_log.dart';
import 'package:frontend/features/guia/trips/domain/repositories/caja_negra_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:frontend/core/di/service_locator.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CajaNegraService — fachada de alto nivel para la auditoría local
//
// Rol: simplificar la escritura en la Caja Negra para módulos que no
// necesitan conocer TipoEventoSeguridad (mapa, alertas, etc.).
// Internamente delega al singleton CajaNegraLocalDataSource.
//
// Uso:
//   CajaNegraService().registrarIncidente(
//     nombreTurista: 'Ana López',
//     prioridad: 'CRITICA',
//     accionRealizada: 'Salida de zona segura',
//   );
// ─────────────────────────────────────────────────────────────────────────────

class CajaNegraService {
  // Singleton — misma instancia durante toda la sesión
  static final CajaNegraService _instance = CajaNegraService._internal();
  factory CajaNegraService() => _instance;
  CajaNegraService._internal();

  CajaNegraRepository get _repo => sl<CajaNegraRepository>();

  Future<void> _log(
    TipoIncidente tipo,
    String desc,
    double lat,
    double lng,
  ) async {
    final ev = IncidentLog(
      id: const Uuid().v4(),
      timestamp: DateTime.now().toUtc(),
      tipo: tipo,
      descripcion: desc,
      latitud: lat,
      longitud: lng,
    );
    await _repo.registrarEvento(ev);
  }

  // ── API de alto nivel ──────────────────────────────────────────────────────

  /// Incidente detectado automáticamente (alejamiento, zona, etc.)
  void registrarIncidente({
    required String nombreTurista,
    required String prioridad,
    required String accionRealizada,
    String coordenadas = '',
  }) {
    _log(
      TipoIncidente.alertaTuristaAlejado,
      '[$prioridad] Turista: $nombreTurista — $accionRealizada - Coords: $coordenadas',
      0,
      0,
    );
  }

  /// SOS automático por tiempo agotado (guía no respondió)
  void registrarSosAutomatico({
    required String nombreTurista,
    String prioridad = 'CRITICA',
    String coordenadas = '',
  }) {
    _log(
      TipoIncidente.sosManual,
      '[$prioridad] Turista: $nombreTurista — SOS AUTOMÁTICO (TIEMPO AGOTADO)',
      0,
      0,
    );
  }

  /// Cancelación deliberada del guía mediante deslizador
  void registrarCancelacionGuia({
    required String descripcionAlerta,
    String coordenadas = '',
  }) {
    _log(
      TipoIncidente.accionGuia,
      'Guía canceló alerta — $descripcionAlerta (deslizador)',
      0,
      0,
    );
  }

  /// Inicio / fin de protección de un viaje
  void registrarInicioProteccion(String nombreViaje) {
    _log(
      TipoIncidente.sistemaIniciado,
      'Inicio de protección: $nombreViaje',
      0,
      0,
    );
  }

  void registrarFinProteccion(String nombreViaje) {
    _log(
      TipoIncidente.sistemaFinalizado,
      'Fin de protección: $nombreViaje',
      0,
      0,
    );
  }

  /// Incidente de turista resuelto exitosamente por el guía (deslizador verde).
  void registrarIncidenteResuelto({
    required String turistaId,
    required String nombreTurista,
    String motivoOriginal = 'Alerta',
  }) {
    _log(
      TipoIncidente.incidenteResuelto,
      'INCIDENTE RESUELTO — Turista: $nombreTurista (ID: $turistaId) — Motivo original: $motivoOriginal',
      0,
      0,
    );
  }

  /// Lee el log completo (más reciente primero)
  Future<List<IncidentLog>> leerBitacora() => _repo.obtenerEvidencia();

  /// Limpia el log (exportar antes de limpiar)
  Future<void> limpiarBitacora() => _repo.limpiarCajaNegraLocal();
}
