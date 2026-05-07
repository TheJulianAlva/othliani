import 'package:flutter/material.dart';
import '../../domain/entities/viaje.dart';

class QuickDetailCard extends StatelessWidget {
  final Viaje viaje;
  final VoidCallback onAbrirPantallaCompleta;

  const QuickDetailCard({
    super.key,
    required this.viaje,
    required this.onAbrirPantallaCompleta,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Image with Title
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: const Color(0xFF1B3B6F), // Fallback color
              image: DecorationImage(
                image: NetworkImage(
                  "https://picsum.photos/seed/${viaje.id}/400/200", // Dummy image based on ID
                ),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.4),
                  BlendMode.darken,
                ),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          viaje.estado.replaceAll('_', ' '),
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.edit, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      const Icon(Icons.more_vert, color: Colors.white, size: 16),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      viaje.destino,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Folio: V-${viaje.id}",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Resumen content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Resumen de Actividad",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.map_outlined, size: 14),
                        label: const Text("Ver Itinerario", style: TextStyle(fontSize: 12)),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Alert Box (Dummy si hay alertas)
                  if (viaje.alertasActivas > 0)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border(left: BorderSide(color: Colors.red.shade400, width: 4)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.warning, size: 16, color: Colors.red.shade700),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Retraso por incidencia",
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade900, fontSize: 13),
                                  ),
                                ],
                              ),
                              Text("Hace 1 h", style: TextStyle(color: Colors.red.shade400, fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Notificado en bitácora de viaje. Continuamos ruta con retraso estimado.",
                            style: TextStyle(color: Colors.red.shade700, fontSize: 12, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  
                  // Timeline Box
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue.shade100),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          // Actividad actual
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.location_on, color: Colors.blue.shade600, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Llegada a destino actual",
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        Text(
                                          "En curso",
                                          style: TextStyle(color: Colors.blue.shade600, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Estimado de llegada: 09:30 AM",
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                    ),
                                    const SizedBox(height: 8),
                                    LinearProgressIndicator(
                                      value: 0.75,
                                      backgroundColor: Colors.blue.shade50,
                                      color: Colors.blue.shade600,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(height: 1),
                          const SizedBox(height: 16),
                          // Actividad previa
                          Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.grey, size: 20),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  "Check-in Completado",
                                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.black87),
                                ),
                              ),
                              Text(
                                "06:15 AM",
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.chat_bubble_outline, size: 16),
                    label: const Text("Chat Guía"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onAbrirPantallaCompleta,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF004A75),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Abrir Pantalla Completa"),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
