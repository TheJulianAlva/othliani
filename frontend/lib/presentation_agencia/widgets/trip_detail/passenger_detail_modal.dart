import 'package:flutter/material.dart';

class PassengerDetailModal extends StatelessWidget {
  final Map<String, dynamic> passenger;

  const PassengerDetailModal({super.key, required this.passenger});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 16,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
        child: Column(
          children: [
            // A. HEADERS
            _buildHeader(context),
            const Divider(height: 1),

            // B. BODY (2 Columns)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left Column: Profile (35%)
                  Expanded(
                    flex: 35,
                    child: Container(
                      color: Colors.grey.shade50,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProfileSection(),
                            const SizedBox(height: 24),
                            _buildEmergencyContact(),
                            const SizedBox(height: 24),
                            _buildDeviceInfo(),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const VerticalDivider(width: 1),

                  // Right Column: Intelligence (65%)
                  Expanded(
                    flex: 65,
                    child: DefaultTabController(
                      length: 3,
                      child: Column(
                        children: [
                          const TabBar(
                            labelColor: Color(0xFF0F4C75),
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: Color(0xFF0F4C75),
                            tabs: [
                              Tab(
                                icon: Icon(Icons.bar_chart),
                                text: 'Estadísticas',
                              ),
                              Tab(icon: Icon(Icons.history), text: 'Historial'),
                              Tab(icon: Icon(Icons.map), text: 'Ubicación'),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                _buildStatsTab(),
                                _buildLogsTab(),
                                const Center(child: Text('Mapa de Recorrido')),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // C. FOOTER
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                'DETALLE DE TURISTA: ${passenger['name'] ?? 'ANA GÓMEZ'}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F4C75),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.circle, size: 8, color: Colors.green),
                    SizedBox(width: 6),
                    Text(
                      'CONECTADO',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Reporte PDF'),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      children: [
        const Center(
          child: CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=ana'),
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoRow(Icons.badge, 'Folio', 'PA-9923'),
        _buildInfoRow(Icons.phone, 'Teléfono', '+52 55 1234 5678'),
        _buildInfoRow(Icons.bloodtype, 'Sangre', 'O+'),
        _buildInfoRow(
          Icons.medical_services,
          'Alergias',
          'Penicilina',
          isWarning: true,
        ),
      ],
    );
  }

  Widget _buildEmergencyContact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CONTACTO DE EMERGENCIA',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pedro Gómez',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Text(
                'Parentesco: Padre',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '+52 55 9876 5432',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16, color: Colors.blue),
                    onPressed: () {},
                    tooltip: 'Copiar',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DISPOSITIVO',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoRow(Icons.smartphone, 'Modelo', 'iPhone 13'),
        _buildInfoRow(
          Icons.battery_alert,
          'Batería',
          '15% (Crítico)',
          isCritical: true,
        ),
        _buildInfoRow(Icons.signal_cellular_alt, 'Señal', '2 Barras (4G)'),
      ],
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isWarning = false,
    bool isCritical = false,
  }) {
    Color color = Colors.black87;
    if (isWarning) color = Colors.orange.shade800;
    if (isCritical) color = Colors.red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'GRÁFICA DE CONECTIVIDAD (Últimas 4 hrs)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            // Mock Chart Visualization
            child: CustomPaint(painter: ConnectionChartPainter()),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 12, height: 12, color: Colors.blue),
              const SizedBox(width: 8),
              const Text('Señal (%)'),
              const SizedBox(width: 24),
              Container(width: 12, height: 12, color: Colors.green),
              const SizedBox(width: 8),
              const Text('Velocidad (km/h)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogsTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildLogEntry(
          '12:15 PM',
          'Recuperó conexión (4G)',
          'Conectividad',
          Colors.green,
        ),
        _buildLogEntry(
          '12:10 PM',
          '⚠ Batería baja (15%)',
          'Dispositivo',
          Colors.amber,
        ),
        _buildLogEntry(
          '11:45 AM',
          '⚠ Alerta Alejamiento (60m)',
          'Geo-Seguridad',
          Colors.orange,
        ),
        _buildLogEntry(
          '11:30 AM',
          'Ingreso a Geo-cerca "Mirador"',
          'Ubicación',
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildLogEntry(String time, String msg, String type, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 4, right: 12),
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  msg,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  type,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.call),
              label: const Text('LLAMAR DISPOSITIVO'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F4C75),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.message),
              label: const Text('ENVIAR MENSAJE'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.settings),
              label: const Text('GESTIONAR'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.grey),
                foregroundColor: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Simple Mock Painter for the Wireframe Look
class ConnectionChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintBlue =
        Paint()
          ..color = Colors.blue
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final paintGreen =
        Paint()
          ..color = Colors.green.withValues(alpha: 0.5)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final pathBlue = Path();
    final pathGreen = Path();

    // Mock Data Points
    pathBlue.moveTo(0, size.height * 0.2); // 80% signal
    pathBlue.lineTo(size.width * 0.2, size.height * 0.2);
    pathBlue.lineTo(size.width * 0.25, size.height * 0.8); // Drop
    pathBlue.lineTo(size.width * 0.4, size.height * 0.8);
    pathBlue.lineTo(size.width * 0.45, size.height * 0.3); // Recovery
    pathBlue.lineTo(size.width, size.height * 0.3);

    // Speed
    pathGreen.moveTo(0, size.height * 0.9);
    pathGreen.lineTo(size.width * 0.3, size.height * 0.85);
    pathGreen.lineTo(size.width * 0.6, size.height * 0.9);
    pathGreen.lineTo(size.width, size.height * 0.85);

    canvas.drawPath(pathBlue, paintBlue);
    canvas.drawPath(pathGreen, paintGreen);

    // Grid lines
    final gridPaint = Paint()..color = Colors.grey.withValues(alpha: 0.2);
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      gridPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
