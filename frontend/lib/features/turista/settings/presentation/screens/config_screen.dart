import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/l10n/app_localizations.dart';
import 'package:frontend/features/turista/settings/presentation/cubit/locale_cubit.dart';
import 'package:frontend/features/turista/settings/presentation/cubit/theme_cubit.dart';
import 'accessibility_screen.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      children: [
        // Language
        BlocBuilder<LocaleCubit, Locale>(
          builder: (context, locale) {
            return ListTile(
              leading: const Icon(Icons.language),
              title: Text(l10n.language),
              subtitle: Text(
                locale.languageCode == 'es' ? l10n.spanish : l10n.english,
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _showLanguageDialog(context, l10n);
              },
            );
          },
        ),
        const Divider(),

        // Theme
        BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            final isDarkMode = themeMode == ThemeMode.dark;
            return SwitchListTile(
              secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
              title: Text(l10n.theme),
              subtitle: Text(isDarkMode ? l10n.darkTheme : l10n.lightTheme),
              value: isDarkMode,
              onChanged: (value) {
                context.read<ThemeCubit>().setTheme(value);
              },
            );
          },
        ),
        const Divider(),

        // Accessibility
        ListTile(
          leading: const Icon(Icons.accessibility),
          title: Text(l10n.accessibility),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _showAccessibilityDialog(context);
          },
        ),
        const Divider(),

        // Notifications
        SwitchListTile(
          secondary: const Icon(Icons.notifications),
          title: Text(l10n.notifications),
          value: true,
          onChanged: (bool value) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Configurar notificaciones próximamente'),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showLanguageDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => SimpleDialog(
            title: Text(l10n.language),
            children: [
              SimpleDialogOption(
                onPressed: () {
                  context.read<LocaleCubit>().setLocale(const Locale('es'));
                  Navigator.pop(dialogContext);
                },
                child: Row(
                  children: [
                    // Since we don't have access to context.read inside dialog builder easily unless we pass it or wrap
                    // Actually showDialog context is above BlocProvider? No, it's usually fine if valid context passed.
                    // But strictly speaking, the context passed to method is from build, so it has providers.
                    // The dialogContext might not have them if not implementing route aware.
                    // However, SimpleDialog children usage of 'context.read' refers to the closure context if correct.
                    // To be safe, use the context passed to the method.
                    const Icon(Icons.language), // Just generic icon
                    const SizedBox(width: 8),
                    Text(l10n.spanish),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  context.read<LocaleCubit>().setLocale(const Locale('en'));
                  Navigator.pop(dialogContext);
                },
                child: Row(
                  children: [
                    const Icon(Icons.language),
                    const SizedBox(width: 8),
                    Text(l10n.english),
                  ],
                ),
              ),
            ],
          ),
    );
  }

  void _showAccessibilityDialog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AccessibilityScreen(),
        fullscreenDialog: true,
      ),
    );
  }
}
