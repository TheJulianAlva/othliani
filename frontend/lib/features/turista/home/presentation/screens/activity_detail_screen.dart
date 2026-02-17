import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/app_colors.dart';

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
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
              ),
              child: const Icon(Icons.image, size: 80, color: Colors.grey),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Time
            Row(
              children: [
                const Icon(Icons.access_time, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  activityTime,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Title
            Text(
              activityTitle,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Description section
            const Text(
              'Descripción',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: AppSpacing.sm),

            Text(
              activityDescription,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Location section
            const Text(
              'Ubicación',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: AppSpacing.sm),

            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(AppBorderRadius.sm),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Zona arqueológica de Tulum',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Additional info
            const Text(
              'Información Adicional',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: AppSpacing.sm),

            _buildInfoRow(Icons.people, 'Grupo completo'),
            const SizedBox(height: AppSpacing.sm),
            _buildInfoRow(Icons.restaurant, 'Comida incluida'),
            const SizedBox(height: AppSpacing.sm),
            _buildInfoRow(Icons.directions_bus, 'Transporte incluido'),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
      ],
    );
  }
}
