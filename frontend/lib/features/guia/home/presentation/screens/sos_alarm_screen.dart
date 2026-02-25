import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/features/guia/home/domain/usecases/sucesion_mando_usecase.dart';
import 'package:frontend/features/guia/trips/domain/services/caja_negra_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PrioridadAlerta — modelo de datos para el SOS contextual
//
// Creado por _procesarAlerta() en el mapa y pasado como `extra` a /sos.
// ─────────────────────────────────────────────────────────────────────────────

enum PrioridadAlerta { estandar, critica }

class AlertaSOS {
  final PrioridadAlerta prioridad;
  final String mensaje;
  final String? nombreTurista;
  final bool autoDetectada;

  /// Segundos antes de enviar automáticamente (3 estándar / 5 crítica por
  /// requerir confirmación más deliberada del guía).
  int get timerSegundos => prioridad == PrioridadAlerta.critica ? 5 : 3;

  const AlertaSOS({
    required this.prioridad,
    required this.mensaje,
    this.nombreTurista,
    this.autoDetectada = false,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// SOSAlarmScreen
// ─────────────────────────────────────────────────────────────────────────────

class SOSAlarmScreen extends StatefulWidget {
  /// Metadata contextual de la alerta.
  /// null = activación manual del guía (prioridad estándar, 3 s).
  final AlertaSOS? alerta;

  /// Resultado del protocolo de Sucesión de Mando ejecutado por [SosCubit].
  /// Si está presente, se muestra en la pantalla de confirmación en lugar
  /// del texto genérico.
  final ResultadoSucesion? resultadoSucesion;

  /// Callback ejecutado cuando el SOS se confirma (tras el timer).
  final VoidCallback? onAlertaEnviada;

  const SOSAlarmScreen({
    super.key,
    this.alerta,
    this.resultadoSucesion,
    this.onAlertaEnviada,
  });

  @override
  State<SOSAlarmScreen> createState() => _SOSAlarmScreenState();
}

class _SOSAlarmScreenState extends State<SOSAlarmScreen>
    with SingleTickerProviderStateMixin {
  // ── Timer ─────────────────────────────────────────────────────────────────
  late int _segundosRestantes;
  Timer? _timer;
  bool _enviado = false;

  // ── Slider ────────────────────────────────────────────────────────────────
  double _dragX = 0;
  static const double _trackWidth = 280.0;
  static const double _thumbSize = 64.0;
  static const double _maxDrag = _trackWidth - _thumbSize - 8;

  // ── Pulso / Parpadeo ──────────────────────────────────────────────────────
  late AnimationController _pulseCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _flashAnim; // usado solo en modo crítico

  bool get _esCritico => widget.alerta?.prioridad == PrioridadAlerta.critica;

  // Colores según prioridad
  Color get _bgColor =>
      _esCritico ? const Color(0xFF7B0000) : const Color(0xFFBF360C);
  Color get _bgFlashColor =>
      _esCritico ? const Color(0xFFD50000) : const Color(0xFFE65100);

  @override
  void initState() {
    super.initState();
    _segundosRestantes = widget.alerta?.timerSegundos ?? 3;

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _esCritico ? 400 : 800),
    )..repeat(reverse: true);

    _scaleAnim = Tween<double>(
      begin: 0.82,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _flashAnim = _pulseCtrl; // reutilizamos el mismo controlador para el flash

    _iniciarConteo();
    HapticFeedback.heavyImpact();
  }

  void _iniciarConteo() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_segundosRestantes > 1) {
          _segundosRestantes--;
          _esCritico
              ? HapticFeedback.heavyImpact()
              : HapticFeedback.mediumImpact();
        } else {
          t.cancel();
          _enviarSOS();
        }
      });
    });
  }

  void _enviarSOS() {
    HapticFeedback.heavyImpact();
    _pulseCtrl.stop();
    setState(() => _enviado = true);
    widget.onAlertaEnviada?.call();

    // 📌 Registro en Caja Negra (fire-and-forget — no bloquea la UI)
    // 📌 Registro: el SOS fue disparado o timeout
    final alerta = widget.alerta;
    if (alerta?.autoDetectada == true) {
      CajaNegraService().registrarIncidente(
        nombreTurista: alerta?.nombreTurista ?? 'Desconocido',
        prioridad:
            alerta?.prioridad == PrioridadAlerta.critica
                ? 'CRITICA'
                : 'ESTANDAR',
        accionRealizada: alerta?.mensaje ?? 'Alejamiento detectado',
      );
    } else {
      CajaNegraService().registrarSosAutomatico(
        nombreTurista: 'Guía',
        prioridad: 'CRITICA',
      );
    }
  }

  void _cancelar() {
    _timer?.cancel();
    HapticFeedback.lightImpact();

    // 📌 Registro: acción del guía (canceló con deslizador)
    CajaNegraService().registrarCancelacionGuia(
      descripcionAlerta: widget.alerta?.mensaje ?? 'SOS',
      coordenadas:
          '', // No tenemos coordenadas aquí, se podría pasar null o una cadena vacía
    );

    if (mounted) Navigator.of(context).pop();
  }

  void _onDragUpdate(DragUpdateDetails d) =>
      setState(() => _dragX = (_dragX + d.delta.dx).clamp(0.0, _maxDrag));

  void _onDragEnd(DragEndDetails _) {
    if (_dragX >= _maxDrag * 0.85) {
      _cancelar();
    } else {
      setState(() => _dragX = 0);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_enviado) return _vistaConfirmada();

    // Fondo con parpadeo en modo crítico
    return AnimatedBuilder(
      animation: _flashAnim,
      builder: (_, child) {
        final bg =
            _esCritico
                ? Color.lerp(_bgColor, _bgFlashColor, _flashAnim.value)!
                : _bgColor;
        return Scaffold(backgroundColor: bg, body: child);
      },
      child: SafeArea(child: _vistaConteo()),
    );
  }

  // ── Vista: SOS enviado ────────────────────────────────────────────────────
  Widget _vistaConfirmada() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.verified_user_rounded,
                size: 110,
                color: Colors.greenAccent,
              ),
              const SizedBox(height: 20),
              const Text(
                'AUXILIO SOLICITADO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              if (_esCritico && widget.alerta?.nombreTurista != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(40),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.alerta!.nombreTurista!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  // Preferimos el mensaje dinámico del protocolo de sucesión
                  widget.resultadoSucesion?.mensajeUI ??
                      (_esCritico
                          ? 'Alerta de PRIORIDAD CRÍTICA enviada.\n'
                              'Contactos de confianza y central notificados.\n\n'
                              'Mantén la calma. Protocolo de emergencia activado.'
                          : 'Tu ubicación GPS y contactos de confianza han sido notificados.\n\n'
                              'Mantén la calma. Auxilio en camino.'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ),
              // Log de auditoría visible (B2B)
              if (widget.alerta?.autoDetectada == true) ...[
                const SizedBox(height: 12),
                _FilaAuditoria(
                  '${_esCritico ? "⚠️ Incidente Crítico" : "ℹ️ Alerta"} '
                  'registrada a las ${TimeOfDay.now().format(context)}',
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'FINALIZAR ALERTA',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Vista: Conteo regresivo ───────────────────────────────────────────────
  Widget _vistaConteo() {
    final progreso =
        (_segundosRestantes - 1) /
        (widget.alerta?.timerSegundos ?? 3).toDouble();
    final alerta = widget.alerta;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Ícono pulsante — diferente según prioridad
        ScaleTransition(
          scale: _scaleAnim,
          child: Icon(
            _esCritico
                ? Icons
                    .child_care_rounded // menores / vulnerables
                : Icons.warning_amber_rounded, // estándar
            size: 100,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),

        // Badge de prioridad (solo crítica)
        if (_esCritico)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '⚠ PRIORIDAD CRÍTICA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
        const SizedBox(height: 16),

        // Nombre del turista (en negrita gigante si es crítico)
        if (alerta?.nombreTurista != null)
          Text(
            alerta!.nombreTurista!,
            style: TextStyle(
              color: Colors.white,
              fontSize: _esCritico ? 32 : 20,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 8),

        Text(
          alerta?.mensaje ?? 'ACTIVANDO SOS',
          style: TextStyle(
            color: Colors.white,
            fontSize: _esCritico ? 18 : 28,
            fontWeight: FontWeight.w800,
            letterSpacing: _esCritico ? 0.5 : 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'Enviando alerta en $_segundosRestantes segundo${_segundosRestantes != 1 ? "s" : ""}…',
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 28),

        // Barra de progreso
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progreso,
              backgroundColor: Colors.white.withAlpha(40),
              color: Colors.white,
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(height: 72),

        // ── Slider de cancelación ────────────────────────────────────────
        const Text(
          'DESLIZA PARA CANCELAR',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 10),

        GestureDetector(
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          child: SizedBox(
            width: _trackWidth,
            height: _thumbSize + 8,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  width: _trackWidth,
                  height: _thumbSize,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(_thumbSize / 2),
                    border: Border.all(color: Colors.white.withAlpha(60)),
                  ),
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(left: _thumbSize),
                    child: const Text(
                      'Desliza →',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: Duration.zero,
                  width: _dragX + _thumbSize,
                  height: _thumbSize,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(45),
                    borderRadius: BorderRadius.circular(_thumbSize / 2),
                  ),
                ),
                Positioned(
                  left: _dragX + 4,
                  child: Container(
                    width: _thumbSize - 8,
                    height: _thumbSize - 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color:
                          _dragX > _maxDrag * 0.5
                              ? Colors.green
                              : (_esCritico
                                  ? const Color(0xFF7B0000)
                                  : const Color(0xFFBF360C)),
                      size: 26,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _dragX > _maxDrag * 0.5
              ? '¡Suelta para cancelar!'
              : 'Desliza hasta el final para cancelar la alerta',
          style: TextStyle(
            color:
                _dragX > _maxDrag * 0.5 ? Colors.greenAccent : Colors.white38,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// ── Auxiliares ────────────────────────────────────────────────────────────────

class _FilaAuditoria extends StatelessWidget {
  final String texto;
  const _FilaAuditoria(this.texto);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withAlpha(10),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.white24),
    ),
    child: Row(
      children: [
        const Icon(Icons.receipt_long_rounded, size: 14, color: Colors.white54),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ),
      ],
    ),
  );
}
