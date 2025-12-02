import 'package:flutter/material.dart';
import 'package:frontend/core/navigation/routes_turista.dart';
import 'package:frontend/core/widgets/info_modal.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FolioScreen extends StatefulWidget {
  const FolioScreen({super.key});

  @override
  State<FolioScreen> createState() => _FolioScreenState();
}

class _FolioScreenState extends State<FolioScreen> {
  final _folioController = TextEditingController();

  @override
  void dispose() {
    _folioController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final l10n = AppLocalizations.of(context)!;
    final folio = _folioController.text.trim();
    if (folio.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.folioDescription),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    context.go(RoutesTurista.phoneConfirm);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 50,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        l10n.appTitle,
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l10n.folioDescription,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 35),
                      TextField(
                        controller: _folioController,
                        decoration: const InputDecoration(
                          hintText: 'XXXXX-XXXXXX-XXX',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        textCapitalization: TextCapitalization.characters,
                      ),
                      const SizedBox(height: 35),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleSubmit,
                          child: Text(l10n.continueButton),
                        ),
                      ),
                      const SizedBox(height: 80),
                      GestureDetector(
                        onTap: () {
                          InfoModal.show(
                            context: context,
                            title: 'Aviso de Privacidad',
                            content: '''                                     
Este es el texto de ejemplo para el Aviso de Privacidad.
Incluye políticas de datos personales, finalidad del tratamiento,
mecanismos de acceso, rectificación y cancelación, etc.
Por favor, asegúrese de leer y comprender estos términos antes de continuar.
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
        ),
      ),
    );
  }
}
