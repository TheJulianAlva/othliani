import 'package:flutter/material.dart';
import 'package:frontend/core/utils/e164_utils.dart';
import 'package:frontend/core/widgets/info_modal.dart';
import 'package:frontend/core/widgets/phone_number_field.dart';

/// Pantalla que utiliza el widget reutilizable y muestra botón Confirmar.

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  PhoneNumberValue? _current;

  void _onConfirm() {
    if (!_formKey.currentState!.validate()) return;
    if (_current == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete el número de teléfono')),
      );
      return;
    }

    // Construimos las partes explícitas
    final parts = partsFrom(
      countryCode: _current!.countryCode, // MX
      dialCode: _current!.dialCode, // +52
      localDigits: _current!.localDigits, // 7225698563
    );

    // Aquí puedes enviar al backend (Firebase/API)
    debugPrint(
      'codigo: ${parts.codigo} | numero: ${parts.numero} | pais: ${parts.pais} | e164: ${parts.e164}',
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Número confirmado: ${parts.e164}')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                            'Confirma número de teléfono',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Coloque su número de teléfono',
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
                              child: const Text('Confirmar'),
                            ),
                          ),
                          const SizedBox(height: 24),
                          GestureDetector(
                            onTap: () {
                              InfoModal.show(
                                context: context,
                                title: 'Aviso de Privacidad',
                                content: '''
Este es el texto de ejemplo para el Aviso de Privacidad...
Este es el texto de ejemplo para el Aviso de Privacidad...
Este es el texto de ejemplo para el Aviso de Privacidad...
Este es el texto de ejemplo para el Aviso de Privacidad...
Este es el texto de ejemplo para el Aviso de Privacidad...
Este es el texto de ejemplo para el Aviso de Privacidad...
Este es el texto de ejemplo para el Aviso de Privacidad...
Este es el texto de ejemplo para el Aviso de Privacidad...
Este es el texto de ejemplo para el Aviso de Privacidad...
Este es el texto de ejemplo para el Aviso de Privacidad...
Este es el texto de ejemplo para el Aviso de Privacidad...
Este es el texto de ejemplo para el Aviso de Privacidad...
Este es el texto de ejemplo para el Aviso de Privacidad...
Este es el texto de ejemplo para el Aviso de Privacidad...

''',
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
