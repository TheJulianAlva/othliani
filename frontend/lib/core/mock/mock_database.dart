import 'mock_models.dart';

class MockDatabase {
  static final MockDatabase _instance = MockDatabase._internal();
  factory MockDatabase() => _instance;
  MockDatabase._internal();

  final List<MockViaje> _viajes = [
    MockViaje(
      id: '204',
      destino: 'Centro Histórico CDMX',
      estado: EstadoViaje.EN_CURSO,
      turistasTotales: 15,
      idGuia: 'g1',
      latitudActual: 19.4326,
      longitudActual: -99.1332,
    ),
    MockViaje(
      id: '110',
      destino: 'Teotihuacán',
      estado: EstadoViaje.EN_CURSO,
      turistasTotales: 40,
      idGuia: 'g2',
      latitudActual: 19.6925,
      longitudActual: -98.8439,
    ),
    MockViaje(
      id: '305',
      destino: 'Nevado de Toluca',
      estado: EstadoViaje.PROGRAMADO,
      turistasTotales: 12,
      idGuia: 'g3',
      latitudActual: 19.108,
      longitudActual: -99.759,
    ),
    MockViaje(
      id: '401',
      destino: 'Cañón del Sumidero',
      estado: EstadoViaje.FINALIZADO,
      turistasTotales: 25,
      idGuia: 'g4',
      latitudActual: 16.835,
      longitudActual: -93.033,
    ),
  ];

  final List<MockAlerta> _alertas = [
    MockAlerta(
      id: 'A-01',
      idViaje: '204',
      nombreTurista: 'Ana G.',
      tipo: TipoAlerta.PANICO,
      hora: DateTime.now().subtract(const Duration(minutes: 5)),
      esCritica: true,
      mensaje: 'PÁNICO - Turista Ana G. activó SOS',
    ),
    MockAlerta(
      id: 'A-02',
      idViaje: '110',
      nombreTurista: 'Luis P.',
      tipo: TipoAlerta.LEJANIA,
      hora: DateTime.now().subtract(const Duration(minutes: 15)),
      esCritica: false,
      mensaje: 'ALEJAMIENTO - Luis P. fuera de rango (50m)',
    ),
  ];

  List<MockAlerta> get alertas => _alertas;
  List<MockViaje> get viajes => _viajes;

  // Returning comprehensive data structure for new DashboardData entity
  Future<Map<String, dynamic>> getDashboardFullData() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return {
      'viajes_activos':
          _viajes.where((v) => v.estado == EstadoViaje.EN_CURSO).length,
      'viajes_programados':
          _viajes.where((v) => v.estado == EstadoViaje.PROGRAMADO).length,
      'turistas_campo': _viajes
          .where((v) => v.estado == EstadoViaje.EN_CURSO)
          .fold(0, (sum, v) => sum + v.turistasTotales),
      'alertas_criticas': _alertas.where((a) => a.esCritica).length,
      'guias_offline': 2,
      'viajes_mapa':
          _viajes.where((v) => v.estado == EstadoViaje.EN_CURSO).toList(),
      'alertas_recientes': _alertas,
    };
  }
}
