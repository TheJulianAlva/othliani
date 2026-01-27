import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/kpi_card.dart';
import '../widgets/agency_map_widget.dart';
import '../widgets/incident_panel.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Row 1: Header / Title with Date Filter (Mock)
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

            // Row 2: KPI Cards
            Row(
              children: [
                KPICard(
                  title: 'Viajes',
                  icon: Icons.directions_bus,
                  value: '12',
                  subtitle: '5 Programados',
                  onTap: () => context.go('/viajes?status=active'),
                ),
                KPICard(
                  title: 'Turistas',
                  icon: Icons.groups,
                  value: '145',
                  subtitle: '3 Sin Red',
                  onTap: () => context.go('/usuarios?tab=clients'),
                ),
                KPICard(
                  title: 'Alertas',
                  icon: Icons.warning,
                  value: '02',
                  subtitle: 'Críticas',
                  isAlert: true,
                  onTap: () => context.go('/auditoria?filter=critical'),
                ),
                KPICard(
                  title: 'Guías',
                  icon: Icons.support_agent,
                  value: '10',
                  subtitle: '2 Offline',
                  onTap:
                      () => context.go('/usuarios?tab=guides&status=offline'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Row 3: Map & Incident Panel
            SizedBox(
              height: 500, // Fixed height for the main operational view
              child: Row(
                children: const [
                  // Map (70%)
                  Expanded(flex: 7, child: AgencyMapWidget()),

                  SizedBox(width: 24),

                  // Incident Panel (30%)
                  Expanded(flex: 3, child: IncidentPanel()),
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
