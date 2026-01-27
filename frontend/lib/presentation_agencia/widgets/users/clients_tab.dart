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

        // Sticky Header Container
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              Expanded(flex: 3, child: _buildHeaderCell('CLIENTE')),
              Expanded(flex: 2, child: _buildHeaderCell('FRECUENCIA')),
              Expanded(flex: 2, child: _buildHeaderCell('ÚLTIMO VIAJE')),
              Expanded(flex: 3, child: _buildHeaderCell('NOTAS INTERNAS')),
              Expanded(flex: 1, child: _buildHeaderCell('')),
            ],
          ),
        ),

        // List Body
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _ClientRow(
                name: 'Ana Gómez',
                email: 'ana.gomez@mail.com',
                frequency: '3 Viajes',
                lastTrip: 'Nevado de Toluca\n(Ene 2026)',
                notes: 'Cliente VIP, Alérgica a nueces',
                initials: 'AG',
                avatarColor: Colors.purple.shade100,
                textColor: Colors.purple.shade900,
              ),
              const Divider(height: 1),
              _ClientRow(
                name: 'Carlos Pérez',
                email: 'cperez@mail.com',
                frequency: '1 Viaje',
                lastTrip: 'Teotihuacán\n(Dic 2025)',
                notes: '--',
                initials: 'CP',
                avatarColor: Colors.blue.shade100,
                textColor: Colors.blue.shade900,
              ),
              const Divider(height: 1),
              _ClientRow(
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
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.grey.shade600,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
  }
}

class _ClientRow extends StatelessWidget {
  final String name;
  final String email;
  final String frequency;
  final String lastTrip;
  final String notes;
  final String initials;
  final Color avatarColor;
  final Color textColor;

  const _ClientRow({
    required this.name,
    required this.email,
    required this.frequency,
    required this.lastTrip,
    required this.notes,
    required this.initials,
    required this.avatarColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      hoverColor: const Color(0xFFF5F5F5), // Hover Effect!
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Cliente
            Expanded(
              flex: 3,
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
            // Frecuencia
            Expanded(
              flex: 2,
              child: Text(
                frequency,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            // Ultimo Viaje
            Expanded(
              flex: 2,
              child: Text(
                lastTrip,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            // Notas
            Expanded(
              flex: 3,
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
            // Actions
            Expanded(
              flex: 1,
              child: IconButton(
                icon: const Icon(Icons.history, color: Colors.blue),
                tooltip: 'Ver Historial Completo',
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
