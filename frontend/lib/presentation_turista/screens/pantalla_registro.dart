import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/info_modal.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/navigation/routes_turista.dart';
import 'package:frontend/core/utils/mock_auth_data.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _termsAccepted = false;
  bool _privacyAccepted = false;

  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = 'Juan';
    _lastNameController.text = 'Morales';
    _emailController.text = 'juanmorales@outlook.com';
    _passwordController.text = '************';
    _confirmPasswordController.text = '************';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isValidInput() {
    final name = _nameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty ||
        lastName.isEmpty ||
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

  void _handleRegister() {
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

    MockAuthData.registeredEmail = _emailController.text.trim();
    context.go(RoutesTurista.login);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.createAccount,
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              _buildTextField(
                '${l10n.name}:',
                l10n.name,
                controller: _nameController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Apellido:',
                'Apellido',
                controller: _lastNameController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                '${l10n.email}:',
                l10n.email,
                controller: _emailController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                '${l10n.password}:',
                l10n.password,
                controller: _passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                '${l10n.confirmPassword}:',
                l10n.confirmPassword,
                controller: _confirmPasswordController,
                obscureText: true,
              ),
              const SizedBox(height: 16),
              _buildCheckbox(
                'Términos y condiciones',
                _termsAccepted,
                (val) => setState(() => _termsAccepted = val ?? false),
                onTapLink: () => InfoModal.show(
                  context: context,
                  title: 'Términos y condiciones',
                  content: 'Contenido de los términos y condiciones...',
                ),
              ),
              _buildCheckbox(
                'Aviso de privacidad',
                _privacyAccepted,
                (val) => setState(() => _privacyAccepted = val ?? false),
                onTapLink: () => InfoModal.show(
                  context: context,
                  title: 'Aviso de Privacidad',
                  content: 'Contenido del aviso de privacidad...',
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _handleRegister,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(l10n.createAccount),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint, {
    required TextEditingController controller,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
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
