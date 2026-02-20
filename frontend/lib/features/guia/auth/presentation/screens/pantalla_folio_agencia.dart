import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/navigation/routes_guia.dart';
import 'package:frontend/features/guia/auth/presentation/cubit/guia_agency_login_cubit.dart';

/// Paso 1 del flujo B2B: el guía ingresa el folio proporcionado por su agencia.
/// El [GuiaAgencyLoginCubit] es provisto por el router.
class PantallaFolioAgencia extends StatefulWidget {
  const PantallaFolioAgencia({super.key});

  @override
  State<PantallaFolioAgencia> createState() => _PantallaFolioAgenciaState();
}

class _PantallaFolioAgenciaState extends State<PantallaFolioAgencia> {
  final _folioController = TextEditingController();

  @override
  void dispose() {
    _folioController.dispose();
    super.dispose();
  }

  void _onIngresar(BuildContext context) {
    context.read<GuiaAgencyLoginCubit>().submitFolio(_folioController.text);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GuiaAgencyLoginCubit, GuiaAgencyLoginState>(
      listener: (context, state) {
        if (state is GuiaAgencyFolioValidated) {
          context.push(RoutesGuia.agencyPhone, extra: state.folio);
        } else if (state is GuiaAgencyLoginFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F0F0),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: const BackButton(color: Colors.black87),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 32),

                // Tarjeta blanca
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Bienvenido a Otlhiani',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Coloque su folio con el que está registrado en la agencia',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                      ),
                      const SizedBox(height: 24),

                      // Campo folio
                      TextField(
                        controller: _folioController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          hintText: 'xxxxx-xxxxx-xxx',
                          hintStyle: const TextStyle(color: Colors.black38),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onSubmitted: (_) => _onIngresar(context),
                      ),
                      const SizedBox(height: 20),

                      // Botón Ingresar
                      BlocBuilder<GuiaAgencyLoginCubit, GuiaAgencyLoginState>(
                        builder: (context, state) {
                          if (state is GuiaAgencyLoginLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return ElevatedButton(
                            onPressed: () => _onIngresar(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3D5AF1),
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text('Ingresar'),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Link Privacidad
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Privacidad',
                    style: TextStyle(color: Color(0xFF3D5AF1)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
