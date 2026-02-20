import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/di/service_locator.dart';
import 'package:frontend/core/navigation/routes_guia.dart';
import 'package:frontend/features/guia/auth/presentation/cubit/guia_register_cubit.dart';

class GuiaRegisterScreen extends StatelessWidget {
  const GuiaRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GuiaRegisterCubit>(),
      child: const _GuiaRegisterView(),
    );
  }
}

class _GuiaRegisterView extends StatefulWidget {
  const _GuiaRegisterView();

  @override
  State<_GuiaRegisterView> createState() => _GuiaRegisterViewState();
}

class _GuiaRegisterViewState extends State<_GuiaRegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _emergenciaCtrl = TextEditingController();

  // ValueNotifier para toggles de visibilidad — evita setState y rebuild del árbol
  final _ocultarPassword = ValueNotifier<bool>(true);
  final _ocultarConfirm = ValueNotifier<bool>(true);

  bool _aceptaTerminos = false;
  bool _aceptaPrivacidad = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _correoCtrl.dispose();
    _telefonoCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _emergenciaCtrl.dispose();
    _ocultarPassword.dispose();
    _ocultarConfirm.dispose();
    super.dispose();
  }

  void _onCrearCuenta(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    if (!_aceptaTerminos || !_aceptaPrivacidad) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Debes aceptar los términos y el aviso de privacidad',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    context.read<GuiaRegisterCubit>().register(
      nombre: _nombreCtrl.text.trim(),
      apellido: _apellidoCtrl.text.trim(),
      correo: _correoCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
      contactoEmergencia:
          _emergenciaCtrl.text.trim().isEmpty
              ? null
              : _emergenciaCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<GuiaRegisterCubit, GuiaRegisterState>(
      listener: (context, state) {
        if (state is GuiaRegisterSuccess) {
          context.push(RoutesGuia.emailVerification);
        } else if (state is GuiaRegisterFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Ingresa tus datos',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Nombre ─────────────────────────────────────────────
                  _buildCampo(
                    'Nombre:',
                    _nombreCtrl,
                    hint: 'Juan',
                    validator:
                        (v) =>
                            (v == null || v.isEmpty) ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 14),

                  // ── Apellido ───────────────────────────────────────────
                  _buildCampo(
                    'Apellido:',
                    _apellidoCtrl,
                    hint: 'Morales',
                    validator:
                        (v) =>
                            (v == null || v.isEmpty) ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 14),

                  // ── Correo ─────────────────────────────────────────────
                  _buildCampo(
                    'Correo:',
                    _correoCtrl,
                    hint: 'juanmorales@outlook.com',
                    teclado: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Campo requerido';
                      if (!v.contains('@')) return 'Correo inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // ── Teléfono ───────────────────────────────────────────
                  _buildCampo(
                    'Número de teléfono',
                    _telefonoCtrl,
                    hint: '000-0000-000',
                    teclado: TextInputType.phone,
                    validator:
                        (v) =>
                            (v == null || v.isEmpty) ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 14),

                  // ── Contraseña — ValueListenableBuilder para toggle sin setState
                  ValueListenableBuilder<bool>(
                    valueListenable: _ocultarPassword,
                    builder:
                        (_, ocultar, __) => _buildCampo(
                          'Contraseña:',
                          _passwordCtrl,
                          hint: '••••••••••••',
                          ocultarTexto: ocultar,
                          sufijo: IconButton(
                            icon: Icon(
                              ocultar ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed:
                                () =>
                                    _ocultarPassword.value =
                                        !_ocultarPassword.value,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Campo requerido';
                            }
                            if (v.length < 6) return 'Mínimo 6 caracteres';
                            return null;
                          },
                        ),
                  ),
                  const SizedBox(height: 14),

                  // ── Confirmar contraseña ───────────────────────────────
                  ValueListenableBuilder<bool>(
                    valueListenable: _ocultarConfirm,
                    builder:
                        (_, ocultar, __) => _buildCampo(
                          'Confirmar contraseña:',
                          _confirmPasswordCtrl,
                          hint: '••••••••••••',
                          ocultarTexto: ocultar,
                          sufijo: IconButton(
                            icon: Icon(
                              ocultar ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed:
                                () =>
                                    _ocultarConfirm.value =
                                        !_ocultarConfirm.value,
                          ),
                          validator: (v) {
                            if (v != _passwordCtrl.text) {
                              return 'Las contraseñas no coinciden';
                            }
                            return null;
                          },
                        ),
                  ),
                  const SizedBox(height: 14),

                  // ── Contacto emergencia (opcional) ─────────────────────
                  _buildCampo(
                    'Contacto de emergencia (opcional):',
                    _emergenciaCtrl,
                    hint: 'Nombre y teléfono',
                  ),
                  const SizedBox(height: 20),

                  // ── Checkboxes ─────────────────────────────────────────
                  _buildCheckbox(
                    label: 'Términos y condiciones',
                    value: _aceptaTerminos,
                    color: colorScheme.primary,
                    onChanged: (v) => setState(() => _aceptaTerminos = v!),
                  ),
                  const SizedBox(height: 8),
                  _buildCheckbox(
                    label: 'Aviso de privacidad',
                    value: _aceptaPrivacidad,
                    color: colorScheme.primary,
                    onChanged: (v) => setState(() => _aceptaPrivacidad = v!),
                  ),
                  const SizedBox(height: 28),

                  // ── Botón crear cuenta ─────────────────────────────────
                  BlocBuilder<GuiaRegisterCubit, GuiaRegisterState>(
                    builder: (context, state) {
                      if (state is GuiaRegisterLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return ElevatedButton(
                        onPressed: () => _onCrearCuenta(context),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: const Text('Crear cuenta'),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCampo(
    String label,
    TextEditingController ctrl, {
    String? hint,
    bool ocultarTexto = false,
    TextInputType teclado = TextInputType.text,
    Widget? sufijo,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: ctrl,
          obscureText: ocultarTexto,
          keyboardType: teclado,
          validator: validator,
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

  Widget _buildCheckbox({
    required String label,
    required bool value,
    required Color color,
    required void Function(bool?) onChanged,
  }) {
    return Row(
      children: [
        Checkbox(value: value, onChanged: onChanged, activeColor: color),
        GestureDetector(
          onTap: () => onChanged(!value),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
