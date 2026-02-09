import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/l10n/app_localizations.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/features/turista/settings/presentation/cubit/accessibility_cubit.dart';

class AccessibilityScreen extends StatelessWidget {
  const AccessibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.accessibilitySettings)),
      body: BlocBuilder<AccessibilityCubit, AccessibilityState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              // Font Size
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.fontSize,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...FontSizeOption.values.map((option) {
                        String label;
                        switch (option) {
                          case FontSizeOption.small:
                            label = l10n.small;
                            break;
                          case FontSizeOption.medium:
                            label = l10n.medium;
                            break;
                          case FontSizeOption.large:
                            label = l10n.large;
                            break;
                          case FontSizeOption.extraLarge:
                            label = l10n.extraLarge;
                            break;
                        }
                        return RadioListTile<FontSizeOption>(
                          title: Text(label),
                          value: option,
                          groupValue: state.fontSize,
                          onChanged: (value) {
                            if (value != null) {
                              context.read<AccessibilityCubit>().setFontSize(
                                value,
                              );
                            }
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // High Contrast
              Card(
                child: SwitchListTile(
                  secondary: const Icon(Icons.contrast),
                  title: Text(l10n.highContrast),
                  subtitle: const Text('Aumenta el contraste de colores'),
                  value: state.highContrast,
                  onChanged: (value) {
                    context.read<AccessibilityCubit>().setHighContrast(value);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Screen Reader
              Card(
                child: SwitchListTile(
                  secondary: const Icon(Icons.record_voice_over),
                  title: Text(l10n.screenReader),
                  subtitle: const Text(
                    'Activa la compatibilidad con lectores de pantalla',
                  ),
                  value: state.screenReader,
                  onChanged: (value) {
                    context.read<AccessibilityCubit>().setScreenReader(value);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Reduce Animations
              Card(
                child: SwitchListTile(
                  secondary: const Icon(Icons.animation),
                  title: Text(l10n.reduceAnimations),
                  subtitle: const Text(
                    'Reduce las animaciones en la aplicación',
                  ),
                  value: state.reduceAnimations,
                  onChanged: (value) {
                    context.read<AccessibilityCubit>().setReduceAnimations(
                      value,
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Haptic Feedback
              Card(
                child: SwitchListTile(
                  secondary: const Icon(Icons.vibration),
                  title: Text(l10n.hapticFeedback),
                  subtitle: const Text('Vibración al tocar elementos'),
                  value: state.hapticFeedback,
                  onChanged: (value) {
                    context.read<AccessibilityCubit>().setHapticFeedback(value);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
