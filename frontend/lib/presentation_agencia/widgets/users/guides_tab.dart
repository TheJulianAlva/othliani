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

        // Sticky Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              Expanded(flex: 3, child: _buildHeaderCell('EMPLEADO')),
              Expanded(flex: 2, child: _buildHeaderCell('VIAJES ASIG.')),
              Expanded(flex: 2, child: _buildHeaderCell('LICENCIA ACTIVA?')),
              Expanded(flex: 2, child: _buildHeaderCell('ULTIMO ACCESO')),
              Expanded(flex: 2, child: _buildHeaderCell('ACCIONES')),
            ],
          ),
        ),

        // List Content (Scrollable)
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _GuideRow(
                name: 'Marcos Ruiz',
                initials: 'MR',
                avatarColor: Colors.blue.shade100,
                tripStatus: '🟢 En Ruta',
                tripDetail: '(Viaje #204)',
                isActiveSlot: true,
                lastAccess: 'Hace 5 min\nApp Android',
              ),
              const Divider(height: 1),
              _GuideRow(
                name: 'Ana Paula G.',
                initials: 'AP',
                avatarColor: Colors.purple.shade100,
                tripStatus: '⚪ Inactiva',
                tripDetail: '',
                isActiveSlot: true,
                lastAccess: 'Ayer 18:00\nWeb',
              ),
              const Divider(height: 1),
              _GuideRow(
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

class _GuideRow extends StatelessWidget {
  final String name;
  final String initials;
  final Color avatarColor;
  final String tripStatus;
  final String tripDetail;
  final bool isActiveSlot;
  final String lastAccess;

  const _GuideRow({
    required this.name,
    required this.initials,
    required this.avatarColor,
    required this.tripStatus,
    required this.tripDetail,
    required this.isActiveSlot,
    required this.lastAccess,
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
            // Empleado
            Expanded(
              flex: 3,
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
            Expanded(
              flex: 2,
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
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
            // Licencia Activa
            Expanded(
              flex: 2,
              child: Tooltip(
                message:
                    isActiveSlot
                        ? 'Ocupa Slot de Licencia. Puede loguearse.'
                        : 'Pausado. No ocupa Slot. No puede loguearse.',
                child: Row(
                  children: [
                    Icon(
                      isActiveSlot
                          ? Icons.check_circle
                          : Icons.pause_circle_filled,
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
            Expanded(
              flex: 2,
              child: Text(
                lastAccess,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            // Acciones
            Expanded(
              flex: 2,
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      isActiveSlot ? 'Editar' : 'Reactivar',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.more_vert,
                      size: 18,
                      color: Colors.grey,
                    ),
                    onPressed: () {},
                    tooltip: 'Más Acciones',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
