import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/navigation/routes_guia.dart';
import 'package:frontend/features/guia/auth/presentation/cubit/guia_agency_login_cubit.dart';

/// Paso 2 del flujo B2B: el guía confirma su número de teléfono registrado.
/// Recibe el folio validado como [folio] desde la ruta anterior.
class PantallaPhoneGuia extends StatefulWidget {
  final String folio;

  const PantallaPhoneGuia({super.key, required this.folio});

  @override
  State<PantallaPhoneGuia> createState() => _PantallaPhoneGuiaState();
}

class _PantallaPhoneGuiaState extends State<PantallaPhoneGuia> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onConfirmar(BuildContext context) {
    context.read<GuiaAgencyLoginCubit>().submitPhone(
      widget.folio,
      _phoneController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GuiaAgencyLoginCubit, GuiaAgencyLoginState>(
      listener: (context, state) {
        if (state is GuiaAgencyAuthenticated) {
          context.go(RoutesGuia.home);
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
                        'Confirma número de teléfono',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Coloque su número de teléfono',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                      ),
                      const SizedBox(height: 24),

                      // Campo teléfono
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: InputDecoration(
                          hintText: '722-569-8563',
                          hintStyle: const TextStyle(color: Colors.black38),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onSubmitted: (_) => _onConfirmar(context),
                      ),
                      const SizedBox(height: 20),

                      // Botón Confirmar
                      BlocBuilder<GuiaAgencyLoginCubit, GuiaAgencyLoginState>(
                        builder: (context, state) {
                          if (state is GuiaAgencyLoginLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return ElevatedButton(
                            onPressed: () => _onConfirmar(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3D5AF1),
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text('Confirmar'),
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
