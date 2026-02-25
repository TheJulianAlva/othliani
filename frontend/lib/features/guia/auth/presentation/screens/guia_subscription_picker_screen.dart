import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/navigation/routes_guia.dart';

/// Modelo de datos para cada plan
class _PlanData {
  final String nombre;
  final double precio;
  final String descripcion;
  final List<String> beneficios;
  final bool esPopular;

  const _PlanData({
    required this.nombre,
    required this.precio,
    required this.descripcion,
    required this.beneficios,
    this.esPopular = false,
  });
}

class GuiaSubscriptionPickerScreen extends StatefulWidget {
  const GuiaSubscriptionPickerScreen({super.key});

  @override
  State<GuiaSubscriptionPickerScreen> createState() =>
      _GuiaSubscriptionPickerScreenState();
}

class _GuiaSubscriptionPickerScreenState
    extends State<GuiaSubscriptionPickerScreen> {
  static const _planes = [
    _PlanData(
      nombre: 'Basic',
      precio: 9,
      descripcion: 'Para individuos y viajes anuales',
      beneficios: [
        'Botón SOS activo',
        'Itinerarios básicos',
        'Soporte estándar',
        'Hasta 10 participantes',
      ],
    ),
    _PlanData(
      nombre: 'Pro',
      precio: 19,
      descripcion: 'Para guías y grupos en crecimiento',
      beneficios: [
        'Botón SOS + alertas inteligentes',
        'Itinerarios ilimitados',
        'Chat con participantes',
        'Hasta 50 participantes',
        'Reportes de viaje',
      ],
      esPopular: true,
    ),
    _PlanData(
      nombre: 'Business',
      precio: 99,
      descripcion: 'Para organizaciones con necesidades avanzadas',
      beneficios: [
        'Todo lo de Pro',
        'Integración con agencias',
        'API de seguridad',
        'Participantes ilimitados',
        'Soporte prioritario 24/7',
        'Análisis de riesgo ISO 31000',
      ],
    ),
  ];

  String _planSeleccionado = 'Pro';

  void _irAPago(BuildContext context) {
    final plan = _planes.firstWhere((p) => p.nombre == _planSeleccionado);
    context.push(
      RoutesGuia.mockPayment,
      extra: {'plan': plan.nombre, 'precio': plan.precio},
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Pricing',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Our pricing is not expensive, but it\'s not cheap either; it\'s exactly what it should be.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // ── Cards de planes ──────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    _planes.map((plan) {
                      return Expanded(
                        child: _PlanCard(
                          plan: plan,
                          seleccionado: _planSeleccionado == plan.nombre,
                          onSeleccionar:
                              () => setState(
                                () => _planSeleccionado = plan.nombre,
                              ),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 28),

              // ── Tabla comparativa ────────────────────────────────────────
              _buildTablaComparativa(context),
              const SizedBox(height: 32),

              // ── Botón elegir plan ────────────────────────────────────────
              ElevatedButton(
                onPressed: () => _irAPago(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Text('Continuar con plan $_planSeleccionado'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTablaComparativa(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final features = [
      ('Botón SOS', [true, true, true]),
      ('Itinerarios', [true, true, true]),
      ('Chat participantes', [false, true, true]),
      ('Alertas inteligentes', [false, true, true]),
      ('API de seguridad', [false, false, true]),
      ('Reportes de viaje', [false, true, true]),
      ('Soporte 24/7', [false, false, true]),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Compare Features',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        // Encabezado de columnas
        Row(
          children: [
            const Expanded(flex: 3, child: SizedBox()),
            ...['Basic', 'Pro', 'Business'].map(
              (n) => Expanded(
                flex: 2,
                child: Text(
                  n,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        const Divider(height: 16),
        ...features.map(
          (f) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    f.$1,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                ...f.$2.map(
                  (tiene) => Expanded(
                    flex: 2,
                    child: Icon(
                      tiene ? Icons.check_circle : Icons.cancel,
                      color:
                          tiene
                              ? colorScheme.primary
                              : colorScheme.surfaceContainerHighest,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── PlanCard Widget ──────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final _PlanData plan;
  final bool seleccionado;
  final VoidCallback onSeleccionar;

  const _PlanCard({
    required this.plan,
    required this.seleccionado,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onSeleccionar,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: seleccionado ? colorScheme.primary : colorScheme.outline,
            width: seleccionado ? 2 : 1,
          ),
          color:
              seleccionado
                  ? colorScheme.primary.withAlpha(20)
                  : colorScheme.surface,
        ),
        child: Column(
          children: [
            if (plan.esPopular)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Popular',
                  style: TextStyle(
                    fontSize: 10,
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 4),
            Text(
              plan.nombre,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${plan.precio.toInt()}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            Text(
              '/mo',
              style: TextStyle(
                fontSize: 10,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onSeleccionar,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    seleccionado
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHighest,
                foregroundColor:
                    seleccionado
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(60, 28),
                textStyle: const TextStyle(fontSize: 11),
              ),
              child: const Text('Choose'),
            ),
          ],
        ),
      ),
    );
  }
}
