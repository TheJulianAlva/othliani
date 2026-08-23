import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/demo/demo_config.dart';
import 'package:frontend/core/demo/demo_socket_service.dart';
import 'package:frontend/core/navigation/routes_turista.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/veltur_tokens.dart';
import 'package:frontend/features/turista/home/presentation/widgets/walkie_talkie_button.dart';

class ComunicacionSeguridadScreen extends StatelessWidget {
  const ComunicacionSeguridadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = VelturTokens.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.md),
          Text(
            'Herramientas de Seguridad y Comunicación',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),

          // --- SECCIÓN SOS ---
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: tokens.dangerSoft,
              borderRadius: BorderRadius.circular(tokens.radiusLg),
              border: Border.all(color: tokens.danger.withValues(alpha: 0.3)),
              boxShadow: tokens.shadowSm,
            ),
            child: Column(
              children: [
                Icon(Icons.security_rounded, color: tokens.danger, size: 48),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Botón de Emergencia (SOS)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: tokens.danger,
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
                        SnackBar(
                          content: const Text('🚨 Alerta de emergencia enviada.'),
                          backgroundColor: tokens.danger,
                        ),
                      );
                    }
                  },
                  child: Container(
                    height: 80,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: tokens.danger,
                      borderRadius: BorderRadius.circular(tokens.radiusFull),
                      boxShadow: tokens.shadowGlowDanger,
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
              borderRadius: BorderRadius.circular(tokens.radiusLg),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
              boxShadow: tokens.shadowSm,
            ),
            child: Column(
              children: [
                Icon(Icons.radio, color: theme.colorScheme.primary, size: 48),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Radio Grupal (Walkie-Talkie)',
                  style: theme.textTheme.titleMedium?.copyWith(
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
                    color: tokens.warnSoft,
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                    border: Border.all(color: tokens.warn.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: tokens.warn, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Nota: Esta herramienta debe ser habilitada previamente por tu guía para poder transmitir voz.',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: tokens.warn,
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
                Text(
                  'Mantén presionado para hablar',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: tokens.textMuted,
                  ),
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
