import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/navigation/routes_guia.dart';
import 'package:frontend/core/theme/app_colors.dart';

class GuiaEmailConfirmationScreen extends StatefulWidget {
  const GuiaEmailConfirmationScreen({super.key});

  @override
  State<GuiaEmailConfirmationScreen> createState() =>
      _GuiaEmailConfirmationScreenState();
}

class _GuiaEmailConfirmationScreenState
    extends State<GuiaEmailConfirmationScreen> {
  static const int _tiempoEspera = 30;
  int _segundosRestantes = _tiempoEspera;
  Timer? _timer;
  bool _reenviando = false;

  @override
  void initState() {
    super.initState();
    _iniciarCuentaRegresiva();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _iniciarCuentaRegresiva() {
    _timer?.cancel();
    setState(() {
      _segundosRestantes = _tiempoEspera;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_segundosRestantes <= 1) {
        timer.cancel();
        setState(() {
          _segundosRestantes = 0;
        });
      } else {
        setState(() {
          _segundosRestantes--;
        });
      }
    });
  }

  Future<void> _onReenviar() async {
    if (_segundosRestantes > 0 || _reenviando) return;

    setState(() {
      _reenviando = true;
    });

    // Simula envío de correo
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _reenviando = false;
    });

    _iniciarCuentaRegresiva();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Correo reenviado correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool puedeReenviar = _segundosRestantes == 0 && !_reenviando;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RoutesGuia.login),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Se ha enviado un\ncorreo de\nrestablecimiento.',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 40),
              // Tiempo de espera
              Text(
                'Tiempo de espera:',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _segundosRestantes > 0
                    ? '$_segundosRestantes segundos:'
                    : '0 segundos:',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Mensaje de no recibido
              Text(
                '¿No se ha enviado el mensaje?',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Botón Reenviar
              ElevatedButton(
                onPressed: puedeReenviar ? _onReenviar : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child:
                    _reenviando
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Reenviar'),
              ),
              const SizedBox(height: 24),
              // Botón volver al login
              TextButton(
                onPressed: () => context.go(RoutesGuia.login),
                child: const Text('Volver al inicio de sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
