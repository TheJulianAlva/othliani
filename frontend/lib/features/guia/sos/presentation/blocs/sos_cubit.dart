import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/agencia/trips/domain/entities/viaje.dart';
import 'package:frontend/features/guia/home/domain/usecases/sucesion_mando_usecase.dart';
import 'package:frontend/core/services/location_service.dart';
import 'package:frontend/core/di/service_locator.dart';
import 'package:uuid/uuid.dart';
import 'package:frontend/features/guia/trips/domain/entities/incident_log.dart';
import 'package:frontend/features/guia/trips/data/datasources/caja_negra_local_datasource.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SosCubit — manejador del Pre-aviso SOS de 30 segundos
//
// Flujo:
//   SosIdle ──triggerWarning()──► SosWarning(30) ──(tick)──► SosWarning(29)…
//   SosWarning ──cancelSos()──► SosIdle
//   SosWarning(0) ──────────────────────────────────────────► SosActive
//   SosActive ──declararResuelto()──────────────────────────► SosIdle
// ─────────────────────────────────────────────────────────────────────────────

abstract class SosState {
  const SosState();
}

/// Estado normal — la app funciona sin alerta.
class SosIdle extends SosState {
  const SosIdle();
}

/// Pre-aviso naranja: el guía tiene [secondsLeft] segundos para cancelar.
class SosWarning extends SosState {
  final int secondsLeft;
  const SosWarning(this.secondsLeft);
}

/// SOS real enviado — la central fue notificada.
/// Lleva el [resultado] del protocolo de Sucesión de Mando ejecutado.
class SosActive extends SosState {
  /// Qué ocurrió y a quién se avisó. Null si el SOS fue activado
  /// manualmente antes de completar el protocolo.
  final ResultadoSucesion? resultado;
  const SosActive({this.resultado});
}

// ─────────────────────────────────────────────────────────────────────────────

class SosCubit extends Cubit<SosState> {
  Timer? _timer;

  /// Segundos del pre-aviso antes de disparar el SOS real.
  static const int _preAvisoSegundos = 30;

  /// Viaje activo — proporciona contexto para la Sucesión de Mando.
  /// Opcional: si es null, [SosActive] se emite sin protocolo de sucesión.
  final Viaje? viajeActivo;

  /// UseCase que decide a quién y cómo avisar según el modelo del viaje.
  final SucesionMandoUseCase _sucesionMandoUseCase;

  /// Servicio que envuelve la geolocalización (con un timeout de 5s)
  final LocationService _locationService;

  /// Audit Trail inalterable (Caja Negra legal)
  final CajaNegraLocalDataSource cajaNegra;

  SosCubit({
    this.viajeActivo,
    SucesionMandoUseCase? sucesionMandoUseCase,
    LocationService? locationService,
    CajaNegraLocalDataSource? cajaNegraRef,
  }) : _sucesionMandoUseCase =
           sucesionMandoUseCase ?? SucesionMandoUseCase(repository: sl()),
       _locationService = locationService ?? LocationService(),
       cajaNegra = cajaNegraRef ?? sl<CajaNegraLocalDataSource>(),
       super(const SosIdle());

  // ── Método interno de Log Legal ────────────────────────────────────────────

  Future<void> _registrarLog(TipoIncidente tipo, String descripcion) async {
    // Intentar obtener posición real rápida. Si falla, fallback.
    double lat = 19.4326;
    double lng = -99.1332;
    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        lat = position.latitude;
        lng = position.longitude;
      }
    } catch (_) {}

    final log = IncidentLog(
      id: const Uuid().v4(),
      timestamp: DateTime.now().toUtc(), // Siempre UTC para auditoría legal
      tipo: tipo,
      descripcion: descripcion,
      latitud: lat,
      longitud: lng,
    );
    await cajaNegra.registrarEvento(log);
  }

  // ── API pública ────────────────────────────────────────────────────────────

  /// Inicia el pre-aviso. Si ya hay una alerta activa, ignora la llamada.
  void triggerWarning() {
    if (state is SosWarning || state is SosActive) return;

    // 📝 LOG: El guía posiblemente está en problemas
    _registrarLog(
      TipoIncidente.sosGuiaActivado,
      "Pre-Aviso de SOS disparado (botón presionado o posible inmovilidad)",
    );

    emit(const SosWarning(_preAvisoSegundos));
    _startTimer();
  }

  /// Cancela el pre-aviso o declara la emergencia como resuelta.
  void cancelSos() {
    _timer?.cancel();
    emit(const SosIdle());

    // 📝 LOG: Falsa alarma o situación controlada
    _registrarLog(
      TipoIncidente.sosGuiaCancelado,
      "El guía canceló el SOS manualmente. Situación bajo control.",
    );
  }

  /// Lanza el SOS manualmente sin esperar el timer (acción deliberada del guia).
  void activarSOSManual() {
    _timer?.cancel();
    _ejecutarProtocoloYEmitir();
  }

  // ── Privados ───────────────────────────────────────────────────────────────

  void _startTimer() {
    _timer?.cancel();
    int segundos = _preAvisoSegundos;

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (isClosed) {
        t.cancel();
        return;
      }
      segundos--;
      if (segundos > 0) {
        emit(SosWarning(segundos));
      } else {
        t.cancel();
        _ejecutarProtocoloYEmitir();
      }
    });
  }

  /// Ejecuta la Sucesión de Mando y emite [SosActive] con el resultado.
  Future<void> _ejecutarProtocoloYEmitir() async {
    if (isClosed) return;

    // Ubicación simulada como fallback de ultra-emergencia si falla el hardware
    double lat = 19.4326;
    double lng = -99.1332;

    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        lat = position.latitude;
        lng = position.longitude;
      }
    } catch (_) {
      // Usar coordenadas estáticas como último recurso (no bloquear emergencia)
    }

    if (viajeActivo != null) {
      final resultado = await _sucesionMandoUseCase.ejecutarProtocolo(
        viajeActivo!,
        lat,
        lng,
      );

      // 📝 LOG: Emergencia real con protocolo operando
      await _registrarLog(
        TipoIncidente.sosGuiaActivado,
        "🚨 SOS REAL ENVIADO Y SUCESIÓN DISPARADA. Protocolo operando.",
      );

      if (!isClosed) emit(SosActive(resultado: resultado));
    } else {
      // 📝 LOG: Emergencia real (simulada) sin viaje activo
      await _registrarLog(
        TipoIncidente.sosGuiaActivado,
        "🚨 SOS REAL ENVIADO (Sin Viaje Activo) - Posible error de contexto o activación general.",
      );

      if (!isClosed) emit(const SosActive());
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
