import 'package:flutter/material.dart';

class GuidesTab extends StatelessWidget {
  const GuidesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // License / Subscription Status Bar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          color: Colors.blue.shade50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ESTADO DE TU SUSCRIPCIÓN B2B',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F4C75),
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: 12 / 15,
                            minHeight: 10,
                            backgroundColor: Colors.white,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.green,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Estás usando 12 de 15 licencias de Guía.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF0F4C75),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.upgrade, size: 16),
                    label: const Text('ADQUIRIR MÁS'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Toolbar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '🔍 Buscar Guía...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  ),
                ),
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
                  0: FlexColumnWidth(2.5), // Empleado
                  1: FlexColumnWidth(2), // Viajes Asig.
                  2: FlexColumnWidth(1.5), // Licencia Activa
                  3: FlexColumnWidth(2), // Ultimo Acceso
                  4: FlexColumnWidth(1.5), // Acciones
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
                      _buildHeaderCell('EMPLEADO'),
                      _buildHeaderCell('VIAJES ASIG.'),
                      _buildHeaderCell('LICENCIA ACTIVA?'),
                      _buildHeaderCell('ULTIMO ACCESO'),
                      _buildHeaderCell('ACCIONES'),
                    ],
                  ),
                  // Row 1
                  _buildGuideRow(
                    name: 'Marcos Ruiz',
                    initials: 'MR',
                    avatarColor: Colors.blue.shade100,
                    tripStatus: '🟢 En Ruta',
                    tripDetail: '(Viaje #204)',
                    isActiveSlot: true,
                    lastAccess: 'Hace 5 min\nApp Android',
                  ),
                  // Row 2
                  _buildGuideRow(
                    name: 'Ana Paula G.',
                    initials: 'AP',
                    avatarColor: Colors.purple.shade100,
                    tripStatus: '⚪ Inactiva',
                    tripDetail: '',
                    isActiveSlot: true,
                    lastAccess: 'Ayer 18:00\nWeb',
                  ),
                  // Row 3
                  _buildGuideRow(
                    name: 'Pedro S.',
                    initials: 'PS',
                    avatarColor: Colors.orange.shade100,
                    tripStatus: '⚪ Inactivo',
                    tripDetail: '',
                    isActiveSlot: false,
                    lastAccess: 'Hace 1 mes\n--',
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

  TableRow _buildGuideRow({
    required String name,
    required String initials,
    required Color avatarColor,
    required String tripStatus,
    required String tripDetail,
    required bool isActiveSlot,
    required String lastAccess,
  }) {
    return TableRow(
      children: [
        // Empleado
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: avatarColor,
                radius: 16,
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F4C75),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F4C75),
                ),
              ),
            ],
          ),
        ),
        // Viajes Asig
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tripStatus,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color:
                      tripStatus.contains('🟢')
                          ? Colors.green.shade700
                          : Colors.grey.shade600,
                ),
              ),
              if (tripDetail.isNotEmpty)
                Text(
                  tripDetail,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
            ],
          ),
        ),
        // Licencia Activa
        Padding(
          padding: const EdgeInsets.all(12),
          child: Tooltip(
            message:
                isActiveSlot
                    ? 'Ocupa Slot de Licencia. Puede loguearse.'
                    : 'Pausado. No ocupa Slot. No puede loguearse.',
            child: Row(
              children: [
                Icon(
                  isActiveSlot ? Icons.check_circle : Icons.pause_circle_filled,
                  color: isActiveSlot ? Colors.green : Colors.grey,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  isActiveSlot ? 'SÍ' : 'NO',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        isActiveSlot
                            ? Colors.green.shade800
                            : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Ultimo Acceso
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            lastAccess,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        // Acciones
        Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, // Reduced horizontal padding
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  isActiveSlot ? 'Editar' : 'Reactivar',
                  style: const TextStyle(fontSize: 11), // Slightly smaller font
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                onPressed: () {},
                tooltip: 'Más Acciones',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
