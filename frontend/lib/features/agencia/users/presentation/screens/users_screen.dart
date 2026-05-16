import 'package:flutter/material.dart';
import '../../domain/entities/guia.dart';
import '../widgets/guide_master_list.dart';
import '../widgets/guide_quick_detail.dart';
import '../widgets/guide_full_profile.dart';

class UsersScreen extends StatefulWidget {
  final String initialTab;
  const UsersScreen({super.key, this.initialTab = 'guias'});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final ScrollController _scrollController = ScrollController();
  Guia? _selectedGuia;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    }
  }

  // Datos mock para el rediseño
  final List<Guia> _mockGuias = [
    const Guia(
      id: "GUA-084",
      nombre: "Carlos Rodríguez",
      status: "DISPONIBLE",
      rol: "Coordinador Senior",
      diasTrabajoMes: 12,
      csat: 4.8,
      totalReviews: 22,
      proxViaje: "Acapulco Fin Sem.",
      idiomas: ["Español (Nativo)", "Inglés (Avanzado)", "Francés (Básico)"],
      especialidades: ["Ecoturismo", "Alta Montaña", "Grupos > 40 pax"],
      pagadoMes: 12450.0,
      saldoPendiente: 3200.0,
    ),
    const Guia(
      id: "GUA-012",
      nombre: "Héctor Fuentes",
      status: "EN_VIAJE",
      rol: "Eco-Guía",
      diasTrabajoMes: 18,
      csat: 4.1,
      totalReviews: 14,
      proxViaje: "Terminando V-102",
    ),
    const Guia(
      id: "GUA-099",
      nombre: "Valeria T.",
      status: "DESCANSO",
      rol: "Trainee",
      diasTrabajoMes: 4,
      csat: 0.0,
      totalReviews: 0,
      proxViaje: "Xochimilco Oculto",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Autoseleccionar primero si no hay uno
    _selectedGuia ??= _mockGuias.first;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // PARTE SUPERIOR: DIRECTORIO (Imagen 2)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Directorio y Estado de Guías",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF004A75)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Consola de disponibilidad, rendimiento y cumplimiento.",
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1B3B6F),
                          elevation: 0,
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text("Configurar Metas", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Tarjetas de Estadísticas
                  _buildStatCards(),
                  const SizedBox(height: 24),
                  // Toolbar de búsqueda y filtros
                  _buildToolbar(),
                  const SizedBox(height: 16),
                  // Master-Detail Row
                  SizedBox(
                    height: 550,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Tabla Master (Izquierda)
                        Expanded(
                          flex: 7,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: GuideMasterList(
                              guias: _mockGuias,
                              selectedGuiaId: _selectedGuia?.id,
                                onGuiaSelected: (g) {
                                  setState(() => _selectedGuia = g);
                                  // Al seleccionar, mandamos abajo a su evaluación completa
                                  _scrollToBottom();
                                },
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Detalle Rápido (Derecha)
                        Expanded(
                          flex: 3,
                          child: _selectedGuia != null
                              ? GuideQuickDetail(
                                  guia: _selectedGuia!,
                                  onVerEvaluacion: _scrollToBottom,
                                )
                              : const Center(child: Text("Seleccione un guía")),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Separador
            Container(height: 8, color: Colors.grey.shade200),

            // PARTE INFERIOR: PERFIL COMPLETO (Imagen 3)
            if (_selectedGuia != null)
              GuideFullProfile(guia: _selectedGuia!),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStatCard("DISPONIBLES", "8", Colors.green, Icons.check_circle_outline),
          const SizedBox(width: 16),
          _buildStatCard("EN VIAJE ACTIVO", "4", Colors.blue, Icons.directions_bus_outlined),
          const SizedBox(width: 16),
          _buildStatCard("DESCANSO / PERMISO", "2", Colors.orange, Icons.pause_circle_outline),
          const SizedBox(width: 16),
          _buildStatCard("CAPACIDAD DE CUENTAS (PLAN)", "18 / 20", Colors.indigo, Icons.person_add_alt_outlined, subtitle: "Guías Registrados"),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon, {String? subtitle}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
                  const SizedBox(height: 8),
                  Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1B3B6F))),
                  if (subtitle != null) Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.05), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              decoration: InputDecoration(
                hintText: "Buscar nombre, ID...",
                hintStyle: const TextStyle(fontSize: 13),
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildDropdown("Rol: Todos"),
          const SizedBox(width: 12),
          _buildDropdown("Estado: Todos"),
          const Spacer(),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.filter_list, size: 18),
            label: const Text("Más filtros"),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const Icon(Icons.keyboard_arrow_down, size: 18),
        ],
      ),
    );
  }
}
