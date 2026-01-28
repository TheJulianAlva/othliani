import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/mock/mock_database.dart'; // Mantener para incidentes por ahora
import '../../injection_container.dart';
import '../blocs/dashboard/dashboard_bloc.dart';
import '../widgets/kpi_card.dart';
import '../widgets/agency_map_widget.dart';
import '../widgets/incident_panel.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DashboardBloc>()..add(LoadDashboardStats()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F8),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Row 1: Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Resumen Operativo',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F4C75),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: const Text('Hoy: 22 Enero 2026'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Row 2: KPI Cards (Using BLoC)
              BlocBuilder<DashboardBloc, DashboardState>(
                builder: (context, state) {
                  if (state is DashboardLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is DashboardLoaded) {
                    final stats = state.stats;
                    return Row(
                      children: [
                        Expanded(
                          child: KPICard(
                            title: 'Viajes',
                            icon: Icons.directions_bus,
                            value: '${stats.viajesActivos}',
                            subtitle: '5 Programados',
                            onTap: () => context.go('/viajes?status=active'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: KPICard(
                            title: 'Turistas',
                            icon: Icons.groups,
                            value: '${stats.turistasEnCampo}',
                            subtitle: '3 Sin Red',
                            onTap: () => context.go('/usuarios?tab=clients'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: KPICard(
                            title: 'Alertas',
                            icon: Icons.warning,
                            value: '${stats.alertasCriticas}'.padLeft(2, '0'),
                            subtitle: 'Críticas',
                            isAlert: stats.alertasCriticas > 0,
                            onTap:
                                () => context.go('/auditoria?filter=critical'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: KPICard(
                            title: 'Guías',
                            icon: Icons.support_agent,
                            value: '${stats.guiasOffline}',
                            subtitle: '2 Offline',
                            onTap:
                                () =>
                                    context.go('/usuarios?tab=guides&status=offline'),
                          ),
                        ),
                      ],
                    );
                  } else if (state is DashboardError) {
                    return Center(child: Text(state.message));
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              const SizedBox(height: 24),

              // Row 3: Map & Incident Panel
              SizedBox(
                height: 500,
                child: Row(
                  children: [
                    // Map (70%)
                    Expanded(
                      flex: 7,
                      child: AgencyMapWidget(),
                    ),

                    const SizedBox(width: 24),

                    // Incident Panel (30%)
                    // Nota: IncidentPanel sigue usando MockDatabase directamente por ahora
                    // ya que DashboardStats solo tiene contadores.
                    Expanded(
                      flex: 3,
                      child: IncidentPanel(incidentes: MockDatabase().alertas),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
