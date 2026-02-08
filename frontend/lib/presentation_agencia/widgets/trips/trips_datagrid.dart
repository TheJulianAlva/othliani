import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../domain/entities/viaje.dart';

class TripsDatagrid extends StatefulWidget {
  final List<Viaje> viajes; // Recibe la datos desde el padre

  const TripsDatagrid({super.key, required this.viajes});

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
    // Mapeo de datos (Entity -> ViewModel local)
    final List<TripData> trips =
        widget.viajes.map((v) {
          return TripData(
            v.id,
            v.destino,
            'N/A', // idGuia removed from Entity per user spec
            "22/01 - 23/01",
            v.turistas.toString(),
            _mapStatus(v.estado),
          );
        }).toList();

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
                      rows: _buildDataRows(context, trips),
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
                Text('Mostrando ${trips.length} filas'),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.chevron_left),
                    ),
                    const Text('Página 1 de 1'),
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

  TripStatus _mapStatus(String status) {
    switch (status) {
      case 'EN_CURSO':
        return TripStatus.active;
      case 'PROGRAMADO':
        return TripStatus.scheduled;
      case 'FINALIZADO':
        return TripStatus.finished;
      default:
        return TripStatus.draft;
    }
  }

  List<DataRow> _buildDataRows(BuildContext context, List<TripData> trips) {
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
            Builder(
              builder: (ctx) {
                // Determine if trip is active for intelligent UI
                final esActivo = trip.status == TripStatus.active;

                return PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (value) {
                    switch (value) {
                      case 'ver':
                        // Navigate with section parameter for highlighting
                        context.go('/viajes/${trip.folio}?section=turistas');
                        break;
                      case 'editar':
                        // Show edit simulation
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              '🔧 Edición simulada: Los datos están precargados.',
                            ),
                            backgroundColor: Colors.blue,
                            duration: Duration(seconds: 2),
                          ),
                        );
                        break;
                      case 'cancelar':
                        // Show cancel confirmation dialog
                        _mostrarDialogoCancelar(context, trip);
                        break;
                    }
                  },
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          value: 'ver',
                          child: Row(
                            children: [
                              Icon(
                                esActivo
                                    ? Icons.monitor_heart
                                    : Icons.description,
                                size: 18,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                esActivo
                                    ? 'Monitorear en Vivo'
                                    : 'Ver Expediente / Lista',
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'editar',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18, color: Colors.grey),
                              SizedBox(width: 8),
                              Text('Editar Datos'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'cancelar',
                          child: Row(
                            children: [
                              Icon(
                                Icons.cancel,
                                size: 18,
                                color: Colors.redAccent,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Cancelar Viaje',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ],
                          ),
                        ),
                      ],
                );
              },
            ),
          ),
        ],
      );
    }).toList();
  }

  void _mostrarDialogoCancelar(BuildContext context, TripData trip) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('¿Cancelar Viaje?'),
            content: Text(
              'Estás a punto de cancelar el viaje a ${trip.name}.\nEsta acción es irreversible en producción.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Volver'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.pop(ctx); // Close dialog
                  // Here you would call: context.read<ViajesBloc>().add(DeleteViaje(id));

                  // Visual feedback for simulation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '🚫 Viaje a ${trip.name} cancelado (Simulación)',
                      ),
                      backgroundColor: Colors.red[700],
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text('Confirmar Cancelación'),
              ),
            ],
          ),
    );
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
