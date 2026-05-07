import 'package:flutter/material.dart';
import '../../domain/entities/viaje.dart';

class MasterTripList extends StatelessWidget {
  final List<Viaje> viajes;
  final String? selectedViajeId;
  final Function(Viaje) onViajeSelected;

  const MasterTripList({
    super.key,
    required this.viajes,
    required this.selectedViajeId,
    required this.onViajeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Table Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  "DESTINO Y HORARIO",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "STAFF PRINCIPAL",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(
                    "ESTADO",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: Colors.grey.shade300),
        // List of trips
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: viajes.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
            itemBuilder: (context, index) {
              final viaje = viajes[index];
              final isSelected = viaje.id == selectedViajeId;

              return InkWell(
                onTap: () => onViajeSelected(viaje),
                child: Container(
                  color: isSelected ? Colors.blue.shade50 : Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      // Destino y Horario
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    viaje.destino,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: isSelected ? Colors.blue.shade900 : const Color(0xFF2C3E50),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (viaje.alertasActivas > 0) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      "-20m retraso", // dummy
                                      style: TextStyle(fontSize: 10, color: Colors.orange.shade900, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "08 Mar ${viaje.horaInicio} - 18:30 PM", // Dummy date format for now
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      // Staff Principal
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.grey.shade200,
                              child: Text(
                                viaje.guiaNombre.isNotEmpty ? viaje.guiaNombre.substring(0, 2).toUpperCase() : '?',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                viaje.guiaNombre,
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Estado
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: _buildStateBadge(viaje.estado, viaje.alertasActivas > 0),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStateBadge(String estado, bool hasAlerts) {
    Color bgColor;
    Color textColor;
    String label = estado;

    if (hasAlerts) {
      bgColor = Colors.red.shade50;
      textColor = Colors.red.shade700;
      label = "CON ALERTAS";
    } else if (estado == 'EN_CURSO') {
      bgColor = Colors.green.shade50;
      textColor = Colors.green.shade700;
      label = "EN ACTIVIDAD"; // O "EN RUTA" según diseño
    } else if (estado == 'PROGRAMADO') {
      bgColor = Colors.blue.shade50;
      textColor = Colors.blue.shade700;
      label = "EN RUTA";
    } else {
      bgColor = Colors.grey.shade100;
      textColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor),
        textAlign: TextAlign.center,
      ),
    );
  }
}
