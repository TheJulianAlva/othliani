import 'package:flutter/material.dart';
import '../../widgets/trip_detail/passenger_detail_modal.dart';

class TripPassengerList extends StatelessWidget {
  const TripPassengerList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header Search
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'NÓMINA (PAX)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar Turista...',
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 18,
                      color: Colors.grey,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildPaxItem(
                  context: context,
                  name: 'Ana Gómez',
                  status: PaxStatus.critical,
                  distance: '120m',
                  isFar: true,
                  battery: 15,
                  signal: 2,
                ),
                _buildPaxItem(
                  context: context,
                  name: 'Luis Pérez',
                  status: PaxStatus.warning,
                  distance: '45m',
                  isFar: false, // Borderline
                  battery: 10,
                  signal: 3,
                ),
                _buildPaxItem(
                  context: context,
                  name: 'Carlos Ruiz',
                  status: PaxStatus.ok,
                  distance: '10m',
                  isFar: false,
                  battery: 90,
                  signal: 4,
                ),
                _buildPaxItem(
                  context: context,
                  name: 'Pepe (Offline)',
                  status: PaxStatus.offline,
                  subtitle: 'Hace 15 min',
                  distance: 'UNKNOWN',
                  isFar: false,
                  battery: 0,
                  signal: 0,
                ),
                // Mock filler
                for (int i = 0; i < 5; i++)
                  _buildPaxItem(
                    context: context,
                    name: 'Turista #$i',
                    status: PaxStatus.ok,
                    distance: '${10 + i}m',
                    isFar: false,
                    battery: 80 - i * 5,
                    signal: 4,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaxItem({
    required BuildContext context,
    required String name,
    required PaxStatus status,
    required String distance,
    required bool isFar,
    required int battery,
    required int signal,
    String? subtitle,
  }) {
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case PaxStatus.critical:
        statusColor = Colors.red;
        statusIcon = Icons.warning_rounded;
        break;
      case PaxStatus.warning:
        statusColor = Colors.amber.shade700;
        statusIcon = Icons.info_outline;
        break;
      case PaxStatus.ok:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        break;
      case PaxStatus.offline:
        statusColor = Colors.grey;
        statusIcon = Icons.cloud_off;
        break;
    }

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder:
                  (context) => PassengerDetailModal(
                    passenger: {'name': name, 'status': status},
                  ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Icon
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(statusIcon, color: statusColor, size: 18),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color:
                                  status == PaxStatus.offline
                                      ? Colors.grey
                                      : Colors.black87,
                            ),
                          ),
                          if (status == PaxStatus.critical)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'SOS!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        )
                      else
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 12,
                              color: isFar ? Colors.red : Colors.grey,
                            ),
                            Text(
                              ' A $distance ${isFar ? "(Lejos)" : ""}',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    isFar ? Colors.red : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 8),
                      // Telemetry
                      if (status != PaxStatus.offline)
                        Row(
                          children: [
                            Icon(
                              Icons.battery_std,
                              size: 14,
                              color: battery < 20 ? Colors.red : Colors.green,
                            ),
                            Text(
                              '$battery%',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.signal_cellular_alt,
                              size: 14,
                              color: Colors.grey,
                            ),
                          ],
                        ),

                      // Actions if Critical
                      if (status == PaxStatus.critical) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 28,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade50,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                            child: const Text(
                              'ACCIONES DE PÁNICO',
                              style: TextStyle(color: Colors.red, fontSize: 11),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum PaxStatus { critical, warning, ok, offline }
