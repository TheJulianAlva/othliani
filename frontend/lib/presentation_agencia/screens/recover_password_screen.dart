import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/navigation/routes_agencia.dart';
import '../widgets/agency_auth_layout.dart';

class AgencyRecoverPasswordScreen extends StatefulWidget {
  const AgencyRecoverPasswordScreen({super.key});

  @override
  State<AgencyRecoverPasswordScreen> createState() =>
      _AgencyRecoverPasswordScreenState();
}

class _AgencyRecoverPasswordScreenState
    extends State<AgencyRecoverPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSent = false;

  // Email Regex
  final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  void _submit() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AgencyAuthLayout(
      child: _isSent ? _buildSuccessView() : _buildFormView(),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Recuperar Acceso',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Ingresa el correo asociado a tu cuenta para recibir instrucciones.',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          TextFormField(
            controller: _emailController,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              labelText: 'Correo Electrónico',
              hintText: 'usuario@dominio.com',
              filled: false,
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFD1D5DB)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF0F4C75), width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Campo requerido';
              }
              if (!_emailRegex.hasMatch(value)) {
                return 'Ingresa un correo válido';
              }
              return null;
            },
          ),

          const SizedBox(height: 32),

          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F4C75),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'ENVIAR ENLACE',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          TextButton.icon(
            onPressed: () => context.go(RoutesAgencia.login),
            icon: const Icon(Icons.arrow_back, size: 16),
            label: const Text('Regresar al Login'),
            style: TextButton.styleFrom(foregroundColor: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
        const SizedBox(height: 24),
        const Text(
          '¡Enlace Enviado!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          'Hemos enviado un enlace a tu correo.\nRevisa tu bandeja de entrada.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
        const SizedBox(height: 48),
        TextButton(
          onPressed: () => context.go(RoutesAgencia.login),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF0F4C75)),
          child: const Text('Volver al Inicio de Sesión'),
        ),
      ],
    );
  }
}
