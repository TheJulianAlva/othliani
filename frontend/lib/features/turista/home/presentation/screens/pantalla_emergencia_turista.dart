import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/demo/demo_config.dart';
import 'package:frontend/features/turista/home/presentation/widgets/walkie_talkie_button.dart';

/// Pantalla de emergencia mostrada al turista después de activar el botón SOS.
/// Solo aparece en modo demo (kDemoMode).
class PantallaEmergenciaTurista extends StatefulWidget {
  const PantallaEmergenciaTurista({super.key});

  @override
  State<PantallaEmergenciaTurista> createState() =>
      _PantallaEmergenciaTuristaState();
}

class _PantallaEmergenciaTuristaState extends State<PantallaEmergenciaTurista>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFB71C1C),
        body: SafeArea(
          child: Column(
            children: [
              // Botón cerrar (disponible para el presentador)
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54, size: 28),
                  onPressed: () => context.pop(),
                ),
              ),

              const Spacer(),

              // Ícono pulsante
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (_, __) => Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.15),
                      border: Border.all(color: Colors.white38, width: 3),
                    ),
                    child: const Icon(
                      Icons.emergency_rounded,
                      color: Colors.white,
                      size: 70,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // Mensaje principal
              const Text(
                'Señal enviada al guía',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 14),

              const Text(
                'Quédate donde estás',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Walkie-talkie para escuchar respuesta del guía
              const Text(
                'Mantén presionado para hablar con el guía',
                style: TextStyle(color: Colors.white60, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              WalkieTalkieButton(tripId: kDemoTripId),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  'El guía ya fue notificado y está en camino',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
