import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/navigation/routes_turista.dart';
import 'package:frontend/core/utils/e164_utils.dart';
import 'package:frontend/core/widgets/info_modal.dart';
import 'package:frontend/core/widgets/phone_number_field.dart';
import 'package:frontend/core/di/service_locator.dart';
import 'package:frontend/features/turista/auth/presentation/cubit/verification_cubit.dart';
import 'package:frontend/features/turista/auth/presentation/cubit/verification_state.dart';
import 'package:frontend/core/l10n/app_localizations.dart';

class PhoneScreen extends StatelessWidget {
  const PhoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VerificationCubit>(),
      child: const _PhoneView(),
    );
  }
}

class _PhoneView extends StatefulWidget {
  const _PhoneView();

  @override
  State<_PhoneView> createState() => _PhoneViewState();
}

class _PhoneViewState extends State<_PhoneView> {
  final _formKey = GlobalKey<FormState>();
  PhoneNumberValue? _current;

  void _onConfirm(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_current == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.enterPhone)));
      return;
    }

    final parts = partsFrom(
      countryCode: _current!.countryCode,
      dialCode: _current!.dialCode,
      localDigits: _current!.localDigits,
    );

    context.read<VerificationCubit>().requestPhoneCode(parts.e164);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocListener<VerificationCubit, VerificationState>(
        listener: (context, state) {
          if (state is PhoneCodeSent) {
            context.push(RoutesTurista.smsVerification);
          } else if (state is VerificationError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const hPad = 24.0;
              const vPad = 32.0;

              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(
                  horizontal: hPad,
                  vertical: vPad,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - (vPad * 2),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.verifyPhone,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.enterPhone,
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),
                            PhoneNumberField(
                              initialCountryCode: 'MX',
                              initialDialCode: '+52',
                              mask: '###-###-####',
                              expectedLengths: const {
                                'MX': 10,
                                'US': 10,
                                'ES': 9,
                              },
                              onChanged: (value) => _current = value,
                            ),
                            const SizedBox(height: 28),
                            BlocBuilder<VerificationCubit, VerificationState>(
                              builder: (context, state) {
                                return SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed:
                                        state is VerificationLoading
                                            ? null
                                            : () => _onConfirm(context),
                                    child:
                                        state is VerificationLoading
                                            ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                            : Text(l10n.sendCode),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            GestureDetector(
                              onTap: () {
                                InfoModal.show(
                                  context: context,
                                  title: 'Aviso de Privacidad',
                                  content:
                                      'Contenido del aviso de privacidad...',
                                );
                              },
                              child: Text(
                                'Privacidad',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
