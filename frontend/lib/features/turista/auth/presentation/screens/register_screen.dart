import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/di/service_locator.dart';
import 'package:frontend/core/navigation/routes_turista.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/info_modal.dart';
import 'package:frontend/features/turista/auth/presentation/cubit/register_cubit.dart';
import 'package:frontend/features/turista/auth/presentation/cubit/register_state.dart';
import 'package:frontend/core/l10n/app_localizations.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RegisterCubit>(),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  bool _termsAccepted = false;
  bool _privacyAccepted = false;

  final _nameController = TextEditingController(text: 'Juan');
  final _emailController = TextEditingController(
    text: 'juanmorales@outlook.com',
  );
  final _passwordController = TextEditingController(text: '************');
  final _confirmPasswordController = TextEditingController(
    text: '************',
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isValidInput() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      return false;
    }

    if (password != confirmPassword) {
      return false;
    }

    return true;
  }

  void _onRegisterPressed(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (!_isValidInput()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.error),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (!_termsAccepted || !_privacyAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Debes aceptar los términos y condiciones'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    context.read<RegisterCubit>().register(name, email, password);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<RegisterCubit, RegisterState>(
      listener: (context, state) {
        if (state is RegisterSuccess) {
          context.go(RoutesTurista.login);
        } else if (state is RegisterFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
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
                Text(
                  l10n.createAccount,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                _buildTextField(
                  '${l10n.name}:',
                  _nameController,
                  hint: l10n.name,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  '${l10n.email}:',
                  _emailController,
                  hint: l10n.email,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  '${l10n.password}:',
                  _passwordController,
                  hint: l10n.password,
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  '${l10n.confirmPassword}:',
                  _confirmPasswordController,
                  hint: l10n.confirmPassword,
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                _buildCheckbox(
                  'Términos y condiciones',
                  _termsAccepted,
                  (val) => setState(() => _termsAccepted = val ?? false),
                  onTapLink:
                      () => InfoModal.show(
                        context: context,
                        title: 'Términos y condiciones',
                        content: 'Contenido de los términos y condiciones...',
                      ),
                ),
                _buildCheckbox(
                  'Aviso de privacidad',
                  _privacyAccepted,
                  (val) => setState(() => _privacyAccepted = val ?? false),
                  onTapLink:
                      () => InfoModal.show(
                        context: context,
                        title: 'Aviso de Privacidad',
                        content: 'Contenido del aviso de privacidad...',
                      ),
                ),
                const SizedBox(height: 30),
                BlocBuilder<RegisterCubit, RegisterState>(
                  builder: (context, state) {
                    if (state is RegisterLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ElevatedButton(
                      onPressed: () => _onRegisterPressed(context),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: Text(l10n.createAccount),
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    InfoModal.show(
                      context: context,
                      title: l10n.incorrectDataTitle,
                      content: l10n.incorrectDataContent,
                    );
                  },
                  child: Text(
                    l10n.incorrectDataButton,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? hint,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckbox(
    String label,
    bool value,
    ValueChanged<bool?> onChanged, {
    VoidCallback? onTapLink,
  }) {
    return Row(
      children: [
        Checkbox(value: value, onChanged: onChanged),
        Flexible(
          child: GestureDetector(
            onTap: onTapLink,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
