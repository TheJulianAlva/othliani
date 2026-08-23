import 'package:flutter/material.dart';
import '../../core/theme/app_constants.dart';
import '../../core/theme/veltur_tokens.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String message;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = VelturTokens.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: tokens.accentTeal),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: tokens.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
