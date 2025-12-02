import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/navigation/routes_turista.dart';
import 'package:frontend/core/utils/e164_utils.dart';
import 'package:frontend/core/widgets/info_modal.dart';
import 'package:frontend/core/widgets/phone_number_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  PhoneNumberValue? _current;

  void _onConfirm() {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_current == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.enterPhone)),
      );
      return;
    }

    final parts = partsFrom(
      countryCode: _current!.countryCode,
      dialCode: _current!.dialCode,
      localDigits: _current!.localDigits,
    );

    debugPrint(
      'codigo: ${parts.codigo} | numero: ${parts.numero} | pais: ${parts.pais} | e164: ${parts.e164}',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${l10n.phoneNumber}: ${parts.e164}')),
    );

    context.push(RoutesTurista.smsVerification);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            const hPad = 24.0;
            const vPad = 32.0;

            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _onConfirm,
                              child: Text(l10n.sendCode),
                            ),
                          ),
                          const SizedBox(height: 24),
                          GestureDetector(
                            onTap: () {
                              InfoModal.show(
                                context: context,
                                title: 'Aviso de Privacidad',
                                content: 'Contenido del aviso de privacidad...',
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
    );
  }
}
