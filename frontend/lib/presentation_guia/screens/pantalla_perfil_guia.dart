import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/navigation/routes_guia.dart';
import 'package:frontend/core/l10n/app_localizations.dart';

class ProfileScreenGuia extends StatefulWidget {
  const ProfileScreenGuia({super.key});

  @override
  State<ProfileScreenGuia> createState() => _ProfileScreenGuiaState();
}

class _ProfileScreenGuiaState extends State<ProfileScreenGuia> {
  String _userName = 'Cargando...';
  String _userEmail = 'Cargando...';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userNameGuia') ?? 'Guía Demo';
      _userEmail = prefs.getString('userEmailGuia') ?? 'guia@othliani.com';
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedInGuia');
    await prefs.remove('userNameGuia');
    await prefs.remove('userEmailGuia');

    if (mounted) {
      context.go(RoutesGuia.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 16),
            Text(
              _userName,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            Text(
              _userEmail,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Profile Actions
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(l10n.editProfile),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Mock edit profile
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Funcionalidad de editar perfil próximamente',
                    ),
                  ),
                );
              },
            ),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(l10n.configuration),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to config (reusing tourist config screen or creating a new one if needed)
                // For now, just a placeholder or we could reuse the existing config screen if it's generic enough
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Configuración próximamente')),
                );
              },
            ),

            const Divider(),
            const SizedBox(height: 32),

            // Logout
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(l10n.logout),
            ),
          ],
        ),
      ),
    );
  }
}
