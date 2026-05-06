import 'package:flutter/material.dart';

class AuditToolbar extends StatefulWidget {
  const AuditToolbar({super.key});

  @override
  State<AuditToolbar> createState() => _AuditToolbarState();
}

class _AuditToolbarState extends State<AuditToolbar> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          // Row 1: Filters (Scrollable)
          Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(bottom: 12), // Space for scrollbar
              child: Row(
                children: [
                  _buildFilterMenu(
                    context,
                    icon: Icons.calendar_today,
                    label: 'Rango',
                    value: 'Últimos 7 días',
                    options: [
                      'Hoy (00:00 - Actualidad)',
                      'Ayer',
                      'Últimos 7 días',
                      'Últimos 30 días',
                      'Este año',
                      '--divider--',
                      'Rango Personalizado...',
                    ],
                  ),
                  const SizedBox(width: 12),
                  _buildFilterMenu(
                    context,
                    icon: Icons.person,
                    label: 'Actor',
                    value: 'Todos',
                    options: [
                      'Todos los Actores',
                      'Sistema (Automático)',
                      'Administradores',
                      'Guías',
                      'Turistas',
                    ],
                  ),
                  const SizedBox(width: 12),
                  _buildFilterMenu(
                    context,
                    icon: Icons.label,
                    label: 'Evento',
                    value: 'Seguridad / SOS',
                    options: [
                      'Todos los Eventos',
                      '🚨 Seguridad / SOS',
                      '🔐 Acceso y Auth',
                      '⚙️ Configuración',
                      '💾 Datos (CRUD)',
                      '📡 Conectividad',
                    ],
                  ),
                  const SizedBox(width: 24), // Gap before export button
                  // Export Button
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('Exportar CSV/PDF (Legal)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade800,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Row 2: Search
          TextField(
            decoration: InputDecoration(
              hintText:
                  '🔍 Buscar por palabra clave (ej: Folio #MEX-015, IP, "Error")',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterMenu(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required List<String> options,
  }) {
    return PopupMenuButton<String>(
      tooltip: 'Filtrar por $label',
      onSelected: (val) {}, // Mock selection
      itemBuilder: (context) {
        return options.map<PopupMenuEntry<String>>((opt) {
          if (opt == '--divider--') {
            return const PopupMenuDivider();
          }
          return PopupMenuItem<String>(
            value: opt,
            height: 32,
            child: Text(opt, style: const TextStyle(fontSize: 13)),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
          color: Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade700),
            const SizedBox(width: 8),
            Text(
              '$label: ',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
                fontSize: 13,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: Colors.grey.shade900,
                fontWeight: FontWeight.w600, // Bold selected value
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 18, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }
}
