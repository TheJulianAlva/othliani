import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/di/service_locator.dart';
import 'package:frontend/core/navigation/routes_guia.dart';
import 'package:frontend/features/guia/auth/presentation/cubit/guia_login_cubit.dart';

class GuiaLoginScreen extends StatelessWidget {
  const GuiaLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GuiaLoginCubit>(),
      child: const _GuiaLoginView(),
    );
  }
}

class _GuiaLoginView extends StatefulWidget {
  const _GuiaLoginView();

  @override
  State<_GuiaLoginView> createState() => _GuiaLoginViewState();
}

class _GuiaLoginViewState extends State<_GuiaLoginView> {
  final _emailController = TextEditingController(
    text: 'juanmorales@outlook.com',
  );
  final _passwordController = TextEditingController(text: '************');
  final _ocultarPassword = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _ocultarPassword.dispose();
    super.dispose();
  }

  void _onIniciarSesion(BuildContext context) {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor completa todos los campos'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    context.read<GuiaLoginCubit>().login(email, password);
  }

  void _onTengoAgencia(BuildContext context) {
    context.push(RoutesGuia.agencyFolio);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GuiaLoginCubit, GuiaLoginState>(
      listener: (context, state) {
        if (state is GuiaLoginSuccess) {
          context.go(RoutesGuia.home);
        } else if (state is GuiaLoginFailure) {
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
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Text(
                  'Iniciar sesión',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 30),
                _buildCampoTexto(
                  'Correo electrónico:',
                  _emailController,
                  hint: 'juanmorales@outlook.com',
                  teclado: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                ValueListenableBuilder<bool>(
                  valueListenable: _ocultarPassword,
                  builder:
                      (_, ocultar, __) => _buildCampoTexto(
                        'Contraseña:',
                        _passwordController,
                        hint: '************',
                        ocultarTexto: ocultar,
                        sufijo: IconButton(
                          icon: Icon(
                            ocultar ? Icons.visibility_off : Icons.visibility,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          onPressed:
                              () =>
                                  _ocultarPassword.value =
                                      !_ocultarPassword.value,
                        ),
                      ),
                ),
                const SizedBox(height: 30),
                // Botón principal: Ingresar
                BlocBuilder<GuiaLoginCubit, GuiaLoginState>(
                  builder: (context, state) {
                    if (state is GuiaLoginLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ElevatedButton(
                      onPressed: () => _onIniciarSesion(context),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('Ingresar'),
                    );
                  },
                ),
                const SizedBox(height: 8),
                // Enlace: Olvidé mi contraseña
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => context.push(RoutesGuia.forgotPassword),
                    child: const Text('Olvide mi contraseña'),
                  ),
                ),
                const SizedBox(height: 8),
                // Botón: Registrarse
                OutlinedButton(
                  onPressed: () => context.push(RoutesGuia.register),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Registrarse'),
                ),
                const SizedBox(height: 12),
                // Botón: Tengo cuenta de agencia
                ElevatedButton(
                  onPressed: () => _onTengoAgencia(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Tengo cuenta de agencia'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCampoTexto(
    String etiqueta,
    TextEditingController controlador, {
    String? hint,
    bool ocultarTexto = false,
    TextInputType teclado = TextInputType.text,
    Widget? sufijo,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etiqueta,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controlador,
          obscureText: ocultarTexto,
          keyboardType: teclado,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: sufijo,
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
