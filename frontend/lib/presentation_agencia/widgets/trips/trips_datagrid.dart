import 'package:flutter/material.dart';

class TripsDatagrid extends StatefulWidget {
  const TripsDatagrid({super.key});

  @override
  State<TripsDatagrid> createState() => _TripsDatagridState();
}

class _TripsDatagridState extends State<TripsDatagrid> {
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void dispose() {
    _verticalScrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(24),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Expanded(
            child: Scrollbar(
              controller: _verticalScrollController,
              thumbVisibility: true,
              trackVisibility: true,
              child: SingleChildScrollView(
                controller: _verticalScrollController,
                scrollDirection: Axis.vertical,
                child: Scrollbar(
                  controller: _horizontalScrollController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  notificationPredicate:
                      (notification) => notification.depth == 0,
                  child: SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        Colors.grey.shade50,
                      ),
                      columns: const [
                        DataColumn(
                          label: Text(
                            'FOLIO',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'DESTINO / NOMBRE',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'GUÍA ASIGNADO',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'FECHAS',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'PAX',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'ESTADO',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(label: Text('')), // Actions
                      ],
                      rows: _getMockRows(context),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Simple Pagination Footer
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children: [
                const Text('Mostrando 10 filas'),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.chevron_left),
                    ),
                    const Text('Página 1 de 12'),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<DataRow> _getMockRows(BuildContext context) {
    final trips = [
      TripData(
        "2045",
        "Nevado de Toluca",
        "Juan Pérez",
        "22/01 - 23/01",
        "15",
        TripStatus.active,
      ),
      TripData(
        "2044",
        "Ruta del Vino QRO",
        "María González",
        "25/01 - 27/01",
        "42",
        TripStatus.scheduled,
      ),
      TripData(
        "2042",
        "Cañón del Sumidero",
        null,
        "01/02 - 05/02",
        "08",
        TripStatus.draft,
      ),
      TripData(
        "2040",
        "Huasteca Potosina",
        "Carlos Ruiz",
        "10/01 - 15/01",
        "20",
        TripStatus.finished,
      ),
    ];

    return trips.map((trip) {
      return DataRow(
        cells: [
          DataCell(
            Text(
              '#${trip.folio}',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          DataCell(Text(trip.name)),
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (trip.guideName != null) ...[
                  CircleAvatar(
                    radius: 10,
                    child: Text(
                      trip.guideName![0],
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(trip.guideName!),
                ] else
                  const Text(
                    '(Sin Asignar)',
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          DataCell(Text(trip.dates)),
          DataCell(Text(trip.pax)),
          DataCell(_buildStatusBadge(trip.status)),
          DataCell(
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Text('👁️ Ver Tablero'),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('✏️ Editar'),
                    ),
                    const PopupMenuItem(
                      value: 'pax',
                      child: Text('👥 Ver Turistas'),
                    ),
                    const PopupMenuItem(
                      value: 'cancel',
                      child: Text('🗑️ Cancelar'),
                    ),
                  ],
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildStatusBadge(TripStatus status) {
    Color color;
    Color textColor;
    String text;

    switch (status) {
      case TripStatus.active:
        color = Colors.green.shade100;
        textColor = Colors.green.shade800;
        text = 'ACTIVO';
        break;
      case TripStatus.scheduled:
        color = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        text = 'PROGRAMADO';
        break;
      case TripStatus.draft:
        color = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
        text = 'BORRADOR';
        break;
      case TripStatus.finished:
        color = Colors.black12;
        textColor = Colors.black87;
        text = 'FINALIZADO';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class TripData {
  final String folio;
  final String name;
  final String? guideName;
  final String dates;
  final String pax;
  final TripStatus status;

  TripData(
    this.folio,
    this.name,
    this.guideName,
    this.dates,
    this.pax,
    this.status,
  );
}

enum TripStatus { active, scheduled, draft, finished }
