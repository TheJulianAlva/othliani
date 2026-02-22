import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/agencia/trips/domain/entities/viaje.dart';
import 'package:frontend/features/guia/home/domain/usecases/sucesion_mando_usecase.dart';

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

  SosCubit({this.viajeActivo, SucesionMandoUseCase? sucesionMandoUseCase})
    : _sucesionMandoUseCase = sucesionMandoUseCase ?? SucesionMandoUseCase(),
      super(const SosIdle());

  // ── API pública ────────────────────────────────────────────────────────────

  /// Inicia el pre-aviso. Si ya hay una alerta activa, ignora la llamada.
  void triggerWarning() {
    if (state is SosWarning || state is SosActive) return;

    emit(const SosWarning(_preAvisoSegundos));
    _startTimer();
  }

  /// Cancela el pre-aviso o declara la emergencia como resuelta.
  void cancelSos() {
    _timer?.cancel();
    emit(const SosIdle());
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

    // Ubicación simulada hasta integrar geolocator
    const double lat = 19.4326;
    const double lng = -99.1332;

    if (viajeActivo != null) {
      final resultado = await _sucesionMandoUseCase.ejecutarProtocolo(
        viajeActivo!,
        lat,
        lng,
      );
      if (!isClosed) emit(SosActive(resultado: resultado));
    } else {
      if (!isClosed) emit(const SosActive());
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
