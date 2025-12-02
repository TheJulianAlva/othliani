import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/navigation/routes_turista.dart';
import '../widgets/walkie_talkie_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
      _userName = prefs.getString('userName') ?? 'Turista Invitado';
      _userEmail = prefs.getString('userEmail') ?? 'turista@example.com';
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    if (mounted) {
      context.go(RoutesTurista.login);
    }
  }

  void _showEditProfileDialog() {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: _userName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.editProfile),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(labelText: l10n.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('userName', nameController.text);
              if (mounted) {
                setState(() {
                  _userName = nameController.text;
                });
                Navigator.pop(context);
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile)),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: AppBorderRadius.round,
                  child: Icon(Icons.person, size: 50),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  _userName,
                  style: AppTextStyles.heading,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _userEmail,
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xl),
                
                // Profile Actions
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: Text(l10n.editProfile),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _showEditProfileDialog,
                ),
                const Divider(),
                
                ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(l10n.myTrips),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.myTripsComingSoon)),
                    );
                  },
                ),
                
                const Divider(),
                const SizedBox(height: AppSpacing.xl),
                
                // Logout
                ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(l10n.logout),
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: () {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.deleteAccountConfirm)),
                      );
                    }
                  },
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  child: Text(l10n.deleteAccount),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
          const WalkieTalkieButton(),
        ],
      ),
    );
  }
}
