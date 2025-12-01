import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/presentation_turista/widgets/circular_timer.dart';

class VerificationStatusWidget extends StatefulWidget {
  final String message;
  final VoidCallback onResend;

  const VerificationStatusWidget({
    super.key,
    required this.message,
    required this.onResend,
  });

  @override
  State<VerificationStatusWidget> createState() =>
      _VerificationStatusWidgetState();
}

class _VerificationStatusWidgetState extends State<VerificationStatusWidget> {
  bool _canResend = false;
  // Key to reset timer when resending
  int _timerKey = 0;

  void _onTimerComplete() {
    setState(() {
      _canResend = true;
    });
  }

  void _handleResend() {
    widget.onResend();
    setState(() {
      _canResend = false;
      _timerKey++; // Force timer rebuild
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.message,
          textAlign: TextAlign.center,
          style: const TextStyle(
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
        if (!_canResend)
          CircularTimer(
            key: ValueKey(_timerKey),
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
            onPressed: _canResend ? _handleResend : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _canResend ? AppColors.primary : Colors.grey,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reenviar'),
          ),
        ),
      ],
    );
  }
}
