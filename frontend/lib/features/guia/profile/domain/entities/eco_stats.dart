// ─────────────────────────────────────────────────────────────────────────────
// EcoStats — Gamificación exclusiva para Guías Independientes (B2C)
//
// Una expedición "limpia" = viaje finalizado en el que el guía NO presionó
// SOS y el grupo mantuvo buena cobertura de geocerca.
// ─────────────────────────────────────────────────────────────────────────────

enum NivelEco {
  explorador, // Inicio: < 5 expediciones limpias
  bronce, // ≥ 5   expediciones limpias
  plata, // ≥ 20  expediciones limpias
  oro; // ≥ 50  expediciones limpias (máximo estatus)

  /// Etiqueta legible con emoji para la UI.
  String get etiqueta => switch (this) {
    NivelEco.explorador => '🌿 Explorador Ambiental',
    NivelEco.bronce => '🥉 Guía Consciente · BRONCE',
    NivelEco.plata => '🥈 Guía Responsable · PLATA',
    NivelEco.oro => '🥇 Guardián Verde · ORO',
  };

  /// Número de expediciones necesarias para ALCANZAR este nivel.
  int get umbral => switch (this) {
    NivelEco.explorador => 0,
    NivelEco.bronce => 5,
    NivelEco.plata => 20,
    NivelEco.oro => 50,
  };
}

class EcoStats {
  final int expedicionesLimpias; // Viajes sin SOS ni alertas críticas
  final double kgCo2Ahorrado; // Estimado: ~0.5 kg CO2 por km evitado en auto

  // Datos extra para UI expandida
  final int viajesConducidos; // Total de viajes (limpios + con incidentes)
  final double tasaExito; // expedicionesLimpias / viajesConducidos

  const EcoStats({
    required this.expedicionesLimpias,
    required this.kgCo2Ahorrado,
    this.viajesConducidos = 0,
    this.tasaExito = 1.0,
  });

  // ── Gamificación ────────────────────────────────────────────────────────────

  NivelEco get nivelActual {
    if (expedicionesLimpias >= 50) return NivelEco.oro;
    if (expedicionesLimpias >= 20) return NivelEco.plata;
    if (expedicionesLimpias >= 5) return NivelEco.bronce;
    return NivelEco.explorador;
  }

  /// Cuántas expediciones faltan para el siguiente nivel.
  /// Si ya es Oro, devuelve 0.
  int get expedicionesParaSiguienteNivel {
    return switch (nivelActual) {
      NivelEco.explorador => NivelEco.bronce.umbral - expedicionesLimpias,
      NivelEco.bronce => NivelEco.plata.umbral - expedicionesLimpias,
      NivelEco.plata => NivelEco.oro.umbral - expedicionesLimpias,
      NivelEco.oro => 0,
    };
  }

  /// Progreso dentro del nivel actual [0.0 → 1.0].
  double get progresoNivel {
    if (nivelActual == NivelEco.oro) return 1.0;

    final desde = nivelActual.umbral;
    final hasta = switch (nivelActual) {
      NivelEco.explorador => NivelEco.bronce.umbral,
      NivelEco.bronce => NivelEco.plata.umbral,
      NivelEco.plata => NivelEco.oro.umbral,
      NivelEco.oro => NivelEco.oro.umbral,
    };

    return ((expedicionesLimpias - desde) / (hasta - desde)).clamp(0.0, 1.0);
  }

  /// Nombre del siguiente nivel, null si ya es Oro.
  NivelEco? get siguienteNivel => switch (nivelActual) {
    NivelEco.explorador => NivelEco.bronce,
    NivelEco.bronce => NivelEco.plata,
    NivelEco.plata => NivelEco.oro,
    NivelEco.oro => null,
  };
}
