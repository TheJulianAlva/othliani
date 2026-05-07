import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/viaje.dart';
import '../../../dashboard/presentation/widgets/agency_map_widget.dart'; // We can reuse the map

class FullDetailGrid extends StatelessWidget {
  final Viaje viaje;

  const FullDetailGrid({super.key, required this.viaje});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF4F6F8),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header (Back button, Title, Edit Button)
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  // This just scrolls back up via controller in parent, handled visually for now
                },
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "V-${viaje.id} • ${viaje.estado.replaceAll('_', ' ')}",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      viaje.destino,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF004A75)),
                    ),
                    Text(
                      "Inicio: 08 Mar ${viaje.horaInicio} • Regreso Est: 10 Mar 19:00 PM",
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                icon: const Icon(Icons.edit, size: 16),
                label: const Text("Editar Operación"),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1B3B6F),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                onPressed: () {},
              )
            ],
          ),
          const SizedBox(height: 24),

          // GRID LAYOUT
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // COLUMNA IZQUIERDA (Flex 7)
              Expanded(
                flex: 7,
                child: Column(
                  children: [
                    // MAPA
                    Container(
                      height: 400,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            // ClipRRect added to prevent map overflow
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: AgencyMapWidget(viajes: [viaje], alertas: const []), // Shows only this trip
                            ),
                          ),
                          Positioned(
                            top: 16,
                            left: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                              ),
                              child: const Text("Rastreo GPS (Guía Principal)", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Row(
                              children: [
                                const CircleAvatar(radius: 4, backgroundColor: Colors.green),
                                const SizedBox(width: 4),
                                Text("En vivo", style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 16,
                            left: 16,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("PUNTO DE CONTROL ACTUAL", style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  const Text("Faldas del Nevado", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 2),
                                  const Text("Llegada a tiempo", style: TextStyle(fontSize: 12, color: Colors.green)),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // ROW INFERIOR IZQUIERDA (Alertas + Itinerario)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ALERTAS ACTIVAS
                        Expanded(
                          flex: 4,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.shade100),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.warning, color: Colors.red.shade700, size: 18),
                                    const SizedBox(width: 8),
                                    Text("Alertas Activas", style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold, fontSize: 16)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                if (viaje.alertasActivas > 0)
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border(left: BorderSide(color: Colors.red.shade500, width: 4)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("INCIDENTE", style: TextStyle(color: Colors.red.shade500, fontSize: 10, fontWeight: FontWeight.bold)),
                                            Text("08:00 AM", style: TextStyle(color: Colors.red.shade500, fontSize: 10)),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text("Retraso por incidencia", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade900)),
                                        const SizedBox(height: 2),
                                        Text("Turista afectado: No identificado", style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                                        const SizedBox(height: 8),
                                        Text("\"Notificación general de retraso.\"", style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey.shade600)),
                                      ],
                                    ),
                                  )
                                else
                                  const Text("No hay alertas activas en este momento."),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // ITINERARIO
                        Expanded(
                          flex: 6,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(Icons.timeline, color: Colors.blue.shade700, size: 18),
                                          const SizedBox(width: 8),
                                          const Expanded(
                                            child: Text("Avance de Itinerario", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis),
                                          ),
                                        ],
                                      ),
                                    ),
                                    TextButton.icon(
                                      icon: const Icon(Icons.open_in_new, size: 14),
                                      label: const Text("ITINERARIO COMPLETO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                      onPressed: () {
                                        context.go('/viajes/${viaje.id}/itinerary-operative', extra: viaje);
                                      },
                                    ),
                                  ],
                                ),
                                const Divider(),
                                const SizedBox(height: 8),
                                Center(child: Text("DÍA 1: 08 MAR", style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.bold))),
                                const SizedBox(height: 12),
                                // Contenedor con scroll interno para el itinerario
                                SizedBox(
                                  height: 200, // Fixed height with internal scrolling
                                  child: ListView(
                                    padding: EdgeInsets.zero,
                                    children: [
                                      _buildItineraryItem(
                                        icon: Icons.check_circle,
                                        iconColor: Colors.green,
                                        title: "Check-in Monumento Revolución",
                                        subtitle: "24/25 Personas a bordo",
                                        time: "06:15 AM",
                                        titleColor: Colors.black87,
                                      ),
                                      const SizedBox(height: 16),
                                      _buildItineraryItem(
                                        icon: Icons.location_on,
                                        iconColor: Colors.blue,
                                        title: "Llegada a las faldas del Nevado",
                                        subtitle: "Aprox. a 15km de distancia.",
                                        time: "EST. 09:30 AM",
                                        titleColor: Colors.blue,
                                        timeColor: Colors.blue.shade700,
                                      ),
                                      const SizedBox(height: 16),
                                      _buildItineraryItem(
                                        icon: Icons.access_time,
                                        iconColor: Colors.grey,
                                        title: "Inicio de ascenso",
                                        subtitle: "Punto de reunión: Base del Nevado",
                                        time: "10:00 AM",
                                        titleColor: Colors.grey.shade700,
                                      ),
                                      const SizedBox(height: 16),
                                      _buildItineraryItem(
                                        icon: Icons.access_time,
                                        iconColor: Colors.grey,
                                        title: "Comida grupal",
                                        subtitle: "Restaurante local",
                                        time: "14:00 PM",
                                        titleColor: Colors.grey.shade700,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 24),
              
              // COLUMNA DERECHA (Flex 3)
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    // INFO OPERATIVA
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.grey.shade600, size: 18),
                              const SizedBox(width: 8),
                              const Text("Información Operativa", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("INICIO", style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 2),
                                    const Text("08 Mar • 06:00 AM", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("REGRESO", style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 2),
                                    const Text("10 Mar • 19:00 PM", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          Text("LOGÍSTICA DE TRANSPORTE", style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade100),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                                  child: Icon(Icons.directions_bus, color: Colors.blue.shade700, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(viaje.transporteLogistica, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      Text("Operador: ${viaje.operadorNombre == 'Operador' ? 'Manuel Gómez' : viaje.operadorNombre}", style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
                                  child: Text(viaje.placasVehiculo, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // STAFF
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.badge_outlined, color: Colors.blue.shade700, size: 18),
                              const SizedBox(width: 8),
                              const Text("Staff a Bordo (2)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildStaffItem("CR", viaje.guiaNombre, "LÍDER", "Bat: 85% • Cobertura: Alta"),
                          const Divider(height: 24),
                          _buildStaffItem("AM", "Ana M.", "AUX", "Bat: 92% • Cobertura: Alta"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // LISTA PAX
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.group_outlined, color: Colors.green.shade700, size: 18),
                                  const SizedBox(width: 8),
                                  const Text("Lista PAX", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                              Row(
                                children: [
                                  Text("${viaje.paxOk} Ok", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                                  const SizedBox(width: 8),
                                  const Text("|", style: TextStyle(color: Colors.grey)),
                                  const SizedBox(width: 8),
                                  Text("${viaje.paxBaja} Baja", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            decoration: InputDecoration(
                              hintText: "Buscar turista...",
                              hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                              prefixIcon: const Icon(Icons.search, size: 16),
                              isDense: true,
                              contentPadding: const EdgeInsets.all(8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Lista de pasajeros con scroll interno
                          SizedBox(
                            height: 250,
                            child: ListView.separated(
                              padding: EdgeInsets.zero,
                              itemCount: 10, // Dummy data count
                              separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200, height: 1),
                              itemBuilder: (context, index) {
                                final isBaja = index == 3; // Simular 1 baja
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    radius: 14,
                                    backgroundColor: isBaja ? Colors.red.shade50 : Colors.grey.shade100,
                                    child: Icon(Icons.person, size: 16, color: isBaja ? Colors.red : Colors.grey.shade600),
                                  ),
                                  title: Text(
                                    "Pasajero ${index + 1}",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isBaja ? Colors.grey.shade500 : Colors.black87,
                                      decoration: isBaja ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                  trailing: isBaja 
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(4)),
                                        child: const Text("BAJA", style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
                                      )
                                    : const Icon(Icons.check_circle, color: Colors.green, size: 16),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStaffItem(String initials, String name, String role, String statusText) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.blue.shade50,
          child: Text(initials, style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                    child: Text(role, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                  )
                ],
              ),
              Row(
                children: [
                  const CircleAvatar(radius: 3, backgroundColor: Colors.green),
                  const SizedBox(width: 4),
                  Text(statusText, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.grey),
          onPressed: () {},
        )
      ],
    );
  }

  Widget _buildItineraryItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
    required Color titleColor,
    Color? timeColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: titleColor)),
              Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
            ],
          ),
        ),
        Text(time, style: TextStyle(color: timeColor ?? Colors.grey.shade500, fontSize: 11, fontWeight: timeColor != null ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}
