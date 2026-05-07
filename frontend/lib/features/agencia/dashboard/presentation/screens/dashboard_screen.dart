import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/navigation/routes_agencia.dart';
import 'package:frontend/core/di/service_locator.dart' as di;
import '../widgets/kpi_card.dart';
import '../widgets/incident_panel.dart';
import '../widgets/agency_map_widget.dart';
import 'package:frontend/features/agencia/dashboard/presentation/blocs/dashboard/dashboard_bloc.dart';

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
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF004A75), // Azul oscuro exacto del mockup
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Visión global de las operaciones en tiempo real.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600, // Gris claro del mockup
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- 1. TARJETAS KPI (Con Navegación) ---
                    Row(
                      children: [
                        Expanded(
                          child: KPICard(
                            title: 'VIAJES EN ACTIVIDAD',
                            value: '${data.viajesActivos}',
                            subtitle: 'Visitando sitio',
                            icon: Icons.calendar_today_rounded,
                            customIconColor: const Color(0xFF1B3B6F),
                            customIconBgColor: const Color(0xFFE8EEFF),
                            onTap: () => context.go('${RoutesAgencia.viajes}?filter=en_curso'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: KPICard(
                            title: 'VIAJES EN RUTA',
                            value: '${data.viajesActivos}', // Using viajesActivos for now
                            subtitle: 'En traslado',
                            icon: Icons.directions_bus_rounded,
                            customIconColor: const Color(0xFF6A1B9A),
                            customIconBgColor: const Color(0xFFF3E5F5),
                            onTap: () => context.go('${RoutesAgencia.viajes}?filter=en_curso'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: KPICard(
                            title: 'TURISTAS EN VIAJE',
                            value: '${data.turistasEnCampo}',
                            subtitle: 'Pasajeros a bordo',
                            icon: Icons.hiking_rounded,
                            customIconColor: const Color(0xFF2E7D32),
                            customIconBgColor: const Color(0xFFE8F5E9),
                            isAlert: false, // The mockup shows this as a normal green card
                            onTap: () => context.go('${RoutesAgencia.usuarios}?tab=clientes'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: KPICard(
                            title: 'GUÍAS',
                            value: '${data.guiasTotal}', // Maybe this should be '10 / 14' but keeping dynamic
                            subtitle: 'Ocupados / Disp.',
                            icon: Icons.badge_rounded,
                            customIconColor: const Color(0xFFE65100),
                            customIconBgColor: const Color(0xFFFFF3E0),
                            onTap: () => context.go('${RoutesAgencia.usuarios}?tab=guias'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // --- 2. SECCIÓN CENTRAL (Mapa y Alertas) ---
                    SizedBox(
                      height: 550, // Expanded height for map
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // MAPA INTERACTIVO
                          Expanded(
                            flex: 7,
                            child: AgencyMapWidget(
                              viajes: data.viajesEnMapa,
                              alertas: data.alertasRecientes,
                            ),
                          ),

                          const SizedBox(width: 24),

                          // PANEL DE TRIAGE / ESTADO DE OPERACIONES
                          Expanded(
                            flex: 3,
                            child: IncidentPanel(
                              viajes: data.viajesEnMapa,
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
