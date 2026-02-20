import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/di/service_locator.dart';
import 'package:frontend/core/navigation/routes_guia.dart';
import 'package:frontend/features/guia/auth/presentation/cubit/guia_email_verification_cubit.dart';

class GuiaEmailVerificationScreen extends StatelessWidget {
  const GuiaEmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GuiaEmailVerificationCubit>(),
      child: const _GuiaEmailVerificationView(),
    );
  }
}

class _GuiaEmailVerificationView extends StatefulWidget {
  const _GuiaEmailVerificationView();

  @override
  State<_GuiaEmailVerificationView> createState() =>
      _GuiaEmailVerificationViewState();
}

class _GuiaEmailVerificationViewState
    extends State<_GuiaEmailVerificationView> {
  static const int _tiempoEspera = 30;
  final _codigoCtrl = TextEditingController();
  int _segundosRestantes = _tiempoEspera;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _iniciarCuentaRegresiva();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codigoCtrl.dispose();
    super.dispose();
  }

  void _iniciarCuentaRegresiva() {
    _timer?.cancel();
    setState(() => _segundosRestantes = _tiempoEspera);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_segundosRestantes <= 1) {
        timer.cancel();
        setState(() => _segundosRestantes = 0);
      } else {
        setState(() => _segundosRestantes--);
      }
    });
  }

  void _onVerificar(BuildContext context) {
    final codigo = _codigoCtrl.text.replaceAll('-', '').trim();
    if (codigo.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el código de 6 dígitos')),
      );
      return;
    }
    context.read<GuiaEmailVerificationCubit>().verifyEmailCode(codigo);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final puedeReenviar = _segundosRestantes == 0;

    return BlocListener<GuiaEmailVerificationCubit, GuiaEmailVerificationState>(
      listener: (context, state) {
        if (state is GuiaEmailVerificationSuccess) {
          context.push(RoutesGuia.subscriptionPicker);
        } else if (state is GuiaEmailVerificationFailure) {
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
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Text(
                  'Se ha enviado un código al correo registrado',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Ingrese el código recibido para confirmar su registro',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),

                // ── Campo de código ──────────────────────────────────────
                Text(
                  'Código de 6 dígitos:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _codigoCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    letterSpacing: 8,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: '••-••-••',
                    hintStyle: TextStyle(
                      letterSpacing: 6,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Cuenta regresiva ─────────────────────────────────────
                Text(
                  'Tiempo de espera:',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '$_segundosRestantes segundos',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // ── Reenviar ─────────────────────────────────────────────
                Text(
                  '¿No se ha enviado el mensaje?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: puedeReenviar ? _iniciarCuentaRegresiva : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    disabledBackgroundColor:
                        colorScheme.surfaceContainerHighest,
                  ),
                  child: const Text('Reenviar'),
                ),
                const SizedBox(height: 16),

                // ── Verificar ────────────────────────────────────────────
                BlocBuilder<
                  GuiaEmailVerificationCubit,
                  GuiaEmailVerificationState
                >(
                  builder: (context, state) {
                    if (state is GuiaEmailVerificationLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return OutlinedButton(
                      onPressed: () => _onVerificar(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('Verificar código'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
