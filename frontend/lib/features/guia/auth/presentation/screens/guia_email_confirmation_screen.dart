import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Text(
                'Se ha enviado un\ncorreo de\nrestablecimiento.',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 40),
              // Tiempo de espera
              Text(
                'Tiempo de espera:',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _segundosRestantes > 0
                    ? '$_segundosRestantes segundos:'
                    : '0 segundos:',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Mensaje de no recibido
              Text(
                '¿No se ha enviado el mensaje?',
                style: Theme.of(context).textTheme.bodyMedium,
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
                onPressed: () => context.pop(),
                child: const Text('Volver al inicio de sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
