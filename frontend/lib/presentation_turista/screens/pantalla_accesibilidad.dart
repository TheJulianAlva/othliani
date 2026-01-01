import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/accessibility_provider.dart';
import '../../core/theme/app_constants.dart';
import 'package:frontend/core/l10n/app_localizations.dart';

class AccessibilityScreen extends StatelessWidget {
  const AccessibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accessibilityProvider = context.watch<AccessibilityProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.accessibilitySettings)),
      body: ListView(
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
                    // ignore: deprecated_member_use
                    return RadioListTile<FontSizeOption>(
                      title: Text(label),
                      value: option,
                      // ignore: deprecated_member_use
                      groupValue: accessibilityProvider.fontSize,
                      // ignore: deprecated_member_use
                      onChanged: (value) {
                        if (value != null) {
                          accessibilityProvider.setFontSize(value);
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
              value: accessibilityProvider.highContrast,
              onChanged: (value) {
                accessibilityProvider.setHighContrast(value);
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
              value: accessibilityProvider.screenReader,
              onChanged: (value) {
                accessibilityProvider.setScreenReader(value);
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Reduce Animations
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.animation),
              title: Text(l10n.reduceAnimations),
              subtitle: const Text('Reduce las animaciones en la aplicación'),
              value: accessibilityProvider.reduceAnimations,
              onChanged: (value) {
                accessibilityProvider.setReduceAnimations(value);
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
              value: accessibilityProvider.hapticFeedback,
              onChanged: (value) {
                accessibilityProvider.setHapticFeedback(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
