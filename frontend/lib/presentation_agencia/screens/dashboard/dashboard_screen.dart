import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/navigation/routes_agencia.dart';
import 'package:frontend/injection_container.dart' as di;
import '../../widgets/dashboard/kpi_card.dart';
import '../../widgets/dashboard/incident_panel.dart';
import '../../widgets/dashboard/agency_map_widget.dart';
import 'package:frontend/features/agencia/dashboard/blocs/dashboard/dashboard_bloc.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<DashboardBloc>()..add(LoadDashboardData()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F8),
        body: SingleChildScrollView(
          // Added ScrollView to prevent overflow on smaller screens
          padding: const EdgeInsets.all(24.0),
          child: BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              if (state is DashboardLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is DashboardLoaded) {
                final data = state.data;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resumen Operativo',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F4C75),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- 1. TARJETAS KPI (Con Navegación) ---
                    Row(
                      children: [
                        Expanded(
                          child: KPICard(
                            title: 'VIAJES',
                            value: '${data.viajesActivos}',
                            subtitle: '${data.viajesProgramados} Programados',
                            icon: Icons.directions_bus,
                            onTap:
                                () => context.go(
                                  '${RoutesAgencia.viajes}?filter=en_curso',
                                ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: KPICard(
                            title: 'EN RUTA',
                            value: '${data.turistasEnCampo}',
                            subtitle: '${data.turistasSinRed} Sin Red',
                            icon: Icons.hiking,
                            onTap:
                                () => context.go(
                                  '${RoutesAgencia.usuarios}?tab=clientes',
                                ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: KPICard(
                            title: 'ALERTAS',
                            value: '${data.alertasCriticas}'.padLeft(2, '0'),
                            subtitle: 'Críticas',
                            icon: Icons.warning_amber_rounded,
                            isAlert: data.alertasCriticas > 0,
                            onTap:
                                () => context.go(
                                  '${RoutesAgencia.auditoria}?nivel=critico',
                                ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: KPICard(
                            title: 'GUÍAS',
                            value: '${data.guiasTotal}',
                            subtitle: '${data.guiasOffline} Offline',
                            icon: Icons.map,
                            onTap:
                                () => context.go(
                                  '${RoutesAgencia.usuarios}?tab=guias',
                                ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // --- 2. SECCIÓN CENTRAL (Mapa y Alertas) ---
                    SizedBox(
                      height: 500, // Fixed height for map/sidebar area
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // MAPA INTERACTIVO
                          Expanded(
                            flex: 2,
                            child: AgencyMapWidget(
                              viajes: data.viajesEnMapa,
                              alertas: data.alertasRecientes,
                            ),
                          ),

                          const SizedBox(width: 24),

                          // PANEL DE INCIDENTES
                          Expanded(
                            flex: 1,
                            child: IncidentPanel(
                              incidentes: data.alertasRecientes,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              } else if (state is DashboardError) {
                return Center(child: Text(state.message));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
