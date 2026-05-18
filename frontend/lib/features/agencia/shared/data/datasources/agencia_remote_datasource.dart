import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

import 'package:frontend/core/session/agencia_session.dart';
import 'package:frontend/features/agencia/audit/domain/entities/log_auditoria.dart';
import 'package:frontend/features/agencia/dashboard/domain/entities/dashboard_data.dart';
import 'package:frontend/features/agencia/shared/data/datasources/agencia_datasource.dart';
import 'package:frontend/features/agencia/shared/data/datasources/mock_agencia_datasource.dart';
import 'package:frontend/features/agencia/shared/domain/entities/alerta.dart';
import 'package:frontend/features/agencia/trips/domain/entities/actividad_itinerario.dart';
import 'package:frontend/features/agencia/trips/domain/entities/viaje.dart';
import 'package:frontend/features/agencia/users/domain/entities/guia.dart';
import 'package:frontend/features/agencia/users/domain/entities/turista.dart';

/// Convierte un objeto ActividadInstancia del backend (JSON) a la entidad de dominio.
ActividadItinerario _actividadFromBackend(Map<String, dynamic> json) {
  return ActividadItinerario(
    id: json['id'] as String,
    titulo: json['nombre_actividad'] as String,
    descripcion: json['direccion'] as String? ?? '',
    horaInicio: DateTime.parse(json['hora_programada'] as String),
    horaFin: DateTime.parse(json['hora_fin'] as String),
    tipo: TipoActividad.visitaGuiada,
    radioGeocerca: (json['radio_geocerca_mts'] as num?)?.toDouble() ?? 100.0,
    ubicacionCentral: (json['lat'] != null && json['lng'] != null)
        ? LatLng(
            (json['lat'] as num).toDouble(),
            (json['lng'] as num).toDouble(),
          )
        : null,
  );
}

/// Convierte un Viaje del backend (JSON) a la entidad de dominio [Viaje].
Viaje _viajeFromBackend(Map<String, dynamic> json) {
  final actividades = (json['actividades'] as List<dynamic>? ?? [])
      .map((a) => _actividadFromBackend(a as Map<String, dynamic>))
      .toList();

  final participantes = json['participantes'] as List<dynamic>? ?? [];

  // Coordenadas: toma las de la primera actividad si existen
  double lat = 19.4326; // CDMX fallback
  double lng = -99.1332;
  if (actividades.isNotEmpty && actividades.first.ubicacionCentral != null) {
    lat = actividades.first.ubicacionCentral!.latitude;
    lng = actividades.first.ubicacionCentral!.longitude;
  }

  return Viaje(
    id: json['id'] as String,
    destino: json['nombre_viaje'] as String,
    estado: json['estado'] as String,
    fechaInicio: DateTime.parse(json['created_at'] as String),
    fechaFin: DateTime.parse(json['created_at'] as String).add(
      const Duration(days: 1),
    ),
    turistas: participantes.length,
    latitud: lat,
    longitud: lng,
    itinerario: actividades,
  );
}

/// DataSource remoto real. Llama al backend NestJS para viajes y delega
/// al mock para entidades que el backend aún no expone (guías, auditoría).
class AgenciaRemoteDataSource implements AgenciaDataSource {
  final Dio _dio;

  /// Mock como fallback para métodos sin endpoint real aún.
  final MockAgenciaDataSource _mock;

  AgenciaRemoteDataSource({
    required Dio dio,
    MockAgenciaDataSource? mock,
  })  : _dio = dio,
        _mock = mock ?? MockAgenciaDataSource();

  /// Lee el ID de la agencia desde la sesión activa en cada llamada.
  String get _agenciaId => AgenciaSession.instance.agenciaId;

  // ── Viajes ────────────────────────────────────────────────────────────────

  @override
  Future<List<Viaje>> getListaViajes() async {
    final response = await _dio.get('/viajes/agencia/$_agenciaId');
    final rawList = response.data as List<dynamic>;
    return rawList
        .map((v) => _viajeFromBackend(v as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Viaje?> getDetalleViaje(String id) async {
    final viajes = await getListaViajes();
    try {
      return viajes.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addViaje(Viaje viaje) async {
    // Crear viaje en el backend
    await _dio.post('/viajes', data: {
      'agencia_id': _agenciaId,
      'nombre_viaje': viaje.destino,
      'distancia_max_global': viaje.tipoGrupo.radioMetros.toInt(),
      'tiempo_desconexion_global': 15,
    });
  }

  @override
  Future<bool> simularDeleteViaje(String id) async {
    // Sin endpoint real de borrado aún — delegar al mock
    return _mock.simularDeleteViaje(id);
  }

  // ── Dashboard ─────────────────────────────────────────────────────────────

  @override
  Future<DashboardData> getDashboardData() async {
    final viajes = await getListaViajes();
    final activos = viajes.where((v) => v.estado == 'EN_CURSO').length;
    final programados = viajes.where((v) => v.estado == 'PROGRAMADO').length;
    final totalTuristas = viajes.fold<int>(0, (sum, v) => sum + v.turistas);

    return DashboardData(
      viajesActivos: activos,
      viajesProgramados: programados,
      turistasEnCampo: totalTuristas,
      turistasSinRed: 0,
      alertasCriticas: 0,
      guiasOffline: 0,
      guiasTotal: 0,
      viajesEnMapa: viajes,
      alertasRecientes: const <Alerta>[],
    );
  }

  // ── Guías / Turistas / Auditoría — delegados al mock por ahora ───────────

  @override
  Future<List<Guia>> getListaGuias() => _mock.getAllGuias();

  @override
  Future<List<Guia>> getGuias() => _mock.getAllGuias();

  @override
  Future<List<Turista>> getTuristas() => _mock.getAllTuristas();

  @override
  Future<List<Turista>> getTuristasByViajeId(String viajeId) =>
      _mock.getTuristasByViajeId(viajeId);

  @override
  Future<List<LogAuditoria>> getAuditLogs() => _mock.getAuditLogs();
}
