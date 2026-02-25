import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/di/service_locator.dart';
import 'package:frontend/core/navigation/routes_guia.dart';
import 'package:frontend/features/guia/auth/domain/usecases/activate_subscription_guia_usecase.dart';
import 'package:frontend/features/guia/auth/presentation/cubit/guia_mock_payment_cubit.dart';

class GuiaMockPaymentScreen extends StatelessWidget {
  final String plan;
  final double precio;

  const GuiaMockPaymentScreen({
    super.key,
    required this.plan,
    required this.precio,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<GuiaMockPaymentCubit>(),
      child: _GuiaMockPaymentView(plan: plan, precio: precio),
    );
  }
}

class _GuiaMockPaymentView extends StatefulWidget {
  final String plan;
  final double precio;

  const _GuiaMockPaymentView({required this.plan, required this.precio});

  @override
  State<_GuiaMockPaymentView> createState() => _GuiaMockPaymentViewState();
}

class _GuiaMockPaymentViewState extends State<_GuiaMockPaymentView> {
  final _tarjetaCtrl = TextEditingController(text: '4242 4242 4242 4242');
  final _titularCtrl = TextEditingController(text: 'JUAN MORALES');
  final _fechaCtrl = TextEditingController(text: '12/27');
  final _cvvCtrl = TextEditingController(text: '123');

  @override
  void dispose() {
    _tarjetaCtrl.dispose();
    _titularCtrl.dispose();
    _fechaCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  void _onActivar(BuildContext context) {
    context.read<GuiaMockPaymentCubit>().activateSubscription(
      ActivateSubscriptionGuiaParams(
        plan: widget.plan,
        precioPorMes: widget.precio,
        titularTarjeta: _titularCtrl.text,
        numeroTarjeta: _tarjetaCtrl.text,
        fechaVencimiento: _fechaCtrl.text,
        cvv: _cvvCtrl.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<GuiaMockPaymentCubit, GuiaMockPaymentState>(
      listener: (context, state) {
        if (state is GuiaMockPaymentSuccess) {
          context.go(RoutesGuia.paymentSuccess);
        } else if (state is GuiaMockPaymentFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Activar protección',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // ── Resumen del plan ─────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Plan ${widget.plan}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'OhtliAni Guía Independiente',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      Text(
                        '\$${widget.precio.toInt()}/mes',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Número de tarjeta ────────────────────────────────────
                _buildCampo(
                  context,
                  'Número de tarjeta',
                  _tarjetaCtrl,
                  hint: '#### #### #### ####',
                  teclado: TextInputType.number,
                  prefijo: const Icon(Icons.credit_card),
                ),
                const SizedBox(height: 16),

                // ── Nombre del titular ───────────────────────────────────
                _buildCampo(
                  context,
                  'Nombre del titular',
                  _titularCtrl,
                  hint: 'NOMBRE EN TARJETA',
                ),
                const SizedBox(height: 16),

                // ── Fecha y CVV ──────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _buildCampo(
                        context,
                        'Vencimiento',
                        _fechaCtrl,
                        hint: 'MM/YY',
                        teclado: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildCampo(
                        context,
                        'CVV',
                        _cvvCtrl,
                        hint: '•••',
                        teclado: TextInputType.number,
                        ocultarTexto: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Nota de seguridad ────────────────────────────────────
                Row(
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Pago seguro simulado (entorno de prueba)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // ── Botón activar ────────────────────────────────────────
                BlocBuilder<GuiaMockPaymentCubit, GuiaMockPaymentState>(
                  builder: (context, state) {
                    if (state is GuiaMockPaymentProcessing) {
                      return Column(
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 12),
                          Text(
                            'Validando con el banco…',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      );
                    }
                    return ElevatedButton.icon(
                      onPressed: () => _onActivar(context),
                      icon: const Icon(Icons.shield_outlined),
                      label: const Text('Activar Protección OhtliAni'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCampo(
    BuildContext context,
    String label,
    TextEditingController ctrl, {
    String? hint,
    bool ocultarTexto = false,
    TextInputType teclado = TextInputType.text,
    Widget? prefijo,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          obscureText: ocultarTexto,
          keyboardType: teclado,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefijo,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
