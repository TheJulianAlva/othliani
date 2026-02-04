import '../../domain/entities/viaje.dart';
import '../../domain/entities/guia.dart';
import '../../domain/entities/turista.dart';
import '../../domain/entities/alerta.dart';
import 'mock_models.dart'; // Keep for backward compatibility during transition

class MockDatabase {
  static final MockDatabase _instance = MockDatabase._internal();
  factory MockDatabase() => _instance;
  MockDatabase._internal();

  // --- 1. LISTA DE GUÍAS (Usando Entity Guia) ---
  final List<Guia> _guias = [
    const Guia(
      id: 'G-01',
      nombre: 'Marcos Ruiz',
      status: 'EN_RUTA',
      viajesAsignados: 1,
    ),
    const Guia(
      id: 'G-02',
      nombre: 'Ana Paula G.',
      status: 'ONLINE',
      viajesAsignados: 0,
    ),
    const Guia(
      id: 'G-03',
      nombre: 'Pedro Sánchez',
      status: 'OFFLINE',
      viajesAsignados: 0,
    ),
    const Guia(
      id: 'G-04',
      nombre: 'Luisa Lane',
      status: 'OFFLINE',
      viajesAsignados: 0,
    ),
    const Guia(
      id: 'G-05',
      nombre: 'Carlos V.',
      status: 'ONLINE',
      viajesAsignados: 0,
    ),
    const Guia(
      id: 'G-06',
      nombre: 'Sofia R.',
      status: 'EN_RUTA',
      viajesAsignados: 1,
    ),
    const Guia(
      id: 'G-07',
      nombre: 'Jorge T.',
      status: 'ONLINE',
      viajesAsignados: 0,
    ),
    const Guia(
      id: 'G-08',
      nombre: 'Mariana L.',
      status: 'ONLINE',
      viajesAsignados: 0,
    ),
    const Guia(
      id: 'G-09',
      nombre: 'Roberto C.',
      status: 'EN_RUTA',
      viajesAsignados: 1,
    ),
    const Guia(
      id: 'G-10',
      nombre: 'Elena M.',
      status: 'ONLINE',
      viajesAsignados: 0,
    ),
  ];

  // --- 2. LISTA DE VIAJES (Usando Entity Viaje) ---
  final List<Viaje> _viajes = [
    // Viajes Activos (En Curso)
    const Viaje(
      id: '204',
      destino: 'Centro Histórico CDMX',
      estado: 'EN_CURSO',
      turistas: 15,
      latitud: 19.4326,
      longitud: -99.1332,
    ),
    const Viaje(
      id: '110',
      destino: 'Teotihuacán',
      estado: 'EN_CURSO',
      turistas: 40,
      latitud: 19.6925,
      longitud: -98.8439,
    ),

    // Viajes Futuros
    const Viaje(
      id: '305',
      destino: 'Nevado de Toluca',
      estado: 'PROGRAMADO',
      turistas: 12,
      latitud: 19.108,
      longitud: -99.759,
    ),
    const Viaje(
      id: '306',
      destino: 'Valle de Bravo',
      estado: 'PROGRAMADO',
      turistas: 8,
      latitud: 19.192,
      longitud: -100.131,
    ),
    const Viaje(
      id: '307',
      destino: 'Xochimilco',
      estado: 'PROGRAMADO',
      turistas: 20,
      latitud: 19.295,
      longitud: -99.099,
    ),
    const Viaje(
      id: '308',
      destino: 'Tepoztlán',
      estado: 'PROGRAMADO',
      turistas: 10,
      latitud: 18.986,
      longitud: -99.100,
    ),
    const Viaje(
      id: '309',
      destino: 'Taxco',
      estado: 'PROGRAMADO',
      turistas: 15,
      latitud: 18.556,
      longitud: -99.605,
    ),

    // Viajes Pasados
    const Viaje(
      id: '401',
      destino: 'Cañón del Sumidero',
      estado: 'FINALIZADO',
      turistas: 25,
      latitud: 16.835,
      longitud: -93.033,
    ),
  ];

  // --- 3. LISTA DE TURISTAS (Población Real) ---
  final List<Turista> _turistas = [
    // --- Grupo Viaje 204 (15 pax) ---
    // Turista Problemático (SOS)
    const Turista(
      id: 'T-01',
      nombre: 'Ana Gómez',
      viajeId: '204',
      status: 'SOS',
      bateria: 0.15,
      enCampo: true,
    ),
    // Turistas Normales
    const Turista(
      id: 'T-02',
      nombre: 'Juan Pérez',
      viajeId: '204',
      status: 'OK',
      bateria: 0.90,
      enCampo: true,
    ),
    const Turista(
      id: 'T-03',
      nombre: 'Carla M.',
      viajeId: '204',
      status: 'OK',
      bateria: 0.85,
      enCampo: true,
    ),
    const Turista(
      id: 'T-04',
      nombre: 'Luis R.',
      viajeId: '204',
      status: 'OK',
      bateria: 0.88,
      enCampo: true,
    ),
    // Rellenos para completar los 15 del viaje 204
    const Turista(
      id: 'T-04-5',
      nombre: 'Turista 204-5',
      viajeId: '204',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-04-6',
      nombre: 'Turista 204-6',
      viajeId: '204',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-04-7',
      nombre: 'Turista 204-7',
      viajeId: '204',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-04-8',
      nombre: 'Turista 204-8',
      viajeId: '204',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-04-9',
      nombre: 'Turista 204-9',
      viajeId: '204',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-04-10',
      nombre: 'Turista 204-10',
      viajeId: '204',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-04-11',
      nombre: 'Turista 204-11',
      viajeId: '204',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-04-12',
      nombre: 'Turista 204-12',
      viajeId: '204',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-04-13',
      nombre: 'Turista 204-13',
      viajeId: '204',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-04-14',
      nombre: 'Turista 204-14',
      viajeId: '204',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-04-15',
      nombre: 'Turista 204-15',
      viajeId: '204',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),

    // --- Grupo Viaje 110 (40 pax) ---
    // Turista con Advertencia (Alejamiento)
    const Turista(
      id: 'T-110-01',
      nombre: 'Luis P.',
      viajeId: '110',
      status: 'ADVERTENCIA',
      bateria: 0.30,
      enCampo: true,
    ),
    // Relleno
    const Turista(
      id: 'T-110-2',
      nombre: 'Turista 110-2',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-3',
      nombre: 'Turista 110-3',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-4',
      nombre: 'Turista 110-4',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-5',
      nombre: 'Turista 110-5',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-6',
      nombre: 'Turista 110-6',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-7',
      nombre: 'Turista 110-7',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-8',
      nombre: 'Turista 110-8',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-9',
      nombre: 'Turista 110-9',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-10',
      nombre: 'Turista 110-10',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-11',
      nombre: 'Turista 110-11',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-12',
      nombre: 'Turista 110-12',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-13',
      nombre: 'Turista 110-13',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-14',
      nombre: 'Turista 110-14',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-15',
      nombre: 'Turista 110-15',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-16',
      nombre: 'Turista 110-16',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-17',
      nombre: 'Turista 110-17',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-18',
      nombre: 'Turista 110-18',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-19',
      nombre: 'Turista 110-19',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-20',
      nombre: 'Turista 110-20',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-21',
      nombre: 'Turista 110-21',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-22',
      nombre: 'Turista 110-22',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-23',
      nombre: 'Turista 110-23',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-24',
      nombre: 'Turista 110-24',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-25',
      nombre: 'Turista 110-25',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-26',
      nombre: 'Turista 110-26',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-27',
      nombre: 'Turista 110-27',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-28',
      nombre: 'Turista 110-28',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-29',
      nombre: 'Turista 110-29',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-30',
      nombre: 'Turista 110-30',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-31',
      nombre: 'Turista 110-31',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-32',
      nombre: 'Turista 110-32',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-33',
      nombre: 'Turista 110-33',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-34',
      nombre: 'Turista 110-34',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-35',
      nombre: 'Turista 110-35',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-36',
      nombre: 'Turista 110-36',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-37',
      nombre: 'Turista 110-37',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-38',
      nombre: 'Turista 110-38',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-39',
      nombre: 'Turista 110-39',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),
    const Turista(
      id: 'T-110-40',
      nombre: 'Turista 110-40',
      viajeId: '110',
      status: 'OK',
      bateria: 0.95,
      enCampo: true,
    ),

    // --- Turistas Offline (Sin red, pero en campo) ---
    const Turista(
      id: 'T-OFF-1',
      nombre: 'Pepe L.',
      viajeId: '204',
      status: 'OFFLINE',
      bateria: 0.50,
      enCampo: true,
    ),
    const Turista(
      id: 'T-OFF-2',
      nombre: 'Maria S.',
      viajeId: '110',
      status: 'OFFLINE',
      bateria: 0.40,
      enCampo: true,
    ),
    const Turista(
      id: 'T-OFF-3',
      nombre: 'Jose K.',
      viajeId: '110',
      status: 'OFFLINE',
      bateria: 0.20,
      enCampo: true,
    ),
  ];

  // --- 4. LISTA DE ALERTAS (Usando Entity Alerta) ---
  final List<Alerta> _alertas = [
    Alerta(
      id: 'A-01',
      viajeId: '204',
      nombreTurista: 'Ana G.',
      tipo: 'PANICO',
      hora: DateTime.now().subtract(const Duration(minutes: 5)),
      esCritica: true,
      mensaje: 'PÁNICO - Turista Ana G. activó SOS',
    ),
    Alerta(
      id: 'A-02',
      viajeId: '110',
      nombreTurista: 'Luis P.',
      tipo: 'LEJANIA',
      hora: DateTime.now().subtract(const Duration(minutes: 15)),
      esCritica: false,
      mensaje: 'ALEJAMIENTO - Luis P. fuera de rango (50m)',
    ),
  ];

  // --- MÉTODOS API SIMULADOS ---

  // Obtener Datos Completos para el Dashboard (Calculados)
  Future<Map<String, dynamic>> getDashboardFullData() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Latencia

    // CÁLCULOS REALES BASADOS EN LAS LISTAS
    final viajesActivos = _viajes.where((v) => v.estado == 'EN_CURSO').toList();
    final viajesProgramados =
        _viajes.where((v) => v.estado == 'PROGRAMADO').length;

    // Contamos turistas reales cuyo status 'enCampo' es true
    final turistasEnCampo = _turistas.where((t) => t.enCampo).length;

    // Contamos turistas que tienen status OFFLINE
    final turistasSinRed = _turistas.where((t) => t.status == 'OFFLINE').length;

    // Contamos guías offline
    final guiasOffline = _guias.where((g) => g.status == 'OFFLINE').length;
    final guiasTotal = _guias.length;

    // Contamos alertas (basándonos en status SOS/ADVERTENCIA de turistas)
    final alertasCriticas = _alertas.where((a) => a.esCritica).length;

    return {
      // Data para KPIs
      'stats': {
        'viajes_activos': viajesActivos.length,
        'viajes_prog': viajesProgramados,

        'turistas_campo': turistasEnCampo,
        'turistas_sin_red': turistasSinRed,

        'alertas_criticas': alertasCriticas,

        'guias_total': guiasTotal,
        'guias_offline': guiasOffline,
      },
      // Listas completas para pintar mapas y tablas
      'active_trips': viajesActivos,
      'alertas_recientes': _alertas,
    };
  }

  // --- MÉTODOS API SIMULADOS (CRUD) ---

  // 1. Para Pantalla "Gestión de Viajes"
  Future<List<Viaje>> getAllViajes() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _viajes;
  }

  // 2. Para Pantalla "Detalle de Viaje" (Busca por ID)
  Future<Viaje?> getViajeById(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      return _viajes.firstWhere((v) => v.id == id);
    } catch (e) {
      return null;
    }
  }

  // 3. Para Pantalla "Usuarios"
  Future<List<Guia>> getAllGuias() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _guias;
  }

  // 4. Para Pantalla "Auditoría" - Keep MockLog for now
  Future<List<MockLog>> getAuditLogs() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final logs = [
      MockLog(
        'L-01',
        '2026-01-25 10:42',
        'CRT',
        'Sys_Algorithm',
        'Detectado Alejamiento',
      ),
      MockLog(
        'L-02',
        '2026-01-25 10:40',
        'INF',
        'Admin: Juan',
        'Modificó Geocerca',
      ),
      MockLog(
        'L-03',
        '2026-01-25 09:15',
        'WRN',
        'Guía: Marcos',
        'Pérdida Conexión',
      ),
    ];
    return logs;
  }

  // 5. Get Turistas by Viaje ID
  Future<List<Turista>> getTuristasByViajeId(String viajeId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _turistas.where((t) => t.viajeId == viajeId).toList();
  }

  // 6. Get Alertas by Viaje ID
  Future<List<Alerta>> getAlertasByViajeId(String viajeId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _alertas.where((a) => a.viajeId == viajeId).toList();
  }

  // 7. Simulate Trip Cancellation/Deletion
  Future<bool> simularDeleteViaje(String id) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // In a real app, this would make a DELETE request to the API
    // For the mock, we return true to simulate success
    // You could also remove the trip from _viajes list if you want to persist the change
    return true;
  }

  // Legacy getters for backward compatibility (will be removed)
  List<MockAlerta> get alertas =>
      _alertas
          .map(
            (a) => MockAlerta(
              id: a.id,
              idViaje: a.viajeId,
              nombreTurista: a.nombreTurista,
              tipo: a.tipo == 'PANICO' ? TipoAlerta.PANICO : TipoAlerta.LEJANIA,
              hora: a.hora,
              esCritica: a.esCritica,
              mensaje: a.mensaje,
            ),
          )
          .toList();

  List<MockViaje> get viajes =>
      _viajes
          .map(
            (v) => MockViaje(
              id: v.id,
              destino: v.destino,
              estado:
                  v.estado == 'EN_CURSO'
                      ? EstadoViaje.EN_CURSO
                      : v.estado == 'PROGRAMADO'
                      ? EstadoViaje.PROGRAMADO
                      : EstadoViaje.FINALIZADO,
              turistasTotales: v.turistas,
              idGuia: 'g1',
              latitudActual: v.latitud,
              longitudActual: v.longitud,
            ),
          )
          .toList();
}
