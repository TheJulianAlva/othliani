import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/incident_log.dart';

const String _kCajaNegraKey = 'ohtliani_caja_negra_logs';

class CajaNegraLocalDataSource {
  final SharedPreferences prefs;

  CajaNegraLocalDataSource(this.prefs);

  /// Agrega un nuevo evento a la caja negra de forma inalterable
  Future<void> registrarEvento(IncidentLog log) async {
    // 1. Obtenemos los logs anteriores
    final List<String> logsActuales = prefs.getStringList(_kCajaNegraKey) ?? [];

    // 2. Agregamos el nuevo
    logsActuales.add(jsonEncode(log.toJson()));

    // 3. Guardamos de nuevo (Sobrescribimos la lista completa)
    await prefs.setStringList(_kCajaNegraKey, logsActuales);

    developer.log(
      "Evento registrado offline: ${log.descripcion}",
      name: "CAJA_NEGRA",
    );
  }

  /// Obtiene toda la evidencia del día
  Future<List<IncidentLog>> obtenerEvidencia() async {
    final List<String> logsGuardados =
        prefs.getStringList(_kCajaNegraKey) ?? [];

    return logsGuardados
        .map((str) => IncidentLog.fromJson(jsonDecode(str)))
        .toList()
      ..sort(
        (a, b) => b.timestamp.compareTo(a.timestamp),
      ); // Más recientes primero
  }

  /// Limpia la caja negra (SOLO DEBE LLAMARSE CUANDO EL VIAJE TERMINA Y SE SUBIÓ AL SERVIDOR)
  Future<void> limpiarCajaNegraLocal() async {
    await prefs.remove(_kCajaNegraKey);
    developer.log("Vaciada tras sincronización exitosa.", name: "CAJA_NEGRA");
  }
}
