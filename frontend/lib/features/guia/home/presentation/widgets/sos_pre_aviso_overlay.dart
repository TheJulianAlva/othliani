import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/navigation/routes_guia.dart';
import 'package:frontend/features/guia/home/presentation/blocs/sos/sos_cubit.dart';
import 'package:frontend/features/guia/home/presentation/shared_widgets/swipe_to_action_widget.dart';
import 'package:frontend/features/guia/home/presentation/screens/sos_alarm_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SosPreAvisoOverlay
//
// Overlay que se muestra sobre cualquier pantalla del guía cuando el
// SosCubit entra en SosWarning o SosActive.
//
// Uso: envuelve el Scaffold principal con un BlocBuilder y superpone
// este widget con Positioned.fill en un Stack.
//
// Cuando el timer llega a 0 (SosActive) navega automáticamente a /sos
// con el flujo completo de la SOSAlarmScreen existente.
// ─────────────────────────────────────────────────────────────────────────────

class SosPreAvisoOverlay extends StatefulWidget {
  const SosPreAvisoOverlay({super.key});

  @override
  State<SosPreAvisoOverlay> createState() => _SosPreAvisoOverlayState();
}

class _SosPreAvisoOverlayState extends State<SosPreAvisoOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _flashCtrl;

  @override
  void initState() {
    super.initState();
    _flashCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _flashCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SosCubit, SosState>(
      listenWhen: (_, curr) => curr is SosActive,
      listener: (ctx, _) {
        // Timer llegó a 0 → navegar a la pantalla SOS completa
        context.read<SosCubit>().cancelSos(); // limpia el estado del cubit
        ctx.push(
          RoutesGuia.sos,
          extra: const AlertaSOS(
            prioridad: PrioridadAlerta.critica,
            mensaje: 'SOS AUTOMÁTICO — PRE-AVISO AGOTADO',
            autoDetectada: false,
          ),
        );
      },
      buildWhen: (prev, curr) {
        // Solo reconstruir cuando hay cambio real relevante para el overlay
        return (prev is SosIdle) != (curr is SosIdle) ||
            (curr is SosWarning && prev is SosWarning
                ? (curr).secondsLeft != (prev).secondsLeft
                : true);
      },
      builder: (context, state) {
        if (state is SosIdle) return const SizedBox.shrink();

        if (state is SosWarning) {
          return _VistaPreAviso(
            segundosRestantes: state.secondsLeft,
            flashCtrl: _flashCtrl,
          );
        }

        // SosActive — solo visible brevemente antes de que el listener navegue
        return const SizedBox.shrink();
      },
    );
  }
}

// ── Vista de Pre-aviso (naranja parpadeante) ──────────────────────────────────

class _VistaPreAviso extends StatelessWidget {
  final int segundosRestantes;
  final AnimationController flashCtrl;

  const _VistaPreAviso({
    required this.segundosRestantes,
    required this.flashCtrl,
  });

  @override
  Widget build(BuildContext context) {
    HapticFeedback.mediumImpact();

    const colorBase = Color(0xFFE65100); // deep orange
    const colorFlash = Color(0xFFF57C00);

    return AnimatedBuilder(
      animation: flashCtrl,
      builder: (_, child) {
        final bg = Color.lerp(colorBase, colorFlash, flashCtrl.value)!;
        return Material(color: bg.withAlpha(240), child: child);
      },
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícono de advertencia
              Icon(
                Icons.warning_amber_rounded,
                size: 88,
                color: Colors.white.withAlpha(230),
              ),
              const SizedBox(height: 12),

              // Badge "PRE-ALERTA"
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(35),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'PRE-ALERTA SOS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Se enviará una señal de emergencia en:',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 16),

              // Contador gigante
              Text(
                '$segundosRestantes',
                style: const TextStyle(
                  fontSize: 96,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'segundos',
                style: TextStyle(color: Colors.white60, fontSize: 14),
              ),
              const SizedBox(height: 8),

              // Barra de progreso inversa
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: segundosRestantes / 30.0,
                  minHeight: 6,
                  backgroundColor: Colors.white.withAlpha(30),
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 52),

              // Instrucción
              const Text(
                'DESLIZA PARA CANCELAR',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),

              // Widget anti-pánico
              SwipeToActionWidget(
                text: 'Todo bajo control',
                baseColor: Colors.white,
                textColor: Colors.orange,
                icon: Icons.close_rounded,
                onActionCompleted: () {
                  HapticFeedback.lightImpact();
                  context.read<SosCubit>().cancelSos();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
