import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/navigation/routes_agencia.dart';
import '../widgets/agency_auth_layout.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class AgencyLoginScreen extends StatefulWidget {
  const AgencyLoginScreen({super.key});

  @override
  State<AgencyLoginScreen> createState() => _AgencyLoginScreenState();
}

class _AgencyLoginScreenState extends State<AgencyLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode(); // FocusNode para auto-focus

  // Format: XX-XXXX-XX (alphanumeric allowed based on user request "X")
  final _passwordMaskFormatter = MaskTextInputFormatter(
    mask: '##-####-##',
    filter: {"#": RegExp(r'[a-zA-Z0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  bool _isPasswordVisible = false;

  // Email Regex
  final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  @override
  void initState() {
    super.initState();
    // Auto-focus en el campo de correo cuando se carga la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _emailFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Simulate Login Success
      context.go(RoutesAgencia.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AgencyAuthLayout(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo Small
            Align(
              alignment: Alignment.center,
              child: Column(
                children: const [
                  Icon(Icons.business, size: 40, color: Color(0xFF0F4C75)),
                  SizedBox(height: 12),
                  Text(
                    'Bienvenido al Panel',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Ingresa tus credenciales',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Email Input
            TextFormField(
              controller: _emailController,
              focusNode: _emailFocusNode, // Asignar FocusNode
              textInputAction: TextInputAction.next,
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
            const SizedBox(height: 24),

            // Password Input
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              inputFormatters: [
                TextInputFormatter.withFunction((oldValue, newValue) {
                  return newValue.copyWith(text: newValue.text.toUpperCase());
                }),
                _passwordMaskFormatter,
              ],
              decoration: InputDecoration(
                labelText: 'Contraseña',
                hintText: 'Ej. AB-1234-CD',
                filled: false,
                border: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD1D5DB)),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0F4C75), width: 2),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo requerido';
                }
                // Check mask completeness or length.
                // Unmasked length >= 6 chars.
                if (_passwordMaskFormatter.getUnmaskedText().length < 6) {
                  return 'Mínimo 6 caracteres';
                }
                return null;
              },
            ),

            // Forgot Password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  context.push(RoutesAgencia.recoverPassword);
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF0F4C75),
                ),
                child: const Text('¿Olvidaste tu contraseña?'),
              ),
            ),
            const SizedBox(height: 32),

            // Login Button
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
                  elevation: 2,
                ),
                child: const Text(
                  'INGRESAR AL SISTEMA',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),

            // Footer
            Column(
              children: [
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  '© 2026 Othliani Systems v1.0',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "Privacidad",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "Soporte",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
