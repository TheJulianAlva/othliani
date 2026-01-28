import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/mock/mock_models.dart';
// import 'voice_call_dialog.dart'; // Mantener si se usará

class IncidentPanel extends StatelessWidget {
  final List<MockAlerta>? incidentes;
  final Function(MockAlerta) onIncidentTap;

  const IncidentPanel({
    super.key,
    this.incidentes,
    required this.onIncidentTap,
  });

  @override
  Widget build(BuildContext context) {
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
          Expanded(
            child:
                alerts.isEmpty
                    ? const Center(child: Text("No hay incidentes recientes"))
                    : ListView.builder(
                      padding: const EdgeInsets.all(0),
                      itemCount: alerts.length,
                      itemBuilder: (context, index) {
                        return _buildIncidentItem(context, alerts[index]);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentItem(BuildContext context, MockAlerta alerta) {
    final severity = _mapSeverity(alerta.tipo);
    final color = _getColor(severity);
    final timeStr = DateFormat('hh:mm a').format(alerta.hora);

    return InkWell(
      onTap: () => onIncidentTap(alerta),
      hoverColor: color.withValues(alpha: 0.05),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: color),
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
                        alerta.mensaje, // Using new message field
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
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
