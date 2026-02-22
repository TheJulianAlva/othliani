import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/entities/eco_stats.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EcoStatsService — Calcula y persiste las estadísticas de gamificación B2C
//
// Fuentes de datos (en orden de prioridad):
//   1. SharedPreferences: clave 'sucesion_sms_enviados'  → indica viajes B2C
//   2. SharedPreferences: clave 'ECO_STATS_CACHE'        → datos persistidos
//   3. Mock hardcoded con datos realistas para el demo
// ─────────────────────────────────────────────────────────────────────────────

class EcoStatsService {
  static const _keyCache = 'ECO_STATS_CACHE';
  static const _keyViajesLimpios = 'ECO_VIAJES_LIMPIOS';

  // ── API pública ─────────────────────────────────────────────────────────────

  /// Obtiene las estadísticas eco del guía actual.
  /// Lee la CajaNegraService (via SharedPreferences) para calcular viajes limpios.
  Future<EcoStats> obtenerStats() async {
    final prefs = await SharedPreferences.getInstance();

    // Leemos cuántos viajes limpios se han guardado manualmente
    final viajesLimpios =
        prefs.getInt(_keyViajesLimpios) ?? _mockExpedicionesLimpias;
    final cached = prefs.getString(_keyCache);

    // Si hay caché y corresponde al mismo número de viajes, usamos caché
    if (cached != null) {
      try {
        final map = jsonDecode(cached) as Map<String, dynamic>;
        if ((map['expedicionesLimpias'] as int?) == viajesLimpios) {
          return EcoStats(
            expedicionesLimpias: map['expedicionesLimpias'] as int,
            kgCo2Ahorrado: (map['kgCo2Ahorrado'] as num).toDouble(),
            viajesConducidos: map['viajesConducidos'] as int? ?? viajesLimpios,
            tasaExito: (map['tasaExito'] as num?)?.toDouble() ?? 1.0,
          );
        }
      } catch (_) {
        // Caché corrupto — recalculamos
      }
    }

    // Recalcular y persistir
    final stats = _calcularStats(viajesLimpios);
    await _persistirStats(prefs, stats);
    return stats;
  }

  /// Registra una nueva expedición limpia (sin SOS, sin alertas críticas).
  /// Llamar al finalizar un viaje sin incidentes.
  Future<EcoStats> registrarExpedicionLimpia() async {
    final prefs = await SharedPreferences.getInstance();
    final actual = prefs.getInt(_keyViajesLimpios) ?? _mockExpedicionesLimpias;
    await prefs.setInt(_keyViajesLimpios, actual + 1);
    await prefs.remove(_keyCache); // invalida caché
    return obtenerStats();
  }

  /// Resetea a los datos mock (útil para demo/testing).
  Future<void> resetearAMock() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyViajesLimpios);
    await prefs.remove(_keyCache);
  }

  // ── Privados ────────────────────────────────────────────────────────────────

  // Datos mock: Pedro Sánchez, guía independiente con 24 expediciones limpias,
  // equivalente al nivel PLATA (≥20 < 50). A 26 expediciones del ORO.
  static const int _mockExpedicionesLimpias = 24;

  EcoStats _calcularStats(int expedicionesLimpias) {
    // Estimación CO2: cada expedición promedio recorre ~40 km.
    // Si el grupo va en transporte colectivo versus autos individuales,
    // se ahorran ~0.18 kg CO2/km por persona × 8 personas promedio = 1.44 kg/km
    // → 40 km × 1.44 = 57.6 kg/expedición. Usamos estimado conservador: ~0.6 kg/exp.
    final kgCo2 = expedicionesLimpias * 0.6;

    // Tasa de éxito: asumimos que ~15% de viajes tienen algún incidente menor
    final viajesConducidos = (expedicionesLimpias / 0.85).round();
    final tasaExito = expedicionesLimpias / viajesConducidos.clamp(1, 9999);

    return EcoStats(
      expedicionesLimpias: expedicionesLimpias,
      kgCo2Ahorrado: double.parse(kgCo2.toStringAsFixed(1)),
      viajesConducidos: viajesConducidos,
      tasaExito: double.parse(tasaExito.toStringAsFixed(2)),
    );
  }

  Future<void> _persistirStats(SharedPreferences prefs, EcoStats stats) async {
    await prefs.setString(
      _keyCache,
      jsonEncode({
        'expedicionesLimpias': stats.expedicionesLimpias,
        'kgCo2Ahorrado': stats.kgCo2Ahorrado,
        'viajesConducidos': stats.viajesConducidos,
        'tasaExito': stats.tasaExito,
      }),
    );
  }
}
