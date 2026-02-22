import 'package:frontend/features/guia/trips/data/datasources/caja_negra_local_datasource.dart';

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

  final _ds = CajaNegraLocalDataSource();

  // ── API de alto nivel ──────────────────────────────────────────────────────

  /// Incidente detectado automáticamente (alejamiento, zona, etc.)
  /// Fire-and-forget: no bloquea la UI en situaciones críticas.
  void registrarIncidente({
    required String nombreTurista,
    required String prioridad,
    required String accionRealizada,
    String coordenadas = '',
  }) {
    _ds.registrarEvento(
      tipo: TipoEventoSeguridad.alertaAlejamiento,
      descripcion: 'Turista: $nombreTurista — $accionRealizada',
      prioridad: prioridad,
      coordenadas: coordenadas,
    );
  }

  /// SOS automático por tiempo agotado (guía no respondió)
  void registrarSosAutomatico({
    required String nombreTurista,
    String prioridad = 'CRITICA',
    String coordenadas = '',
  }) {
    _ds.registrarEvento(
      tipo: TipoEventoSeguridad.sosManual,
      descripcion: 'Turista: $nombreTurista — SOS AUTOMÁTICO (TIEMPO AGOTADO)',
      prioridad: prioridad,
      coordenadas: coordenadas,
    );
  }

  /// Cancelación deliberada del guía mediante deslizador
  void registrarCancelacionGuia({
    required String descripcionAlerta,
    String coordenadas = '',
  }) {
    _ds.registrarEvento(
      tipo: TipoEventoSeguridad.accionGuia,
      descripcion: 'Guía canceló alerta — $descripcionAlerta (deslizador)',
      prioridad: 'INFO',
      coordenadas: coordenadas,
    );
  }

  /// Inicio / fin de protección de un viaje
  void registrarInicioProteccion(String nombreViaje) {
    _ds.registrarEvento(
      tipo: TipoEventoSeguridad.inicioProteccion,
      descripcion: 'Inicio de protección: $nombreViaje',
      prioridad: 'INFO',
    );
  }

  void registrarFinProteccion(String nombreViaje) {
    _ds.registrarEvento(
      tipo: TipoEventoSeguridad.finProteccion,
      descripcion: 'Fin de protección: $nombreViaje',
      prioridad: 'INFO',
    );
  }

  /// Incidente de turista resuelto exitosamente por el guía (deslizador verde).
  ///
  /// Se llama al confirmar "Emergencia Resuelta" en [PantallaAlertasGuia].
  void registrarIncidenteResuelto({
    required String turistaId,
    required String nombreTurista,
    String motivoOriginal = 'Alerta',
  }) {
    _ds.registrarEvento(
      tipo: TipoEventoSeguridad.accionGuia,
      descripcion:
          'INCIDENTE RESUELTO — Turista: $nombreTurista (ID: $turistaId) '
          '— Motivo original: $motivoOriginal',
      prioridad: 'INFO',
    );
  }

  /// Lee el log completo (más reciente primero)
  Future<List<EventoSeguridad>> leerBitacora() => _ds.leerEventos();

  /// Limpia el log (exportar antes de limpiar)
  Future<void> limpiarBitacora() => _ds.limpiar();
}
