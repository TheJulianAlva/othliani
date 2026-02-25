import 'package:latlong2/latlong.dart';
import 'package:frontend/features/agencia/trips/domain/entities/viaje.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CalculateRiskUseCase — "El Cerebro Analítico"
//
// Responsabilidad única: dado un tipo de grupo + dos posiciones GPS,
// determinar si el turista superó el radio de la geocerca.
//
// No depende de ningún repositorio ni cubit — es puro y testeable.
//
// Uso:
//   final uc = CalculateRiskUseCase();
//   final enRiesgo = uc.evaluarRiesgo(
//     posicionGuia: LatLng(19.4326, -99.1332),
//     posicionTurista: LatLng(19.4327, -99.1310),
//     tipoGrupo: TipoGrupo.escolar,
//   );
// ─────────────────────────────────────────────────────────────────────────────

class CalculateRiskUseCase {
  static const _distanceCalc = Distance();

  // ── 1) Radio permitido ────────────────────────────────────────────────────

  /// Devuelve el radio de la geocerca en metros según el [TipoGrupo].
  /// La fuente de verdad está en [TipoGrupo.radioMetros] para no duplicar.
  double obtenerRadioSeguro(TipoGrupo tipo) => tipo.radioMetros;

  // ── 2) Distancia real ─────────────────────────────────────────────────────

  /// Calcula la distancia exacta en metros entre el guía y el turista
  /// usando la fórmula de Haversine (integrada en latlong2).
  double calcularDistancia(LatLng posicionGuia, LatLng posicionTurista) =>
      _distanceCalc.as(LengthUnit.Meter, posicionGuia, posicionTurista);

  // ── 3) Veredicto ─────────────────────────────────────────────────────────

  /// Retorna `true` si el turista superó el radio permitido → ¡hay alerta!
  bool evaluarRiesgo({
    required LatLng posicionGuia,
    required LatLng posicionTurista,
    required TipoGrupo tipoGrupo,
  }) {
    final double radioPermitido = obtenerRadioSeguro(tipoGrupo);
    final double distanciaReal = calcularDistancia(
      posicionGuia,
      posicionTurista,
    );
    return distanciaReal > radioPermitido;
  }

  // ── 4) Batch: evalúa múltiples turistas a la vez ─────────────────────────

  /// Evalúa una lista de posiciones de turistas y retorna los índices
  /// que superaron el radio. Útil para el dashboard de la agencia.
  List<int> evaluarGrupo({
    required LatLng posicionGuia,
    required List<LatLng> posicionesTuristas,
    required TipoGrupo tipoGrupo,
  }) {
    final radio = obtenerRadioSeguro(tipoGrupo);
    return [
      for (int i = 0; i < posicionesTuristas.length; i++)
        if (calcularDistancia(posicionGuia, posicionesTuristas[i]) > radio) i,
    ];
  }

  /// Retorna la distancia + si está en riesgo en un solo resultado.
  RiskResult evaluarConDistancia({
    required LatLng posicionGuia,
    required LatLng posicionTurista,
    required TipoGrupo tipoGrupo,
  }) {
    final radio = obtenerRadioSeguro(tipoGrupo);
    final distancia = calcularDistancia(posicionGuia, posicionTurista);
    return RiskResult(
      distanciaMetros: distancia,
      radioPermitidoMetros: radio,
      enRiesgo: distancia > radio,
    );
  }
}

// ── DTO de resultado ──────────────────────────────────────────────────────────

class RiskResult {
  final double distanciaMetros;
  final double radioPermitidoMetros;
  final bool enRiesgo;

  const RiskResult({
    required this.distanciaMetros,
    required this.radioPermitidoMetros,
    required this.enRiesgo,
  });

  /// Porcentaje de la geocerca ocupado (1.0 = en el borde del radio).
  double get porcentajeOcupado =>
      (distanciaMetros / radioPermitidoMetros).clamp(0.0, double.infinity);

  @override
  String toString() =>
      'RiskResult(dist: ${distanciaMetros.toStringAsFixed(1)}m, '
      'radio: ${radioPermitidoMetros}m, enRiesgo: $enRiesgo)';
}
