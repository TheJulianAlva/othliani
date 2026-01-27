import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/mock/mock_database.dart';
import '../widgets/kpi_card.dart';
import '../widgets/agency_map_widget.dart';
import '../widgets/incident_panel.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final MockDatabase _mockDB = MockDatabase();

  late Map<String, dynamic> stats;
  late List<dynamic> incidentesRecientes;

  @override
  void initState() {
    super.initState();
    _cargarDatosSimulados();
  }

  void _cargarDatosSimulados() {
    setState(() {
      stats = _mockDB.getDashboardStats();
      incidentesRecientes = _mockDB.alertas;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

            // Row 2: KPI Cards (Using Mock Data)
            Row(
              children: [
                Expanded(
                  child: KPICard(
                    title: 'Viajes',
                    icon: Icons.directions_bus,
                    value: '${stats['viajes']}',
                    subtitle: '5 Programados',
                    onTap: () => context.go('/viajes?status=active'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: KPICard(
                    title: 'Turistas',
                    icon: Icons.groups,
                    value: '${stats['turistas']}',
                    subtitle: '3 Sin Red',
                    onTap: () => context.go('/usuarios?tab=clients'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: KPICard(
                    title: 'Alertas',
                    icon: Icons.warning,
                    value: '${stats['alertas']}'.padLeft(2, '0'),
                    subtitle: 'Críticas',
                    isAlert: stats['alertas'] > 0,
                    onTap: () => context.go('/auditoria?filter=critical'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: KPICard(
                    title: 'Guías',
                    icon: Icons.support_agent,
                    value: '${stats['guias']}',
                    subtitle: '2 Offline',
                    onTap:
                        () => context.go('/usuarios?tab=guides&status=offline'),
                  ),
                ),
              ],
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
                  ), // Could pass _mockDB.viajes here

                  const SizedBox(width: 24),

                  // Incident Panel (30%)
                  Expanded(
                    flex: 3,
                    child: IncidentPanel(incidentes: _mockDB.alertas),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
