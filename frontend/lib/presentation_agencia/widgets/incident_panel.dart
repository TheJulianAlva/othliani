import 'package:flutter/material.dart';

class IncidentPanel extends StatelessWidget {
  const IncidentPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Flexible(
                  child: Text(
                    'PANEL DE INCIDENTES',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.filter_list, size: 18, color: Colors.grey),
              ],
            ),
          ),

          // List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(0),
              children: [
                _buildIncidentItem(
                  severity: IncidentSeverity.critical,
                  time: '10:42 AM',
                  title: 'PÁNICO - Viaje #204',
                  description: 'Turista: Ana G. activó SOS.',
                  actions: ['Ver Ubicación', 'Llamar Guía'],
                ),
                _buildIncidentItem(
                  severity: IncidentSeverity.warning,
                  time: '10:35 AM',
                  title: 'ALEJAMIENTO - Viaje #110',
                  description: 'Turista: Luis P. fuera de rango (50m).',
                  actions: ['Ver Detalle'],
                ),
                _buildIncidentItem(
                  severity: IncidentSeverity.info,
                  time: '09:00 AM',
                  title: 'SISTEMA',
                  description: 'Sincronización completada (Offline data).',
                  actions: [],
                ),
                _buildIncidentItem(
                  severity: IncidentSeverity.info,
                  time: '08:45 AM',
                  title: 'INICIO DE GUARDIA',
                  description: 'Supervisor Julián inició sesión.',
                  actions: [],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentItem({
    required IncidentSeverity severity,
    required String time,
    required String title,
    required String description,
    required List<String> actions,
  }) {
    final color = _getColor(severity);

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Severity Indicator
            Container(width: 4, color: color),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (severity == IncidentSeverity.critical)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Icon(Icons.warning, size: 14, color: color),
                          ),
                        Text(
                          time,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),

                    if (actions.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children:
                            actions.map((action) {
                              return InkWell(
                                onTap: () {},
                                child: Text(
                                  action,
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor(IncidentSeverity severity) {
    switch (severity) {
      case IncidentSeverity.critical:
        return Colors.red;
      case IncidentSeverity.warning:
        return Colors.amber.shade700;
      case IncidentSeverity.info:
        return Colors.blue;
    }
  }
}

enum IncidentSeverity { critical, warning, info }
