enum TipoAlerta { LEJANIA, DESCONEXION, PANICO }

enum EstadoViaje { PROGRAMADO, EN_CURSO, FINALIZADO }

class MockAgencia {
  final String id;
  final String nombre;
  final int licenciasTotales;
  final int licenciasUsadas;

  MockAgencia(
    this.id,
    this.nombre,
    this.licenciasTotales,
    this.licenciasUsadas,
  );
}

class MockGuia {
  final String id;
  final String nombre;
  final bool isOnline;
  final String idAgencia;

  MockGuia(
    this.id,
    this.nombre, {
    this.isOnline = false,
    required this.idAgencia,
  });
}

class MockViaje {
  final String id;
  final String destino;
  final EstadoViaje estado;
  final int turistasTotales;
  final String idGuia;
  final double latitudActual; // Para el mapa
  final double longitudActual;

  MockViaje({
    required this.id,
    required this.destino,
    required this.estado,
    required this.turistasTotales,
    required this.idGuia,
    required this.latitudActual,
    required this.longitudActual,
  });
}

class MockAlerta {
  final String id;
  final String idViaje;
  final String nombreTurista;
  final TipoAlerta tipo;
  final DateTime hora;
  final bool esCritica;

  MockAlerta({
    required this.id,
    required this.idViaje,
    required this.nombreTurista,
    required this.tipo,
    required this.hora,
    required this.esCritica,
  });
}
