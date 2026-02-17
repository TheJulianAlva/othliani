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
          // Formateo de fechas
          final inicio = v.fechaInicio;
          final fin = v.fechaFin;

          return TripData(
            v.id,
            v.destino,
            v.guiaNombre,
            inicio, // Pasamos DateTime completo
            fin, // Pasamos DateTime completo
            v.duracionLabel, // Pasamos la duración formateada desde la entidad
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
                      dataRowMinHeight: 40,
                      dataRowMaxHeight:
                          65, // <--- AUMENTADO PARA EVITAR OVERFLOW
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
                            'CALENDARIO / DURACIÓN',
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
                if (trip.guideName != null &&
                    trip.guideName != 'Sin asignar') ...[
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.indigo.shade100,
                    child: Text(
                      trip.guideName![0],
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.indigo.shade800,
                        fontWeight: FontWeight.bold,
                      ),
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
          // CELDA DE FECHAS INTELIGENTE
          DataCell(
            Builder(
              builder: (context) {
                // 1. Formatos Cortos (Para la vista rápida)
                final inicio = trip.fechaInicio;
                final fin = trip.fechaFin;

                String formatHoraCorto(DateTime dt) =>
                    "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
                String formatFechaCorto(DateTime dt) => "${dt.day}/${dt.month}";

                final inicioCorto =
                    "${formatFechaCorto(inicio)} ${formatHoraCorto(inicio)}";
                final finCorto = formatHoraCorto(fin);
                final finLargo =
                    "${formatFechaCorto(fin)} ${formatHoraCorto(fin)}";

                // Lógica visual: ¿Es mismo día o multi-día?
                final bool mismoDia =
                    inicio.day == fin.day &&
                    inicio.month == fin.month &&
                    inicio.year == fin.year;

                // 2. Formato Largo y Humano (Para el Tooltip)
                final tooltipMessage = _generarTooltipHumano(inicio, fin);

                return Tooltip(
                  message: tooltipMessage, // <--- AQUÍ ESTÁ LA MAGIA
                  waitDuration: const Duration(milliseconds: 500),
                  showDuration: const Duration(seconds: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(color: Colors.white, fontSize: 12),

                  // EL CONTENIDO VISUAL (LO DE SIEMPRE)
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_month,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              mismoDia
                                  ? "$inicioCorto - $finCorto"
                                  : "$inicioCorto ➝ $finLargo",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            trip.duracionLabel, // "3 días"
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue[900],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
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

  String _generarTooltipHumano(DateTime inicio, DateTime fin) {
    // Array de meses y días para español
    const meses = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];

    String formatoHora(DateTime dt) {
      final hora = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      final min = dt.minute.toString().padLeft(2, '0');
      return "$hora:$min $ampm";
    }

    String formatoFecha(DateTime dt) {
      return "${dt.day} de ${meses[dt.month - 1]} ${dt.year}";
    }

    // Lógica:
    // Si es mismo día: "10 de Feb 2026 (10:00 AM - 06:00 PM)"
    // Si es diferente: "10 de Feb 10:00 AM hasta 12 de Feb 06:00 PM"

    if (inicio.year == fin.year &&
        inicio.month == fin.month &&
        inicio.day == fin.day) {
      return "📅 ${formatoFecha(inicio)}\n⏰ Horario: ${formatoHora(inicio)} - ${formatoHora(fin)}";
    } else {
      return "🛫 Inicio: ${formatoFecha(inicio)} a las ${formatoHora(inicio)}\n🛬 Fin:    ${formatoFecha(fin)} a las ${formatoHora(fin)}";
    }
  }
}

class TripData {
  final String folio;
  final String name;
  final String? guideName;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String duracionLabel;
  final String pax;
  final TripStatus status;

  TripData(
    this.folio,
    this.name,
    this.guideName,
    this.fechaInicio,
    this.fechaFin,
    this.duracionLabel,
    this.pax,
    this.status,
  );
}

enum TripStatus { active, scheduled, draft, finished }
