import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/navigation/routes_guia.dart';
import 'package:frontend/core/l10n/app_localizations.dart';

class LoginScreenGuia extends StatefulWidget {
  const LoginScreenGuia({super.key});

  @override
  State<LoginScreenGuia> createState() => _LoginScreenGuiaState();
}

class _LoginScreenGuiaState extends State<LoginScreenGuia> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill for testing purposes, similar to tourist app
    _emailController.text = 'guia@othliani.com';
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

  Future<void> _handleLogin() async {
    if (_isValidInput()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedInGuia', true);
      await prefs.setString('userNameGuia', 'Guía Demo');
      await prefs.setString('userEmailGuia', _emailController.text.trim());

      if (mounted) {
        context.go(RoutesGuia.home);
      }
    } else {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.error), // Using generic error message from l10n
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
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
              const SizedBox(height: 40),
              Text(
                'OthliAni - Guía', // Specific title for Guide App
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 10),
              Text(
                l10n.login,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 30),
              _buildTextField(
                '${l10n.emailAddress}:',
                l10n.emailAddress,
                controller: _emailController,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                '${l10n.password}:',
                l10n.password,
                controller: _passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(l10n.signIn),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    context.push(RoutesGuia.forgotPassword);
                  },
                  child: Text(l10n.forgotPassword),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.dontHaveAccount),
                  TextButton(
                    onPressed: () {
                      context.push(RoutesGuia.register);
                    },
                    child: Text(l10n.register),
                  ),
                ],
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
}
