import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/viaje.dart';

class ItineraryOperativeScreen extends StatelessWidget {
  final Viaje viaje;

  const ItineraryOperativeScreen({super.key, required this.viaje});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            context.go('/viajes');
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Itinerario Operativo: V-${viaje.id} ${viaje.destino}", style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
            Text("Vista Administrativa (Proveedores y Logística)", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
        actions: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
              child: Text("EN CURSO", style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 10)),
            ),
          ),
          const SizedBox(width: 16),
          Center(
            child: FilledButton.icon(
              icon: const Icon(Icons.edit_document, size: 16),
              label: const Text("Modificar Logística"),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1B2B3C),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Column: Timeline
            Expanded(
              flex: 6,
              child: _buildTimelineSection(),
            ),
            const SizedBox(width: 24),
            // Right Column: Logistics and Providers
            Expanded(
              flex: 4,
              child: _buildLogisticsSection(viaje),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.route_outlined, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                const Text("Control de Paradas y Check-ins", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          const Divider(height: 1),
          // Timeline Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildDayDivider("DÍA 1: 08 DE MARZO"),
                const SizedBox(height: 24),
                
                _buildTimelineEvent(
                  icon: Icons.people,
                  iconColor: Colors.grey.shade400,
                  iconBg: Colors.grey.shade100,
                  title: "Cita y Pase de Lista (Monumento Rev.)",
                  subtitle: "Check-in inicial. Coordinador: Ana M.",
                  statusText: "COMPLETADO 06:15 AM",
                  progText: "Prog: 06:00 AM",
                  isCompleted: true,
                ),
                const SizedBox(height: 24),

                _buildTimelineEvent(
                  icon: Icons.restaurant,
                  iconColor: Colors.green,
                  iconBg: Colors.green.shade50,
                  title: "Parada Desayuno (Tres Marías)",
                  subtitle: "Proveedor: Restaurante El Paraíso.",
                  badgeText: "PAGO EN SITIO",
                  badgeColor: Colors.orange.shade700,
                  badgeBg: Colors.orange.shade50,
                  statusText: "EN ESTE SITIO 08:30 AM",
                  progText: "Prog: 08:30 AM",
                  isCurrent: true,
                  customContent: Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.green.shade700, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "El guía completó el pago de \$2,400 MXN en efectivo a nombre de la agencia.",
                            style: TextStyle(color: Colors.green.shade900, fontSize: 11),
                          ),
                        )
                      ],
                    ),
                  )
                ),
                const SizedBox(height: 24),

                _buildTimelineEvent(
                  icon: Icons.landscape,
                  iconColor: Colors.grey.shade400,
                  iconBg: Colors.white,
                  borderColor: Colors.grey.shade300,
                  title: "Ingreso al Parque Nacional",
                  subtitle: "Registro de brazaletes de acceso CONANP.",
                  badgeText: "PRE-PAGADO",
                  badgeColor: Colors.blue.shade700,
                  badgeBg: Colors.blue.shade50,
                  statusText: "PENDIENTE",
                  progText: "Prog: 10:30 AM",
                ),
                
                const SizedBox(height: 32),
                _buildDayDivider("DÍA 2: 09 DE MARZO"),
                const SizedBox(height: 24),

                _buildTimelineEvent(
                  icon: Icons.hotel,
                  iconColor: Colors.grey.shade400,
                  iconBg: Colors.white,
                  borderColor: Colors.grey.shade300,
                  title: "Check-out Hotel Real del Nevado",
                  subtitle: "Entrega de llaves.",
                  badgeText: "PRE-PAGADO",
                  badgeColor: Colors.blue.shade700,
                  badgeBg: Colors.blue.shade50,
                  statusText: "PROGRAMADO",
                  progText: "Prog: 10:00 AM",
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDayDivider(String day) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(day, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87)),
    );
  }

  Widget _buildTimelineEvent({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    Color? borderColor,
    required String title,
    required String subtitle,
    String? badgeText,
    Color? badgeColor,
    Color? badgeBg,
    required String statusText,
    required String progText,
    bool isCompleted = false,
    bool isCurrent = false,
    Widget? customContent,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline node
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                  border: borderColor != null ? Border.all(color: borderColor) : null,
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: isCompleted || isCurrent ? Colors.grey.shade300 : Colors.grey.shade200,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                ),
              )
            ],
          ),
          const SizedBox(width: 16),
          // Event content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isCurrent ? Colors.green.shade200 : Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                                if (badgeText != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(4)),
                                    child: Text(badgeText, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: badgeColor)),
                                  )
                                ]
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(statusText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isCurrent ? Colors.green.shade700 : (isCompleted ? Colors.grey.shade600 : Colors.grey.shade800))),
                          const SizedBox(height: 2),
                          Text(progText, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                        ],
                      )
                    ],
                  ),
                  if (customContent != null) customContent,
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLogisticsSection(Viaje viaje) {
    return Column(
      children: [
        // Operación de Transporte (Dark Card)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1B2B3C), // Dark navy
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.directions_bus, color: Colors.blue.shade300, size: 18),
                  const SizedBox(width: 8),
                  const Text("Operación de Transporte", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("UNIDAD ASIGNADA", style: TextStyle(color: Colors.grey.shade400, fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(viaje.transporteLogistica, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                        Text("Placas: ${viaje.placasVehiculo}", style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("COSTO OPERATIVO", style: TextStyle(color: Colors.grey.shade400, fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text("\$4,500.00 MXN", style: TextStyle(color: Colors.greenAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                        Text("Status: LIQUIDADO", style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.blueGrey.shade700,
                      child: const Text("MG", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${viaje.operadorNombre == 'Operador' ? 'Manuel Gómez' : viaje.operadorNombre} (Conductor titular)", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          Text("Tel: 55 1234 5678", style: TextStyle(color: Colors.grey.shade400, fontSize: 10)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.phone, color: Colors.white, size: 18),
                      onPressed: () {},
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Proveedores Relacionados
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
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
                    Icon(Icons.storefront, color: Colors.orange.shade700, size: 18),
                    const SizedBox(width: 8),
                    const Text("Proveedores Relacionados (2)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildProviderItem(
                        name: "Restaurante El Paraíso",
                        service: "Servicio de desayuno buffet para 25 personas.",
                        status: "PAGADO",
                        statusColor: Colors.green,
                        statusBg: Colors.green.shade50,
                        contact: "Contacto: Sra. Rosa (Gerente)",
                        actionText: "Enviar WhatsApp",
                      ),
                      const Divider(height: 32),
                      _buildProviderItem(
                        name: "Parque Nevado de Toluca",
                        service: "Accesos CONANP (Brazaletes diarios). Pagar ejidatarios en sitio.",
                        status: "PRE-PAGADO",
                        statusColor: Colors.blue.shade700,
                        statusBg: Colors.blue.shade50,
                        note: "Nota Gasto: \$50 MXN (x25) = \$1,250 a ejidatarios. Efectivo entregado al guía.",
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildProviderItem({
    required String name,
    required String service,
    required String status,
    required Color statusColor,
    required Color statusBg,
    String? contact,
    String? actionText,
    String? note,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(4)),
              child: Text(status, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: statusColor)),
            )
          ],
        ),
        const SizedBox(height: 4),
        Text(service, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
        const SizedBox(height: 12),
        if (contact != null || actionText != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (contact != null) Text(contact, style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
              if (actionText != null)
                InkWell(
                  onTap: () {},
                  child: Row(
                    children: [
                      Icon(Icons.message, size: 14, color: Colors.blue.shade700),
                      const SizedBox(width: 4),
                      Text(actionText, style: TextStyle(fontSize: 11, color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
            ],
          ),
        if (note != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(4)),
            child: Text(note, style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
          )
      ],
    );
  }
}
