import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EventoSeguridad — unidad mínima de registro en la Caja Negra
// ─────────────────────────────────────────────────────────────────────────────

enum TipoEventoSeguridad {
  inicioProteccion,
  finProteccion,
  alertaAlejamiento,
  sosManual,
  accionGuia, // cancelación con deslizador
  sincronizacion;

  String get etiqueta => switch (this) {
    TipoEventoSeguridad.inicioProteccion => 'INICIO PROTECCIÓN',
    TipoEventoSeguridad.finProteccion => 'FIN PROTECCIÓN',
    TipoEventoSeguridad.alertaAlejamiento => 'ALERTA ALEJAMIENTO',
    TipoEventoSeguridad.sosManual => 'SOS MANUAL',
    TipoEventoSeguridad.accionGuia => 'ACCIÓN GUÍA',
    TipoEventoSeguridad.sincronizacion => 'SINCRONIZACIÓN',
  };
}

class EventoSeguridad {
  final String id;
  final DateTime timestamp;
  final TipoEventoSeguridad tipo;

  /// 'CRITICA' | 'ESTANDAR' | 'INFO'
  final String prioridad;
  final String descripcion;

  /// Coordenadas GPS en formato 'lat,lng', vacío si no aplica.
  final String coordenadas;

  /// false mientras no se sincronice con el servidor de OhtliAni.
  final bool sincronizado;

  const EventoSeguridad({
    required this.id,
    required this.timestamp,
    required this.tipo,
    required this.prioridad,
    required this.descripcion,
    this.coordenadas = '',
    this.sincronizado = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'tipo': tipo.name,
    'prioridad': prioridad,
    'descripcion': descripcion,
    'coordenadas': coordenadas,
    'sincronizado': sincronizado ? 1 : 0,
  };

  factory EventoSeguridad.fromMap(Map<String, dynamic> m) => EventoSeguridad(
    id: m['id'] as String,
    timestamp: DateTime.parse(m['timestamp'] as String),
    tipo: TipoEventoSeguridad.values.firstWhere(
      (e) => e.name == m['tipo'],
      orElse: () => TipoEventoSeguridad.accionGuia,
    ),
    prioridad: m['prioridad'] as String,
    descripcion: m['descripcion'] as String,
    coordenadas: m['coordenadas'] as String? ?? '',
    sincronizado: (m['sincronizado'] as int? ?? 0) == 1,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// CajaNegraLocalDataSource
//
// Persiste eventos de seguridad en SharedPreferences como lista JSON.
// Las escrituras se hacen de forma fire-and-forget (unawaited) para no
// bloquear la UI durante una emergencia.
//
// Capacidad máxima: 500 eventos (FIFO). Suficiente para ≈30 expediciones.
// ─────────────────────────────────────────────────────────────────────────────

class CajaNegraLocalDataSource {
  static const String _clave = 'CAJA_NEGRA_EVENTOS';
  static const int _maxEventos = 500;

  /// Instancia singleton lazy — compartida en toda la sesión.
  static final CajaNegraLocalDataSource _instance =
      CajaNegraLocalDataSource._();
  factory CajaNegraLocalDataSource() => _instance;
  CajaNegraLocalDataSource._();

  // ── API pública ────────────────────────────────────────────────────────────

  /// Registra un evento. Fire-and-forget: no await necesario en UI crítica.
  Future<void> registrarEvento({
    required TipoEventoSeguridad tipo,
    required String descripcion,
    String prioridad = 'INFO',
    String coordenadas = '',
  }) async {
    final evento = EventoSeguridad(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      tipo: tipo,
      prioridad: prioridad,
      descripcion: descripcion,
      coordenadas: coordenadas,
    );

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_clave) ?? [];

    // FIFO: elimina los más antiguos si se supera el límite
    while (raw.length >= _maxEventos) {
      raw.removeAt(0);
    }

    raw.add(json.encode(evento.toMap()));
    await prefs.setStringList(_clave, raw);
  }

  /// Lee todos los eventos, ordenados del más reciente al más antiguo.
  Future<List<EventoSeguridad>> leerEventos() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_clave) ?? [];
    return raw
        .map(
          (s) =>
              EventoSeguridad.fromMap(json.decode(s) as Map<String, dynamic>),
        )
        .toList()
        .reversed
        .toList();
  }

  /// Elimina todos los registros (útil para exportar + limpiar).
  Future<void> limpiar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_clave);
  }
}
