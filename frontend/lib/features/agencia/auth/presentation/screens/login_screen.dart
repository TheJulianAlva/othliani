import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../../../../core/navigation/routes_agencia.dart';
import 'package:frontend/core/di/service_locator.dart';
import '../widgets/agency_auth_layout.dart'; // Local import within feature
import '../blocs/login/login_bloc.dart';

class AgencyLoginScreen extends StatelessWidget {
  const AgencyLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(repository: sl()),
      child: const _LoginForm(),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();

  final _passwordMaskFormatter = MaskTextInputFormatter(
    mask: '##-####-##',
    filter: {"#": RegExp(r'[a-zA-Z0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  bool _isPasswordVisible = false;

  final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  @override
  void initState() {
    super.initState();
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
      context.read<LoginBloc>().add(
        LoginSubmitted(
          email: _emailController.text,
          password:
              _passwordController
                  .text, // Sending formatted or plain? Controller has formatted.
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          context.go(RoutesAgencia.dashboard);
        } else if (state is LoginFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is LoginLoading;

        return AgencyAuthLayout(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: const [
                      Icon(Icons.business, size: 40, color: Color(0xFF0F4C75)),
                      SizedBox(height: 12),
                      Text(
                        'Bienvenido al Panel',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Ingresa tus credenciales',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                TextFormField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  textInputAction: TextInputAction.next,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Correo Electrónico',
                    hintText: 'usuario@dominio.com',
                    filled: false,
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFD1D5DB)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFF0F4C75),
                        width: 2,
                      ),
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

                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.done,
                  enabled: !isLoading,
                  onFieldSubmitted: (_) => _submit(),
                  inputFormatters: [
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      return newValue.copyWith(
                        text: newValue.text.toUpperCase(),
                      );
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
                      borderSide: BorderSide(
                        color: Color(0xFF0F4C75),
                        width: 2,
                      ),
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
                    if (_passwordMaskFormatter.getUnmaskedText().length < 6) {
                      return 'Mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed:
                        isLoading
                            ? null
                            : () {
                              context.push(RoutesAgencia.recoverPassword);
                            },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF0F4C75),
                    ),
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F4C75),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 2,
                    ),
                    child:
                        isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
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

                Column(
                  children: [
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      '© 2026 Othliani Systems v1.0',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
