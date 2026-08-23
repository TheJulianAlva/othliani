import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/veltur_tokens.dart';

class ActivityDetailScreen extends StatelessWidget {
  final String activityTitle;
  final String activityTime;
  final String activityDescription;

  const ActivityDetailScreen({
    super.key,
    required this.activityTitle,
    required this.activityTime,
    required this.activityDescription,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = VelturTokens.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalles de Actividad')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Activity image placeholder
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: tokens.surfaceWarm,
                borderRadius: BorderRadius.circular(tokens.radiusMd),
              ),
              child: Icon(Icons.image, size: 80, color: tokens.textMuted),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Time
            Row(
              children: [
                Icon(Icons.access_time, color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  activityTime,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Title
            Text(activityTitle, style: theme.textTheme.headlineSmall),

            const SizedBox(height: AppSpacing.lg),

            // Description section
            Text('Descripción', style: theme.textTheme.titleLarge),

            const SizedBox(height: AppSpacing.sm),

            Text(
              activityDescription,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: tokens.textMuted,
                height: 1.5,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Location section
            Text('Ubicación', style: theme.textTheme.titleLarge),

            const SizedBox(height: AppSpacing.sm),

            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: tokens.surfaceWarm,
                borderRadius: BorderRadius.circular(tokens.radiusSm),
                border: Border.all(color: tokens.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: theme.colorScheme.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Zona arqueológica de Tulum',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: tokens.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Additional info
            Text('Información Adicional', style: theme.textTheme.titleLarge),

            const SizedBox(height: AppSpacing.sm),

            _buildInfoRow(context, Icons.people, 'Grupo completo'),
            const SizedBox(height: AppSpacing.sm),
            _buildInfoRow(context, Icons.restaurant, 'Comida incluida'),
            const SizedBox(height: AppSpacing.sm),
            _buildInfoRow(
              context,
              Icons.directions_bus,
              'Transporte incluido',
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    final tokens = VelturTokens.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          text,
          style: theme.textTheme.bodyLarge?.copyWith(color: tokens.textMuted),
        ),
      ],
    );
  }
}
