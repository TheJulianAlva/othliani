import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/navigation/routes_turista.dart';
import 'package:frontend/core/utils/mock_auth_data.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text =
        MockAuthData.registeredEmail ?? 'juanmorales@outlook.com';
    _passwordController.text = '************';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidInput() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    return email.isNotEmpty && password.isNotEmpty;
  }

  void _handleLogin() {
    if (_isValidInput()) {
      context.go(RoutesTurista.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa todos los campos'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              const SizedBox(height: 40),
              const Text(
                'Iniciar sesión',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 30),
              _buildTextField(
                'Correo electrónico:',
                'Ingresa tu correo',
                controller: _emailController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Contraseña:',
                'Ingresa tu contraseña',
                controller: _passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Ingresar'),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    context.go(RoutesTurista.forgotPassword);
                  },
                  child: const Text('Olvide mi contraseña'),
                ),
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
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
}
