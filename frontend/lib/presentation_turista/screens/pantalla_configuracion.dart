import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/providers/theme_provider.dart';
import 'pantalla_accesibilidad.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return ListView(
      children: [
        // Language
        ListTile(
          leading: const Icon(Icons.language),
          title: Text(l10n.language),
          subtitle: Text(
            localeProvider.locale.languageCode == 'es' 
              ? l10n.spanish 
              : l10n.english
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _showLanguageDialog(context, localeProvider, l10n);
          },
        ),
        const Divider(),
        
        // Theme
        SwitchListTile(
          secondary: Icon(
            themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode
          ),
          title: Text(l10n.theme),
          subtitle: Text(
            themeProvider.isDarkMode ? l10n.darkTheme : l10n.lightTheme
          ),
          value: themeProvider.isDarkMode,
          onChanged: (value) {
            themeProvider.setTheme(value);
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

  void _showLanguageDialog(
    BuildContext context, 
    LocaleProvider provider,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.language),
        children: [
          SimpleDialogOption(
            onPressed: () {
              provider.setLocale(const Locale('es'));
              Navigator.pop(context);
            },
            child: Row(
              children: [
                if (provider.locale.languageCode == 'es')
                  const Icon(Icons.check, color: Colors.green),
                const SizedBox(width: 8),
                Text(l10n.spanish),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              provider.setLocale(const Locale('en'));
              Navigator.pop(context);
            },
            child: Row(
              children: [
                if (provider.locale.languageCode == 'en')
                  const Icon(Icons.check, color: Colors.green),
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
