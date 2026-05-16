import 'package:flutter/material.dart';
import '../../domain/entities/guia.dart';

class GuideMasterList extends StatelessWidget {
  final List<Guia> guias;
  final String? selectedGuiaId;
  final Function(Guia) onGuiaSelected;

  const GuideMasterList({
    super.key,
    required this.guias,
    this.selectedGuiaId,
    required this.onGuiaSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header de la Tabla
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          color: Colors.grey.shade50,
          child: Row(
            children: const [
              Expanded(flex: 4, child: Text("STAFF", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
              Expanded(flex: 2, child: Text("ESTADO", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
              Expanded(flex: 2, child: Text("DÍAS TRABAJO (MES)", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
              Expanded(flex: 2, child: Text("CSAT", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
              Expanded(flex: 3, child: Text("PRÓX. VIAJE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
            ],
          ),
        ),
        const Divider(height: 1),
        // Lista de Guías
        Expanded(
          child: ListView.separated(
            itemCount: guias.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final guia = guias[index];
              final isSelected = guia.id == selectedGuiaId;

              return InkWell(
                onTap: () => onGuiaSelected(guia),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  color: isSelected ? Colors.blue.shade50.withValues(alpha: 0.5) : null,
                  child: Row(
                    children: [
                      // STAFF
                      Expanded(
                        flex: 4,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.blue.shade100,
                              child: Text(guia.nombre.substring(0, 2).toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF004A75))),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(guia.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis),
                                  Text("${guia.id} • ${guia.rol}", style: TextStyle(fontSize: 10, color: Colors.grey.shade600), overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ESTADO
                      Expanded(
                        flex: 2,
                        child: _buildStatusPill(guia.status),
                      ),
                      // DÍAS TRABAJO
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Text("${guia.diasTrabajoMes} Días", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            if (guia.diasTrabajoMes > 15) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 14),
                            ],
                          ],
                        ),
                      ),
                      // CSAT
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: List.generate(5, (i) => Icon(Icons.star, size: 12, color: i < guia.csat.floor() ? Colors.orange : Colors.grey.shade300)),
                            ),
                            Text("${guia.csat} (${guia.totalReviews} Rev)", style: TextStyle(fontSize: 9, color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                      // PRÓX. VIAJE
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(guia.proxViaje ?? "Sin asignar", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: guia.proxViaje == null ? Colors.grey : Colors.black87)),
                            if (guia.proxViaje != null) Text("15 Mar • 06:00 AM", style: TextStyle(fontSize: 9, color: Colors.grey.shade600)),
                          ],
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

  Widget _buildStatusPill(String status) {
    Color color;
    Color bgColor;
    String text;

    switch (status) {
      case 'DISPONIBLE':
        color = Colors.green.shade700;
        bgColor = Colors.green.shade50;
        text = "• Disponible";
        break;
      case 'EN_VIAJE':
        color = Colors.blue.shade700;
        bgColor = Colors.blue.shade50;
        text = "• En Viaje (V-102)";
        break;
      case 'DESCANSO':
      default:
        color = Colors.grey.shade600;
        bgColor = Colors.grey.shade100;
        text = "• Descanso";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
