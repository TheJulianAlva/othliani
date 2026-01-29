import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/viajes/viajes_bloc.dart';

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
    return BlocBuilder<ViajesBloc, ViajesState>(
      builder: (context, state) {
        if (state is ViajesLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<TripData> trips = [];
        if (state is ViajesLoaded) {
          trips =
              state.viajes.map((v) {
                return TripData(
                  v.id,
                  v.destino,
                  'N/A', // idGuia removed from Entity per user spec
                  "22/01 - 23/01",
                  v.turistas.toString(),
                  _mapStatus(v.estado),
                );
              }).toList();
        } else if (state is ViajesError) {
          return Center(child: Text(state.message));
        }

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
      },
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
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'view') {
                  context.go('/viajes/${trip.folio}');
                }
              },
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
