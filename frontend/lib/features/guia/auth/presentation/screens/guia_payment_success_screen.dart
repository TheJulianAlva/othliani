import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/navigation/routes_guia.dart';

class GuiaPaymentSuccessScreen extends StatefulWidget {
  const GuiaPaymentSuccessScreen({super.key});

  @override
  State<GuiaPaymentSuccessScreen> createState() =>
      _GuiaPaymentSuccessScreenState();
}

class _GuiaPaymentSuccessScreenState extends State<GuiaPaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    // Iniciar la animación al cargar la pantalla
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Checkmark animado ──────────────────────────────────────
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  margin: const EdgeInsets.symmetric(horizontal: 100),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green.shade600,
                    size: 80,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // ── Título ─────────────────────────────────────────────────
              Text(
                '¡Suscripción activada!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // ── Mensaje ────────────────────────────────────────────────
              Text(
                'Tu suscripción personal está activa. Ahora puedes gestionar tus propios viajes con seguridad inteligente.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // ── Beneficios rápidos ─────────────────────────────────────
              ...[
                (Icons.sos_outlined, 'Botón SOS activado'),
                (Icons.map_outlined, 'Itinerarios disponibles'),
                (Icons.group_outlined, 'Gestión de participantes lista'),
              ].map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.$1, color: Colors.green.shade600, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        item.$2,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // ── Botón comenzar ─────────────────────────────────────────
              ElevatedButton(
                onPressed: () => context.go(RoutesGuia.home),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Comenzar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
