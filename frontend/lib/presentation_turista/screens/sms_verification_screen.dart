import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/presentation_turista/widgets/circular_timer.dart';

class SmsVerificationScreen extends StatefulWidget {
  const SmsVerificationScreen({super.key});

  @override
  State<SmsVerificationScreen> createState() => _SmsVerificationScreenState();
}

class _SmsVerificationScreenState extends State<SmsVerificationScreen> {
  bool _canResend = false;

  void _onTimerComplete() {
    setState(() {
      _canResend = true;
    });
  }

  void _onResend() {
    // Logic to resend SMS
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('SMS reenviado')));
    setState(() {
      _canResend = false;
    });
    // Re-mount timer or reset logic would be needed here,
    // but for now we just disable button.
    // Ideally we'd reset the timer key to restart it.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificación'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Se ha enviado un mensaje de texto.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Tiempo de espera:',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              // Use Key to force rebuild when resending if we implemented full reset logic
              // For this demo, just showing the timer once.
              if (!_canResend)
                CircularTimer(
                  duration: const Duration(seconds: 30),
                  onComplete: _onTimerComplete,
                )
              else
                const SizedBox(
                  height: 120,
                  width: 120,
                  child: Center(
                    child: Icon(
                      Icons.timer_off,
                      size: 60,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              const SizedBox(height: 40),
              const Text(
                '¿No se ha enviado el mensaje?',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _canResend ? _onResend : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canResend
                        ? AppColors.primary
                        : Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Reenviar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
