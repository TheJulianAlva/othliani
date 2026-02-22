import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/guia/home/presentation/blocs/eco_mode/eco_mode_cubit.dart';
import 'package:frontend/features/guia/home/presentation/shared_widgets/swipe_to_action_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EcoModeOverlay
//
// Pantalla totalmente negra para pantallas OLED/AMOLED.
// Los píxeles negros se apagan físicamente → ahorro real de batería.
//
// Características:
// - Animación de radar pulsante (circle + scale loop)
// - SwipeToActionWidget para despertar (evita toques accidentales del bolsillo)
// - WakeLock no requerido: el monitoreo sigue en background vía Cubit/Services
// ─────────────────────────────────────────────────────────────────────────────

class EcoModeOverlay extends StatefulWidget {
  /// Número de turistas activos bajo monitoreo.
  final int turistasActivos;

  const EcoModeOverlay({super.key, this.turistasActivos = 0});

  @override
  State<EcoModeOverlay> createState() => _EcoModeOverlayState();
}

class _EcoModeOverlayState extends State<EcoModeOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();

    // Oscurecer la barra de estado al entrar en Modo Eco
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.black,
        systemNavigationBarColor: Colors.black,
      ),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(
      begin: 0.85,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOutSine));
    _opacityAnim = Tween<double>(
      begin: 0.25,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOutSine));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    // Restaurar barra de estado al salir
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.black,
        systemNavigationBarColor: Colors.black,
      ),
      child: Material(
        color: Colors.black,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // ── Radar pulsante ──────────────────────────────────────────
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder:
                      (_, child) => Stack(
                        alignment: Alignment.center,
                        children: [
                          // Halo exterior
                          Transform.scale(
                            scale: _pulseAnim.value * 1.4,
                            child: Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.green.withAlpha(
                                    (_opacityAnim.value * 80).round(),
                                  ),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          // Círculo medio
                          Transform.scale(
                            scale: _pulseAnim.value,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.green.withAlpha(
                                    (_opacityAnim.value * 150).round(),
                                  ),
                                  width: 3,
                                ),
                              ),
                              child: child,
                            ),
                          ),
                        ],
                      ),
                  child: Icon(
                    Icons.radar_rounded,
                    color: Colors.green.withAlpha(
                      (_opacityAnim.value * 255).round(),
                    ),
                    size: 64,
                  ),
                ),
                const SizedBox(height: 40),

                // ── Texto de estado ─────────────────────────────────────────
                const Text(
                  'MODO ECO ACTIVO',
                  style: TextStyle(
                    color: Color(0xFF2ECC71),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  widget.turistasActivos > 0
                      ? 'Monitoreando geocerca en segundo plano.\n'
                          '${widget.turistasActivos} turistas bajo protección.'
                      : 'Monitoreo activo en segundo plano.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),

                // Reloj (hora actual)
                _RelojMinimalista(),

                const Spacer(),

                // ── Instrucción ─────────────────────────────────────────────
                Text(
                  'DESLIZA PARA DESPERTAR',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),

                // Anti-toques accidentales
                SwipeToActionWidget(
                  text: 'Volver al mapa',
                  baseColor: const Color(0xFF2ECC71),
                  icon: Icons.light_mode_rounded,
                  onActionCompleted: () {
                    HapticFeedback.lightImpact();
                    context.read<EcoModeCubit>().disableEcoMode();
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Reloj minimalista (no consume GPS ni red) ─────────────────────────────────

class _RelojMinimalista extends StatefulWidget {
  @override
  State<_RelojMinimalista> createState() => _RelojMinimalistaState();
}

class _RelojMinimalistaState extends State<_RelojMinimalista> {
  late String _hora;

  @override
  void initState() {
    super.initState();
    _actualizar();
    // Actualiza cada 30 segundos — suficiente para mostrar la hora sin drenar
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 30));
      if (!mounted) return false;
      _actualizar();
      return true;
    });
  }

  void _actualizar() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    setState(() => _hora = '$h:$m');
  }

  @override
  Widget build(BuildContext context) => Text(
    _hora,
    style: TextStyle(
      color: Colors.grey.shade800,
      fontSize: 48,
      fontWeight: FontWeight.w200,
      letterSpacing: 4,
    ),
  );
}
