import 'package:frontend/features/agencia/trips/domain/entities/viaje.dart';
import 'package:frontend/features/guia/home/domain/repositories/sucesion_mando_repository.dart';
import 'package:frontend/features/guia/trips/domain/services/caja_negra_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SucesionMandoUseCase — "El Cerebro de la Redundancia Operativa"
//
// Decide QUÉ hacer y A QUIÉN avisar cuando el guía principal activa SOS,
// dependiendo del modelo de negocio del viaje (B2B vs. B2C):
//
//   B2B (Agencia) → Push al Co-Guía en campo (transferirMandoAgencia)
//                   Fallback: POST HTTP al dashboard de la agencia
//
//   B2C (Personal) → SMS con link de Google Maps al Contacto de Confianza
//                    Fallback: marcar 911 local
//
// Devuelve [ResultadoSucesion] con el mensajeUI para mostrar en pantalla.
// ─────────────────────────────────────────────────────────────────────────────

/// Resultado de la ejecución del protocolo de sucesión.
/// Llevado en [SosActive] para que la pantalla muestre exactamente qué ocurrió.
class ResultadoSucesion {
  final String mensajeUI; // Texto principal para el guía
  final String? sucesorNombre; // Nombre del sucesor si aplica
  final bool haySuccesor; // Si se encontró alguien a quien avisar

  const ResultadoSucesion({
    required this.mensajeUI,
    this.sucesorNombre,
    this.haySuccesor = true,
  });
}

class SucesionMandoUseCase {
  final CajaNegraService _cajaNegraService;
  final SucesionMandoRepository _repository;

  SucesionMandoUseCase({
    CajaNegraService? cajaNegraService,
    required SucesionMandoRepository repository,
  }) : _cajaNegraService = cajaNegraService ?? CajaNegraService(),
       _repository = repository;

  // ── API pública ─────────────────────────────────────────────────────────────

  /// Ejecuta el protocolo correcto según el [TipoViaje] del viaje activo.
  ///
  /// [lat] y [lng] son la última posición conocida del guía, usadas para
  /// construir el link de Google Maps en el flujo B2C y para el payload B2B.
  Future<ResultadoSucesion> ejecutarProtocolo(
    Viaje viajeActual,
    double lat,
    double lng,
  ) async {
    return switch (viajeActual.tipoViaje) {
      TipoViaje.agencia => _protocoloAgencia(viajeActual, lat, lng),
      TipoViaje.personal => _protocoloPersonal(viajeActual, lat, lng),
    };
  }

  // ── B2B: Agencia ────────────────────────────────────────────────────────────

  Future<ResultadoSucesion> _protocoloAgencia(
    Viaje viaje,
    double lat,
    double lng,
  ) async {
    if (viaje.coGuiasIds.isNotEmpty) {
      final sucesorId = viaje.coGuiasIds.first;

      // ✅ IMPLEMENTADO: Push FCM simulado al Co-Guía (via SharedPreferences + Clipboard)
      // En producción → FCM data message con action:"ASUMIR_MANDO"
      await _repository.transferirMandoAgencia(
        sucesorId: sucesorId,
        sucesorNombre: 'Co-Guía ($sucesorId)',
        viajeId: viaje.id,
      );

      _cajaNegraService.registrarIncidente(
        nombreTurista: 'GUÍA PRINCIPAL',
        prioridad: 'CRITICA',
        accionRealizada:
            '✅ Push enviado → Co-Guía ID: $sucesorId (Viaje ${viaje.id})',
      );

      return ResultadoSucesion(
        mensajeUI:
            '📲 Mando transferido al Co-Guía.\n'
            'ID: $sucesorId\n\n'
            'La central de la agencia fue notificada.\n'
            'El Co-Guía asumirá el control del grupo.',
        sucesorNombre: 'Co-Guía ($sucesorId)',
        haySuccesor: true,
      );
    } else {
      // ✅ IMPLEMENTADO: POST HTTP simulado al dashboard (via SharedPreferences + Clipboard)
      // En producción → dio.post('/api/agencia/alertas/sos', data: payload)
      await _repository.notificarDashboardAgencia(
        viajeId: viaje.id,
        lat: lat,
        lng: lng,
      );

      _cajaNegraService.registrarIncidente(
        nombreTurista: 'GUÍA PRINCIPAL',
        prioridad: 'CRITICA',
        accionRealizada:
            '✅ POST enviado al dashboard de agencia — sin co-guía disponible (Viaje ${viaje.id})',
      );

      return const ResultadoSucesion(
        mensajeUI:
            '🏢 Sin co-guía disponible.\n\n'
            'La central de la agencia fue notificada directamente.\n'
            'Un coordinador asumirá el control remoto.',
        haySuccesor: false,
      );
    }
  }

  // ── B2C: Personal ───────────────────────────────────────────────────────────

  Future<ResultadoSucesion> _protocoloPersonal(
    Viaje viaje,
    double lat,
    double lng,
  ) async {
    if (viaje.contactosConfianza.isNotEmpty) {
      final contacto = viaje.contactosConfianza.first;

      // ✅ IMPLEMENTADO: SMS simulado via SharedPreferences + Clipboard
      // En producción → Twilio API / AWS SNS
      await _repository.enviarSmsEmergencia(
        telefono: contacto.telefono,
        nombreContacto: contacto.nombre,
        lat: lat,
        lng: lng,
      );

      _cajaNegraService.registrarIncidente(
        nombreTurista: 'GUÍA PRINCIPAL',
        prioridad: 'CRITICA',
        accionRealizada:
            '✅ SMS enviado a ${contacto.nombre} (${contacto.telefono}) — '
            'https://maps.google.com/?q=$lat,$lng',
      );

      return ResultadoSucesion(
        mensajeUI:
            '📩 SMS de emergencia enviado a:\n'
            '${contacto.nombre}\n'
            '${contacto.telefono}\n\n'
            'Tu ubicación GPS fue compartida.\n'
            'Mantén la calma. Auxilio en camino.',
        sucesorNombre: contacto.nombre,
        haySuccesor: true,
      );
    } else {
      // ✅ IMPLEMENTADO: Protocolo 911 simulado via Clipboard
      // En producción → url_launcher: launchUrl(Uri.parse('tel:911'))
      await _repository.marcarProtocolo911(lat: lat, lng: lng);

      _cajaNegraService.registrarIncidente(
        nombreTurista: 'GUÍA PRINCIPAL',
        prioridad: 'CRITICA',
        accionRealizada:
            '✅ Protocolo 911 activado — sin contacto de confianza registrado',
      );

      return const ResultadoSucesion(
        mensajeUI:
            '🚨 Sin Contacto de Confianza registrado.\n\n'
            'Se activó el protocolo de emergencias locales.\n'
            'Número copiado al portapapeles: 911',
        haySuccesor: false,
      );
    }
  }
}
