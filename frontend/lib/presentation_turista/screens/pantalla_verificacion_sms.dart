import 'package:flutter/material.dart';
import 'package:frontend/presentation_turista/widgets/verification_status_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/navigation/routes_turista.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SmsVerificationScreen extends StatelessWidget {
  const SmsVerificationScreen({super.key});

  void _onResend(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.resendCode)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RoutesTurista.phoneConfirm),
        ),
        title: Text(l10n.verify),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              VerificationStatusWidget(
                message: l10n.codeDescription,
                onResend: () => _onResend(context),
              ),
              const SizedBox(height: 40),
              TextField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 8),
                decoration: InputDecoration(
                  hintText: '------',
                  labelText: l10n.verificationCode,
                  border: const OutlineInputBorder(),
                ),
                maxLength: 6,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    context.go(RoutesTurista.register);
                  },
                  child: Text(l10n.verify),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
