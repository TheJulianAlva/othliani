import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/navigation/routes_turista.dart';
import 'package:frontend/features/turista/auth/presentation/widgets/verification_status_widget.dart';
import 'package:frontend/core/di/service_locator.dart';
import 'package:frontend/features/turista/auth/presentation/cubit/verification_cubit.dart';
import 'package:frontend/features/turista/auth/presentation/cubit/verification_state.dart';
import 'package:frontend/core/l10n/app_localizations.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VerificationCubit>(),
      child: const _EmailView(),
    );
  }
}

class _EmailView extends StatelessWidget {
  const _EmailView();

  void _onResend(BuildContext context) {
    // In a real app we would know the email from args/state
    context.read<VerificationCubit>().resendEmail('user@example.com');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RoutesTurista.login),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocListener<VerificationCubit, VerificationState>(
        listener: (context, state) {
          if (state is EmailSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.codeDescription),
              ), // Reusing message for "sent"
            );
          } else if (state is VerificationError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: VerificationStatusWidget(
                message: l10n.sendResetLink,
                onResend: () => _onResend(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
