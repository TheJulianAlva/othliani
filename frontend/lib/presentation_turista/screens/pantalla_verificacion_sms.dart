import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/navigation/routes_turista.dart';
import 'package:frontend/presentation_turista/widgets/verification_status_widget.dart';
import 'package:frontend/core/di/service_locator.dart';
import 'package:frontend/features/turista/auth/presentation/cubit/verification_cubit.dart';
import 'package:frontend/features/turista/auth/presentation/cubit/verification_state.dart';
import 'package:frontend/core/l10n/app_localizations.dart';

class SmsVerificationScreen extends StatelessWidget {
  const SmsVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VerificationCubit>(),
      child: const _SmsView(),
    );
  }
}

class _SmsView extends StatefulWidget {
  const _SmsView();

  @override
  State<_SmsView> createState() => _SmsViewState();
}

class _SmsViewState extends State<_SmsView> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _onVerify(BuildContext context) {
    final code = _codeController.text.trim();
    if (code.length == 6) {
      // In a real app, we would get the phone number from arguments or state
      // For this migration, we'll use a hardcoded/mocked phone number as it's not passed yet
      context.read<VerificationCubit>().verifyPhoneCode('+521234567890', code);
    }
  }

  void _onResend(BuildContext context) {
    // Similarly, phone number should be known
    context.read<VerificationCubit>().requestPhoneCode('+521234567890');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.verify),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocConsumer<VerificationCubit, VerificationState>(
        listener: (context, state) {
          if (state is PhoneVerified && state.isValid) {
            context.go(RoutesTurista.register);
          } else if (state is PhoneCodeSent) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.codeDescription)));
          } else if (state is VerificationError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return SafeArea(
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
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, letterSpacing: 8),
                    decoration: InputDecoration(
                      hintText: '------',
                      labelText: l10n.verificationCode,
                      border: const OutlineInputBorder(),
                    ),
                    maxLength: 6,
                    onChanged: (value) {
                      if (value.length == 6) {
                        _onVerify(context);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed:
                          state is VerificationLoading
                              ? null
                              : () => _onVerify(context),
                      child:
                          state is VerificationLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : Text(l10n.verify),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
