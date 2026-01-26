import 'package:flutter/material.dart';

class ClientsTab extends StatelessWidget {
  const ClientsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toolbar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '🔍 Buscar Cliente por Nombre, Email o Teléfono',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Filter Placeholders
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.filter_list, size: 16),
                label: const Text('Más Filtros'),
              ),
            ],
          ),
        ),

        // Table
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(3), // Nombre
                  1: FlexColumnWidth(2), // Frecuencia
                  2: FlexColumnWidth(2), // Ultimo Viaje
                  3: FlexColumnWidth(3), // Notas
                  4: FlexColumnWidth(1), // Historial Button
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                border: TableBorder(
                  horizontalInside: BorderSide(color: Colors.grey.shade100),
                ),
                children: [
                  // Header
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey.shade50),
                    children: [
                      _buildHeaderCell('CLIENTE'),
                      _buildHeaderCell('FRECUENCIA'),
                      _buildHeaderCell('ÚLTIMO VIAJE'),
                      _buildHeaderCell('NOTAS INTERNAS'),
                      _buildHeaderCell(''),
                    ],
                  ),
                  // Row 1
                  _buildClientRow(
                    name: 'Ana Gómez',
                    email: 'ana.gomez@mail.com',
                    frequency: '3 Viajes',
                    lastTrip: 'Nevado de Toluca\n(Ene 2026)',
                    notes: 'Cliente VIP, Alérgica a nueces',
                    initials: 'AG',
                    avatarColor: Colors.purple.shade100,
                    textColor: Colors.purple.shade900,
                  ),
                  // Row 2
                  _buildClientRow(
                    name: 'Carlos Pérez',
                    email: 'cperez@mail.com',
                    frequency: '1 Viaje',
                    lastTrip: 'Teotihuacán\n(Dic 2025)',
                    notes: '--',
                    initials: 'CP',
                    avatarColor: Colors.blue.shade100,
                    textColor: Colors.blue.shade900,
                  ),
                  // Row 3
                  _buildClientRow(
                    name: 'Luisa Fernanda',
                    email: 'luisa.f@mail.com',
                    frequency: '5 Viajes',
                    lastTrip: 'Hierve el Agua\n(Nov 2025)',
                    notes: 'Prefiere asientos ventana',
                    initials: 'LF',
                    avatarColor: Colors.orange.shade100,
                    textColor: Colors.orange.shade900,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  TableRow _buildClientRow({
    required String name,
    required String email,
    required String frequency,
    required String lastTrip,
    required String notes,
    required String initials,
    required Color avatarColor,
    required Color textColor,
  }) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: avatarColor,
                radius: 18,
                child: Text(
                  initials,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F4C75),
                      ),
                    ),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            frequency,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            lastTrip,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(
                Icons.sticky_note_2_outlined,
                size: 14,
                color: Colors.amber,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  notes,
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: IconButton(
            icon: const Icon(Icons.history, color: Colors.blue),
            tooltip: 'Ver Historial Completo',
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}
