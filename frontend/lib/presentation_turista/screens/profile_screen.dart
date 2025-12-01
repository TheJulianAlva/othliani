import 'package:flutter/material.dart';
import '../../core/theme/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/walkie_talkie_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
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
                Text('Nombre del Turista', style: AppTextStyles.heading),
                Text('turista@example.com', style: AppTextStyles.caption),
                const SizedBox(height: AppSpacing.xl),
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Editar Perfil'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Editar perfil próximamente'),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Mis Viajes'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Historial de viajes próximamente'),
                      ),
                    );
                  },
                ),
                const Divider(),
                const SizedBox(height: AppSpacing.xl),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cerrar sesión próximamente'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Cerrar Sesión'),
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Eliminar cuenta próximamente'),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  child: const Text('Eliminar Cuenta'),
                ),
              ],
            ),
          ),
          const WalkieTalkieButton(),
        ],
      ),
    );
  }
}
