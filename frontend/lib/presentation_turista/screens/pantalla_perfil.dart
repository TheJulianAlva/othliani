import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di/service_locator.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/l10n/app_localizations.dart';
import 'package:frontend/presentation_turista/widgets/walkie_talkie_button.dart';
import 'package:frontend/features/turista/auth/presentation/bloc/auth_bloc.dart';

import 'package:frontend/features/turista/auth/presentation/bloc/auth_event.dart';

import 'package:frontend/features/turista/profile/presentation/bloc/profile_bloc.dart';
import 'package:frontend/features/turista/profile/presentation/bloc/profile_event.dart';
import 'package:frontend/features/turista/profile/presentation/bloc/profile_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileBloc>()..add(LoadProfile()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  void _showEditProfileDialog(BuildContext context, String currentName) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(l10n.editProfile),
            content: TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: l10n.name),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<ProfileBloc>().add(
                    UpdateProfile(
                      name: nameController.text,
                      email:
                          'turista@example.com', // Keep email constant or add field
                    ),
                  );
                  Navigator.pop(dialogContext);
                },
                child: Text(l10n.save),
              ),
            ],
          ),
    );
  }

  void _logout(BuildContext context) {
    context.read<AuthBloc>().add(AuthLogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile)),
      body: Stack(
        children: [
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ProfileError) {
                return Center(child: Text(state.message));
              } else if (state is ProfileLoaded) {
                final profile = state.profile;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: AppBorderRadius.round,
                        child: Icon(Icons.person, size: 50),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        profile.name,
                        style: AppTextStyles.heading,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        profile.email,
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
                        onTap:
                            () => _showEditProfileDialog(context, profile.name),
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
                        onPressed: () => _logout(context),
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.deleteAccountConfirm)),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                        child: Text(l10n.deleteAccount),
                      ),

                      const SizedBox(height: 80),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const WalkieTalkieButton(),
        ],
      ),
    );
  }
}
