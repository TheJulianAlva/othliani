import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/di/service_locator.dart';
import 'package:frontend/core/navigation/routes_guia.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/guia/auth/presentation/cubit/guia_forgot_password_cubit.dart';
import 'package:frontend/features/guia/auth/presentation/cubit/guia_forgot_password_state.dart';

class GuiaRecoverPasswordScreen extends StatelessWidget {
  const GuiaRecoverPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GuiaForgotPasswordCubit>(),
      child: const _GuiaRecoverPasswordView(),
    );
  }
}

class _GuiaRecoverPasswordView extends StatefulWidget {
  const _GuiaRecoverPasswordView();

  @override
  State<_GuiaRecoverPasswordView> createState() =>
      _GuiaRecoverPasswordViewState();
}

class _GuiaRecoverPasswordViewState extends State<_GuiaRecoverPasswordView> {
  final _emailController = TextEditingController(
    text: 'juanmorales@outlook.com',
  );

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onEnviar(BuildContext context) {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor ingresa tu correo electrónico'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    context.read<GuiaForgotPasswordCubit>().sendPasswordResetEmail(email);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GuiaForgotPasswordCubit, GuiaForgotPasswordState>(
      listener: (context, state) {
        if (state is GuiaForgotPasswordSuccess) {
          context.go(RoutesGuia.emailConfirmation);
        } else if (state is GuiaForgotPasswordFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(RoutesGuia.login),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppColors.textPrimary,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Ingresa tu correo\nelectrónico',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Correo electrónico:',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'juanmorales@outlook.com',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                BlocBuilder<GuiaForgotPasswordCubit, GuiaForgotPasswordState>(
                  builder: (context, state) {
                    if (state is GuiaForgotPasswordLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ElevatedButton(
                      onPressed: () => _onEnviar(context),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('Enviar'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
