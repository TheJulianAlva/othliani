import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/alerta.dart';

class IncidentPanel extends StatefulWidget {
  final List<Alerta>? incidentes;

  const IncidentPanel({super.key, this.incidentes});

  @override
  State<IncidentPanel> createState() => _IncidentPanelState();
}

class _IncidentPanelState extends State<IncidentPanel> {
  // Estado de Filtros (Por defecto 'Críticos' y 'Advertencia' activos)
  bool _showCritico = true;
  bool _showAdvertencia = true;
  bool _showInfo = false; // Info oculto para limpiar ruido

  @override
  Widget build(BuildContext context) {
    final alerts = widget.incidentes ?? [];

    // 1. Lógica de Filtrado
    final filteredList =
        alerts.where((incidente) {
          final severity = _mapSeverity(incidente.tipo);
          if (severity == IncidentSeverity.critical && _showCritico) {
            return true;
          }
          if (severity == IncidentSeverity.warning && _showAdvertencia) {
            return true;
          }
          if (severity == IncidentSeverity.info && _showInfo) return true;
          return false;
        }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CABECERA CON FILTROS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Últimos Incidentes",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              // Botón "Ver Todo" que lleva a la bitácora completa
              IconButton(
                icon: const Icon(
                  Icons.open_in_new,
                  size: 18,
                  color: Colors.grey,
                ),
                tooltip: "Ir a Auditoría Completa",
                onPressed: () => context.go('/auditoria'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // BARRA DE CHIPS (IGUAL QUE EL MAPA)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  'Críticos',
                  Colors.red,
                  _showCritico,
                  (v) => setState(() => _showCritico = v),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Alertas',
                  Colors.amber.shade800,
                  _showAdvertencia,
                  (v) => setState(() => _showAdvertencia = v),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Info',
                  Colors.blue,
                  _showInfo,
                  (v) => setState(() => _showInfo = v),
                ),
              ],
            ),
          ),
          const Divider(height: 24),

          // LISTA FILTRADA
          Expanded(
            child:
                filteredList.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 40,
                            color: Colors.green.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Sin incidentes visibles",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                    : ListView.separated(
                      itemCount: filteredList.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        final severity = _mapSeverity(item.tipo);
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getColor(severity).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getIcon(severity),
                              color: _getColor(severity),
                              size: 18,
                            ),
                          ),
                          title: Text(
                            item.mensaje,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            "${DateFormat('HH:mm').format(item.hora)} • Viaje #${item.viajeId}",
                            style: const TextStyle(fontSize: 11),
                          ),
                          onTap: () {
                            // Navegación inteligente al contexto
                            context.push(
                              '/viajes/${item.viajeId}?alert_focus=${item.id}',
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  // Helpers de Estilo
  Color _getColor(IncidentSeverity s) {
    switch (s) {
      case IncidentSeverity.critical:
        return Colors.red;
      case IncidentSeverity.warning:
        return Colors.amber.shade800;
      case IncidentSeverity.info:
        return Colors.blue;
    }
  }

  IconData _getIcon(IncidentSeverity s) {
    switch (s) {
      case IncidentSeverity.critical:
        return Icons.report_problem;
      case IncidentSeverity.warning:
        return Icons.warning_amber;
      case IncidentSeverity.info:
        return Icons.info_outline;
    }
  }

  IncidentSeverity _mapSeverity(String tipo) {
    switch (tipo) {
      case 'PANICO':
      case 'CONECTIVIDAD': // Pérdida de conexión es crítica
        return IncidentSeverity.critical;
      case 'DESCONEXION':
      case 'LEJANIA':
      case 'BATERIA': // Batería baja es advertencia
        return IncidentSeverity.warning;
      default:
        return IncidentSeverity.info;
    }
  }

  Widget _buildFilterChip(
    String label,
    Color color,
    bool isSelected,
    Function(bool) onChanged,
  ) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : color,
          fontSize: 11,
        ),
      ),
      selected: isSelected,
      onSelected: onChanged,
      backgroundColor: Colors.white,
      selectedColor: color,
      checkmarkColor: Colors.white,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.transparent : color.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

enum IncidentSeverity { critical, warning, info }
