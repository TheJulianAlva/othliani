import 'mock_models.dart';
// The file is at c:/Users/HP/Documents/OthliAni/othliani/frontend/lib/core/mock/mock_database.dart
// mock_models.dart is in the same directory.
// So import should be simply "mock_models.dart" or "package:..."

class MockDatabase {
  // Singleton
  static final MockDatabase _instance = MockDatabase._internal();
  factory MockDatabase() => _instance;
  MockDatabase._internal();

  // --- TABLAS SIMULADAS ---
  final List<MockViaje> _viajes = [
    MockViaje(
      id: '204',
      destino: 'Centro Histórico',
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
      longitudActual: -98.8437,
    ),
    MockViaje(
      id: '305',
      destino: 'Nevado de Toluca',
      estado: EstadoViaje.PROGRAMADO,
      turistasTotales: 12,
      idGuia: 'g3',
      latitudActual: 19.1083,
      longitudActual: -99.7611,
    ),
  ];

  final List<MockAlerta> _alertas = [
    MockAlerta(
      id: '1',
      idViaje: '204',
      nombreTurista: 'Ana G.',
      tipo: TipoAlerta.PANICO,
      hora: DateTime.now().subtract(const Duration(minutes: 5)),
      esCritica: true,
    ),
    MockAlerta(
      id: '2',
      idViaje: '110',
      nombreTurista: 'Luis P.',
      tipo: TipoAlerta.DESCONEXION,
      hora: DateTime.now().subtract(const Duration(minutes: 15)),
      esCritica: false,
    ),
  ];

  List<MockAlerta> get alertas => _alertas;
  List<MockViaje> get viajes => _viajes;

  // --- MÉTODOS CRUD (Simulando API) ---

  Future<Map<String, dynamic>> getDashboardStats() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return {
      'viajes_activos':
          _viajes.where((v) => v.estado == EstadoViaje.EN_CURSO).length,
      'turistas_campo': _viajes.fold(0, (sum, v) => sum + v.turistasTotales),
      'alertas_criticas': _alertas.where((a) => a.esCritica).length,
      'guias_offline': 1,
    };
  }
}
