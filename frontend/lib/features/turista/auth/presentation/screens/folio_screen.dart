import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/navigation/routes_turista.dart';
import 'package:frontend/core/widgets/info_modal.dart';
import 'package:frontend/core/di/service_locator.dart';
import 'package:frontend/features/turista/auth/presentation/cubit/verification_cubit.dart';
import 'package:frontend/features/turista/auth/presentation/cubit/verification_state.dart';
import 'package:frontend/core/l10n/app_localizations.dart';

class FolioScreen extends StatelessWidget {
  const FolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VerificationCubit>(),
      child: const _FolioView(),
    );
  }
}

class _FolioView extends StatefulWidget {
  const _FolioView();

  @override
  State<_FolioView> createState() => _FolioViewState();
}

class _FolioViewState extends State<_FolioView> {
  final _formKey = GlobalKey<FormState>();
  final _folioController = TextEditingController();

  @override
  void dispose() {
    _folioController.dispose();
    super.dispose();
  }

  void _onConfirm(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final folio = _folioController.text.trim();
    context.read<VerificationCubit>().verifyFolio(folio);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocListener<VerificationCubit, VerificationState>(
        listener: (context, state) {
          if (state is FolioVerified && state.isValid) {
            context.push(RoutesTurista.phoneConfirm);
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
                              l10n.enterFolio,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.folioDescription,
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _folioController,
                              decoration: InputDecoration(
                                labelText: l10n.folioNumber,
                                prefixIcon: const Icon(
                                  Icons.confirmation_number_outlined,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.enterFolio;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
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
                                            : Text(l10n.continueButton),
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
