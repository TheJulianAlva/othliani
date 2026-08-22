import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/demo/demo_config.dart';
import 'package:frontend/core/demo/demo_socket_service.dart';
import 'package:frontend/core/navigation/routes_turista.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/features/turista/home/presentation/widgets/walkie_talkie_button.dart';

class ComunicacionSeguridadScreen extends StatelessWidget {
  const ComunicacionSeguridadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.md),
          Text(
            'Herramientas de Seguridad y Comunicación',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),

          // --- SECCIÓN SOS ---
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.security_rounded, color: Colors.red, size: 48),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Botón de Emergencia (SOS)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Úsalo únicamente en caso de una emergencia real. Mantén presionado por 3 segundos para enviar de inmediato tu ubicación en tiempo real al guía del grupo y a las autoridades de la agencia.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                GestureDetector(
                  onLongPress: () {
                    if (kDemoMode) {
                      DemoSocketService.instance.emitPanic();
                      context.push(RoutesTurista.emergencia);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🚨 Alerta de emergencia enviada.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Container(
                    height: 80,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.5),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'MANTENER PRESIONADO (SOS)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // --- SECCIÓN WALKIE TALKIE ---
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.radio, color: theme.colorScheme.primary, size: 48),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Radio Grupal (Walkie-Talkie)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Comunícate rápidamente por voz con el guía y todo tu grupo.\n\nInstrucciones:\n1. Mantén presionado el botón naranja.\n2. Habla tu mensaje mientras lo sostienes.\n3. Suelta el botón para transmitir tu mensaje a todos.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Nota: Esta herramienta debe ser habilitada previamente por tu guía para poder transmitir voz.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Botón Walkie-Talkie (ampliado visualmente o centrado)
                Center(
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: FittedBox(
                      child: WalkieTalkieButton(
                        tripId: kDemoMode ? kDemoTripId : 'current_trip',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Mantén presionado para hablar',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 100,
          ), // Espacio extra para el scroll y bottom bar
        ],
      ),
    );
  }
}
