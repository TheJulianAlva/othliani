import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/navigation/routes_turista.dart';
import 'package:frontend/core/di/service_locator.dart';
import 'package:frontend/features/turista/auth/presentation/cubit/verification_cubit.dart';
import 'package:frontend/features/turista/auth/presentation/cubit/verification_state.dart';
// ignore: unused_import
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo placeholder (large blue logo)
                      Icon(
                        Icons.sailing, // Fallback icon if logo image is missing
                        size: 100,
                        color: theme.primaryColor,
                      ),
                      const SizedBox(height: 48),
                      TextFormField(
                        controller: _folioController,
                        style: const TextStyle(fontSize: 18),
                        decoration: InputDecoration(
                          hintText: 'Ingresa tu Folio de Viaje',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.primaryColor,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingresa tu Folio de Viaje';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      BlocBuilder<VerificationCubit, VerificationState>(
                        builder: (context, state) {
                          return SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              onPressed:
                                  state is VerificationLoading
                                      ? null
                                      : () => _onConfirm(context),
                              child:
                                  state is VerificationLoading
                                      ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                      : const Text(
                                        'Comenzar Aventura',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                            ),
                          );
                        },
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
