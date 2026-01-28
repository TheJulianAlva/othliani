import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/mock/mock_models.dart';
import 'package:intl/intl.dart';
import 'voice_call_dialog.dart';

class IncidentPanel extends StatelessWidget {
  final List<MockAlerta>? incidentes;

  const IncidentPanel({super.key, this.incidentes});

  @override
  Widget build(BuildContext context) {
    // If no incidents provided, show empty state or default list
    final alerts = incidentes ?? [];

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
            child:
                alerts.isEmpty
                    ? const Center(child: Text("No hay incidentes recientes"))
                    : ListView.builder(
                      padding: const EdgeInsets.all(0),
                      itemCount: alerts.length,
                      itemBuilder: (context, index) {
                        final alerta = alerts[index];
                        return _buildIncidentItem(
                          context: context,
                          alerta: alerta,
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentItem({
    required BuildContext context,
    required MockAlerta alerta,
  }) {
    final severity = _mapSeverity(alerta.tipo);
    final color = _getColor(severity);
    final timeStr = DateFormat('hh:mm a').format(alerta.hora);

    return InkWell(
      onTap:
          () => context.go(
            '/viajes/${alerta.idViaje}/detalle?focus_user=${Uri.encodeComponent(alerta.nombreTurista)}',
          ),
      hoverColor: color.withValues(alpha: 0.05),
      child: Container(
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
                          if (alerta.esCritica)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Icon(
                                Icons.warning,
                                size: 14,
                                color: color,
                              ),
                            ),
                          Text(
                            timeStr,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '${alerta.tipo.name} - Viaje #${alerta.idViaje}',
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
                        'Turista: ${alerta.nombreTurista}.',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),

                      if (alerta.esCritica) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder:
                                      (ctx) => VoiceCallDialog(
                                        contactName:
                                            'Guía del Viaje #${alerta.idViaje}',
                                        role: 'Guía Certificado',
                                      ),
                                );
                              },
                              child: Text(
                                'Llamar Guía',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap:
                                  () => context.go(
                                    '/viajes/${alerta.idViaje}/detalle',
                                  ),
                              child: Text(
                                'Ver Ubicación',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IncidentSeverity _mapSeverity(TipoAlerta tipo) {
    switch (tipo) {
      case TipoAlerta.PANICO:
        return IncidentSeverity.critical;
      case TipoAlerta.DESCONEXION:
        return IncidentSeverity.warning;
      case TipoAlerta.LEJANIA:
        return IncidentSeverity.warning;
    }
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
