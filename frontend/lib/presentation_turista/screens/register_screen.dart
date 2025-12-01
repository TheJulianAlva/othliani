import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/info_modal.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/navigation/routes_turista.dart';
import 'package:frontend/core/utils/mock_auth_data.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _termsAccepted = false;
  bool _privacyAccepted = false;

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
              const Text(
                'Verifica tus datos',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              _buildTextField('Nombre:', 'Juan'),
              const SizedBox(height: 16),
              _buildTextField('Apellido:', 'Morales'),
              const SizedBox(height: 16),
              _buildTextField('Correo:', 'juanmorales@outlook.com'),
              const SizedBox(height: 16),
              _buildTextField('Contraseña:', '************', obscureText: true),
              const SizedBox(height: 16),
              _buildTextField(
                'Confirmar contraseña:',
                '************',
                obscureText: true,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    InfoModal.show(
                      context: context,
                      title: 'Datos incorrectos',
                      content:
                          'Por favor verifica que tus datos sean correctos...',
                      icon: Icons.error_outline,
                      titleColor: AppColors.error,
                    );
                  },
                  child: const Text('¿Datos incorrectos?'),
                ),
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
                onPressed: _termsAccepted && _privacyAccepted
                    ? () {
                        MockAuthData.registeredEmail =
                            'juanmorales@outlook.com';
                        context.go(RoutesTurista.login);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Crear cuenta'),
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
        GestureDetector(
          onTap: onTapLink,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
