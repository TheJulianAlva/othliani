import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/presentation_turista/widgets/verification_status_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/navigation/routes_turista.dart';

class SmsVerificationScreen extends StatelessWidget {
  const SmsVerificationScreen({super.key});

  void _onResend(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('SMS reenviado')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RoutesTurista.phoneConfirm),
        ),
        title: const Text('Verificación'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              VerificationStatusWidget(
                message: 'Se ha enviado un mensaje de texto.',
                onResend: () => _onResend(context),
              ),
              const SizedBox(height: 40),
              // Code Input Field
              const TextField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, letterSpacing: 8),
                decoration: InputDecoration(
                  hintText: '------',
                  labelText: 'Código de verificación',
                  border: OutlineInputBorder(),
                ),
                maxLength: 6,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // Verify code logic
                    context.go(RoutesTurista.register);
                  },
                  child: const Text('Verificar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
