import 'mock_models.dart';

class MockDatabase {
  // Singleton instance
  static final MockDatabase _instance = MockDatabase._internal();
  factory MockDatabase() => _instance;
  MockDatabase._internal() {
    _inicializarDatos();
  }

  // Listas que simulan las tablas de PostgreSQL
  List<MockAgencia> agencias = [];
  List<MockGuia> guias = [];
  List<MockViaje> viajes = [];
  List<MockAlerta> alertas = [];

  void _inicializarDatos() {
    // 1. Crear Agencia Demo
    agencias.add(MockAgencia('AG-001', 'Othliani Adventures', 15, 12));

    // 2. Crear Guías (10 en total como en tu captura)
    guias.add(
      MockGuia('G-001', 'Marcos R.', isOnline: true, idAgencia: 'AG-001'),
    );
    guias.add(
      MockGuia('G-002', 'Ana Paula', isOnline: true, idAgencia: 'AG-001'),
    );
    // ... añadir 8 más ficticios si quieres
    for (int i = 3; i <= 10; i++) {
      guias.add(
        MockGuia(
          'G-00$i',
          'Guía #$i',
          isOnline: i % 2 == 0,
          idAgencia: 'AG-001',
        ),
      );
    }

    // 3. Crear Viajes (Simulando la ubicación en CDMX de tu captura)
    viajes.add(
      MockViaje(
        id: '204',
        destino: 'Centro Histórico',
        estado: EstadoViaje.EN_CURSO,
        turistasTotales: 15,
        idGuia: 'G-001',
        latitudActual: 19.4326,
        longitudActual: -99.1332,
      ),
    );

    viajes.add(
      MockViaje(
        id: '110',
        destino: 'Teotihuacán',
        estado: EstadoViaje.EN_CURSO,
        turistasTotales: 40,
        idGuia: 'G-002',
        latitudActual: 19.6925,
        longitudActual: -98.8439,
      ),
    );

    // 4. Crear Alertas (Lo que se ve en el Panel de Incidentes)
    alertas.add(
      MockAlerta(
        id: 'ALT-01',
        idViaje: '204',
        nombreTurista: 'Ana G.',
        tipo: TipoAlerta.PANICO,
        hora: DateTime.now().subtract(const Duration(minutes: 5)),
        esCritica: true,
      ),
    );

    alertas.add(
      MockAlerta(
        id: 'ALT-02',
        idViaje: '110',
        nombreTurista: 'Luis P.',
        tipo: TipoAlerta.LEJANIA,
        hora: DateTime.now().subtract(const Duration(minutes: 12)),
        esCritica: false,
      ),
    );
  }

  // --- MÉTODOS SIMULADOS DE API (Services) ---

  // Obtener Dashboard Stats
  Map<String, dynamic> getDashboardStats() {
    int viajesActivos =
        viajes.where((v) => v.estado == EstadoViaje.EN_CURSO).length;
    int turistasEnCampo = viajes.fold(0, (sum, v) => sum + v.turistasTotales);
    int alertasCriticas = alertas.where((a) => a.esCritica).length;
    int guiasOnline = guias.where((g) => g.isOnline).length;

    return {
      'viajes': viajesActivos + 5, // +5 programados ficticios
      'turistas': turistasEnCampo,
      'alertas': alertasCriticas,
      'guias': guiasOnline,
    };
  }
}
