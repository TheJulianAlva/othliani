import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/veltur_tokens.dart';

class ItineraryEventCard extends StatelessWidget {
  final String time;
  final String title;
  final String description;

  const ItineraryEventCard({
    super.key,
    required this.time,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = VelturTokens.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        boxShadow: tokens.shadowSm,
      ),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: tokens.primarySoft,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                child: Center(
                  child: Text(
                    time,
                    style: theme.textTheme.labelLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(description, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(Icons.location_on, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
