import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SucesionMandoLocalService — Simulador de comunicaciones externas
//
// En producción, estas funciones llamarían a:
//   - transferirMandoAgencia  → FCM Push al dispositivo del Co-Guía
//   - notificarDashboardAgencia → HTTP POST al endpoint de la agencia
//   - enviarSmsEmergencia      → API Twilio / AWS SNS
//   - marcarProtocolo911       → url_launcher tel:<número>
//
// En DEMO/Simulación, cada acción:
//   1. Persiste el payload en SharedPreferences (log auditable)
//   2. Copia el mensaje al portapapeles (visible en el dispositivo real)
//   3. Simula un delay de red realista (0.5–1.5 s)
// ─────────────────────────────────────────────────────────────────────────────

class SucesionMandoLocalService {
  static const _keyTransferencias = 'sucesion_transferencias';
  static const _keyDashboard = 'sucesion_dashboard_alerts';
  static const _keySms = 'sucesion_sms_enviados';
  static const _keyEmergencias = 'sucesion_emergencias_911';

  // ── B2B: transferir mando al Co-Guía ──────────────────────────────────────

  /// Simula un /push/ al Co-Guía para que su app despierte en modo "Guía Principal".
  /// En producción → FCM `data` message con action:"ASUMIR_MANDO" al token del Co-Guía.
  Future<void> transferirMandoAgencia({
    required String sucesorId,
    required String sucesorNombre,
    required String viajeId,
  }) async {
    await Future.delayed(
      const Duration(milliseconds: 700),
    ); // Simula latencia FCM

    final payload = {
      'action': 'ASUMIR_MANDO',
      'sucesorId': sucesorId,
      'sucesorNombre': sucesorNombre,
      'viajeId': viajeId,
      'timestamp': DateTime.now().toIso8601String(),
      'estado': 'ENVIADO_SIMULADO',
    };

    await _appendLog(_keyTransferencias, payload);

    // Copia el payload al portapapeles para que sea visible en demo
    await Clipboard.setData(
      ClipboardData(
        text:
            '📲 [PUSH SIMULADO → Co-Guía $sucesorNombre]\n'
            'action: ASUMIR_MANDO\n'
            'viajeId: $viajeId\n'
            'timestamp: ${payload['timestamp']}',
      ),
    );
  }

  // ── B2B: notificar dashboard de la agencia ────────────────────────────────

  /// Simula un POST HTTP al endpoint de alertas del dashboard de la agencia.
  /// En producción → dio.post('/api/agencia/alertas/sos', data: payload)
  Future<void> notificarDashboardAgencia({
    required String viajeId,
    required double lat,
    required double lng,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simula HTTP POST

    final payload = {
      'tipo': 'SOS_GUIA_PRINCIPAL_INCAPACITADO',
      'viajeId': viajeId,
      'lat': lat,
      'lng': lng,
      'mapsLink': 'https://maps.google.com/?q=$lat,$lng',
      'timestamp': DateTime.now().toIso8601String(),
      'estado': 'RECIBIDO_SIMULADO',
    };

    await _appendLog(_keyDashboard, payload);

    await Clipboard.setData(
      ClipboardData(
        text:
            '🏢 [HTTP POST SIMULADO → Dashboard Agencia]\n'
            'tipo: SOS_GUIA_PRINCIPAL_INCAPACITADO\n'
            'viajeId: $viajeId\n'
            'ubicación: ${payload['mapsLink']}',
      ),
    );
  }

  // ── B2C: enviar SMS de emergencia ──────────────────────────────────────────

  /// Simula el envío de un SMS al contacto de confianza con el link de ubicación.
  /// En producción → Twilio API: POST /2010-04-01/Accounts/{SID}/Messages
  Future<void> enviarSmsEmergencia({
    required String telefono,
    required String nombreContacto,
    required double lat,
    required double lng,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1200)); // Simula API SMS

    final mapsLink = 'https://maps.google.com/?q=$lat,$lng';
    final mensajeSms =
        'EMERGENCIA OHTLIANI 🆘\n'
        'El guía ha emitido un SOS.\n'
        'Última ubicación conocida:\n'
        '$mapsLink\n'
        'Hora: ${_horaActual()}';

    final payload = {
      'to': telefono,
      'contacto': nombreContacto,
      'body': mensajeSms,
      'timestamp': DateTime.now().toIso8601String(),
      'estado': 'ENVIADO_SIMULADO',
    };

    await _appendLog(_keySms, payload);

    // En demo: copia el SMS al portapapeles — en un dispositivo real se podría
    // abrir la app de SMS con url_launcher('sms:$telefono?body=$mensajeSms')
    await Clipboard.setData(
      ClipboardData(
        text: '📩 [SMS SIMULADO → $nombreContacto ($telefono)]\n$mensajeSms',
      ),
    );
  }

  // ── B2C: protocolo 911 / emergencias locales ──────────────────────────────

  /// Simula la apertura del marcador con el número de emergencias.
  /// En producción → url_launcher: launchUrl(Uri.parse('tel:911'))
  Future<void> marcarProtocolo911({
    required double lat,
    required double lng,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final payload = {
      'accion': 'LLAMAR_911',
      'lat': lat,
      'lng': lng,
      'timestamp': DateTime.now().toIso8601String(),
      'estado': 'INTENTO_SIMULADO',
    };

    await _appendLog(_keyEmergencias, payload);

    // Copia el número + link al portapapeles (en demo, el guía puede marcarlo manualmente)
    await Clipboard.setData(
      ClipboardData(
        text:
            '🚨 [LLAMADA SIMULADA → 911]\n'
            'Ubicación del guía: https://maps.google.com/?q=$lat,$lng\n'
            'En producción este botón abriría el marcador del teléfono.',
      ),
    );
  }

  // ── Utilidades ─────────────────────────────────────────────────────────────

  /// Recupera todos los logs de transferencias (para auditoría/debug).
  Future<List<Map<String, dynamic>>> obtenerLogsTransferencias() async =>
      _readLogs(_keyTransferencias);

  /// Recupera todos los SMS enviados (para auditoría/debug).
  Future<List<Map<String, dynamic>>> obtenerLogsSms() async =>
      _readLogs(_keySms);

  // ── Privados ────────────────────────────────────────────────────────────────

  Future<void> _appendLog(String key, Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(key);
    final List<dynamic> lista =
        existing != null ? jsonDecode(existing) as List : [];
    lista.add(payload);
    await prefs.setString(key, jsonEncode(lista));
  }

  Future<List<Map<String, dynamic>>> _readLogs(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return [];
    final lista = jsonDecode(raw) as List;
    return lista.cast<Map<String, dynamic>>();
  }

  String _horaActual() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
