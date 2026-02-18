import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/itinerary_builder/itinerary_builder_cubit.dart';
import '../../domain/entities/actividad_itinerario.dart'; // Para TipoActividad
import '../widgets/itinerary_builder/activity_edit_dialog.dart'; // ✨ Fase 4

// Configuración visual de las herramientas
final List<Map<String, dynamic>> _catalogoHerramientas = [
  {
    'tipo': TipoActividad.hospedaje,
    'icon': Icons.hotel_rounded,
    'color': Colors.purple,
    'label': 'Hospedaje',
  },
  {
    'tipo': TipoActividad.comida,
    'icon': Icons.restaurant_rounded,
    'color': Colors.orange,
    'label': 'Alimentos',
  },
  {
    'tipo': TipoActividad.traslado,
    'icon': Icons.directions_bus_rounded,
    'color': Colors.blue,
    'label': 'Traslado',
  },
  {
    'tipo': TipoActividad.cultura,
    'icon': Icons.museum_rounded,
    'color': Colors.brown,
    'label': 'Cultura / Museo',
  },
  {
    'tipo': TipoActividad.aventura,
    'icon': Icons.hiking_rounded,
    'color': Colors.green,
    'label': 'Aventura',
  },
  {
    'tipo': TipoActividad.tiempoLibre,
    'icon': Icons.beach_access_rounded,
    'color': Colors.teal,
    'label': 'Tiempo Libre',
  },
];

class ItineraryBuilderScreen extends StatelessWidget {
  final int duracionDias;
  final TimeOfDay? horaInicio;
  final TimeOfDay? horaFin;

  const ItineraryBuilderScreen({
    super.key,
    this.duracionDias = 3,
    this.horaInicio,
    this.horaFin,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              ItineraryBuilderCubit()
                ..init(duracionDias, horaInicio: horaInicio, horaFin: horaFin),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text("Constructor de Itinerario"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.save),
                label: const Text("Guardar Viaje"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        body: BlocListener<ItineraryBuilderCubit, ItineraryBuilderState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              showDialog(
                context: context,
                builder:
                    (dialogContext) => AlertDialog(
                      icon: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 48,
                      ),
                      title: const Text('Horario Inválido'),
                      content: Text(
                        state.errorMessage!,
                        textAlign: TextAlign.center,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: const Text('Entendido'),
                        ),
                      ],
                    ),
              );
            }
          },
          child: const _BodyContent(),
        ),
      ),
    );
  }
}

class _BodyContent extends StatelessWidget {
  const _BodyContent();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ---------------------------------------------
        // PANEL IZQUIERDO: CAJA DE HERRAMIENTAS (20%)
        // ---------------------------------------------
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Bloques de Actividad",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  "Arrastra al itinerario",
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: _catalogoHerramientas.length,
                    itemBuilder: (context, index) {
                      final item = _catalogoHerramientas[index];
                      return _buildDraggableToolItem(
                        tipo: item['tipo'],
                        icon: item['icon'],
                        color: item['color'],
                        label: item['label'],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        const VerticalDivider(width: 1, thickness: 1),

        // ---------------------------------------------
        // PANEL CENTRAL: LÍNEA DE TIEMPO (50%)
        // ---------------------------------------------
        Expanded(
          flex: 5,
          child: Column(
            children: [
              const _DaysTabBar(),
              Expanded(child: const _TimelineDropZone()),
            ],
          ),
        ),

        const VerticalDivider(width: 1, thickness: 1),

        // ---------------------------------------------
        // PANEL DERECHO: HORARIOS + MAPA + STATS (30%)
        // ---------------------------------------------
        Expanded(
          flex: 3,
          child: Column(
            children: [
              // Mapa
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.blue[50],
                  child: const Center(child: Text("Mapa Interactivo")),
                ),
              ),
              const Divider(height: 1),
              // Panel de estadísticas y horarios
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✨ NUEVO: Selector de horario del día
                        const _DayTimeRangeSelector(),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),

                        // Indicador de tiempo restante
                        const _TimeRemainingIndicator(),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 10),

                        const Text(
                          "Resumen del Día",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        _buildStatRow(
                          Icons.eco,
                          "Huella de Carbono",
                          "0 kg CO2",
                        ),
                        _buildStatRow(
                          Icons.schedule,
                          "Duración Total",
                          "0 hrs",
                        ),
                        _buildStatRow(
                          Icons.attach_money,
                          "Costo Estimado",
                          "\$0.00",
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDraggableToolItem({
    required TipoActividad tipo,
    required IconData icon,
    required Color color,
    required String label,
  }) {
    final baseCard = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          const Icon(Icons.drag_indicator, color: Colors.grey, size: 16),
        ],
      ),
    );

    return Draggable<TipoActividad>(
      data: tipo,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.05,
          child: SizedBox(
            width: 200,
            child: Opacity(opacity: 0.9, child: baseCard),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: baseCard),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: baseCard,
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ============================================
// ✨ NUEVO: SELECTOR DE HORARIO DEL DÍA
// ============================================
class _DayTimeRangeSelector extends StatelessWidget {
  const _DayTimeRangeSelector();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItineraryBuilderCubit, ItineraryBuilderState>(
      builder: (context, state) {
        final cubit = context.read<ItineraryBuilderCubit>();
        final diaActual = state.diaSeleccionadoIndex;
        final esUnSoloDia = state.totalDias == 1;

        // Formatear horas para mostrar
        String formatHora(DateTime dt) {
          final h = dt.hour;
          final m = dt.minute.toString().padLeft(2, '0');
          final periodo = h >= 12 ? 'PM' : 'AM';
          final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
          return "$h12:$m $periodo";
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.blue[700]),
                const SizedBox(width: 6),
                Text(
                  "Horario del Día ${diaActual + 1}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // --- HORA DE INICIO ---
            _buildTimeRow(
              context: context,
              label: "Inicio",
              hora: formatHora(state.horaInicioDia),
              esFijo: state.esHoraInicioFija || esUnSoloDia,
              tooltipFijo:
                  esUnSoloDia
                      ? "Hora de inicio del viaje"
                      : "Hora de inicio fija del viaje",
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: state.horaInicioDia.hour,
                    minute: state.horaInicioDia.minute,
                  ),
                  builder:
                      (ctx, child) => MediaQuery(
                        data: MediaQuery.of(
                          ctx,
                        ).copyWith(alwaysUse24HourFormat: false),
                        child: child!,
                      ),
                );
                if (picked != null) {
                  final pickedDt = DateTime(
                    2024,
                    1,
                    1,
                    picked.hour,
                    picked.minute,
                  );
                  if (!pickedDt.isBefore(state.horaFinDia)) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "La hora de inicio debe ser anterior a la hora de fin (${formatHora(state.horaFinDia)})",
                          ),
                          backgroundColor: Colors.orange,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                    return;
                  }
                  // ignore: use_build_context_synchronously
                  cubit.setHoraInicioDia(diaActual, picked);
                }
              },
            ),
            const SizedBox(height: 8),

            // --- HORA DE FIN ---
            _buildTimeRow(
              context: context,
              label: "Fin",
              hora: formatHora(state.horaFinDia),
              esFijo: state.esHoraFinFija || esUnSoloDia,
              tooltipFijo:
                  esUnSoloDia
                      ? "Hora de fin del viaje"
                      : "Hora de fin fija del viaje",
              onTap: () async {
                // ✨ Si horaFin ≤ horaInicio, sugerir horaInicio + 1h como valor inicial
                final horaInicioActual = state.horaInicioDia;
                final horaFinActual = state.horaFinDia;
                final TimeOfDay initialTimeFin;
                if (!horaFinActual.isAfter(horaInicioActual)) {
                  final sugerida = horaInicioActual.add(
                    const Duration(hours: 1),
                  );
                  initialTimeFin = TimeOfDay(
                    hour: sugerida.hour % 24,
                    minute: sugerida.minute,
                  );
                } else {
                  initialTimeFin = TimeOfDay(
                    hour: horaFinActual.hour,
                    minute: horaFinActual.minute,
                  );
                }

                final picked = await showTimePicker(
                  context: context,
                  initialTime: initialTimeFin,
                  builder:
                      (ctx, child) => MediaQuery(
                        data: MediaQuery.of(
                          ctx,
                        ).copyWith(alwaysUse24HourFormat: false),
                        child: child!,
                      ),
                );
                if (picked != null) {
                  final pickedDt = DateTime(
                    2024,
                    1,
                    1,
                    picked.hour,
                    picked.minute,
                  );
                  if (!pickedDt.isAfter(state.horaInicioDia)) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "La hora de fin debe ser posterior a la hora de inicio (${formatHora(state.horaInicioDia)})",
                          ),
                          backgroundColor: Colors.orange,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                    return;
                  }
                  // ignore: use_build_context_synchronously
                  cubit.setHoraFinDia(diaActual, picked);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTimeRow({
    required BuildContext context,
    required String label,
    required String hora,
    required bool esFijo,
    required String tooltipFijo,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        // Etiqueta
        SizedBox(
          width: 36,
          child: Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
        const SizedBox(width: 8),

        // Campo de hora (editable o fijo)
        Expanded(
          child:
              esFijo
                  ? _buildFixedTimeChip(hora, tooltipFijo)
                  : _buildEditableTimeChip(context, hora, onTap),
        ),
      ],
    );
  }

  // Chip para hora FIJA (con candado)
  Widget _buildFixedTimeChip(String hora, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 13, color: Colors.grey[500]),
            const SizedBox(width: 6),
            Text(
              hora,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Chip para hora EDITABLE (con lápiz, tappable)
  Widget _buildEditableTimeChip(
    BuildContext context,
    String hora,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit, size: 13, color: Colors.blue[700]),
            const SizedBox(width: 6),
            Text(
              hora,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.blue[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// PESTAÑAS DE DÍAS (con scroll y flechas)
// ============================================
class _DaysTabBar extends StatefulWidget {
  const _DaysTabBar();

  @override
  State<_DaysTabBar> createState() => _DaysTabBarState();
}

class _DaysTabBarState extends State<_DaysTabBar> {
  final ScrollController _scrollCtrl = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateArrows());
    _scrollCtrl.addListener(_updateArrows);
  }

  void _updateArrows() {
    if (!_scrollCtrl.hasClients) return;
    setState(() {
      _canScrollLeft = _scrollCtrl.offset > 0;
      _canScrollRight =
          _scrollCtrl.offset < _scrollCtrl.position.maxScrollExtent;
    });
  }

  void _scrollLeft() {
    _scrollCtrl.animateTo(
      (_scrollCtrl.offset - 120).clamp(0, double.infinity),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  void _scrollRight() {
    _scrollCtrl.animateTo(
      _scrollCtrl.offset + 120,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Colors.white,
      child: BlocBuilder<ItineraryBuilderCubit, ItineraryBuilderState>(
        builder: (context, state) {
          return Row(
            children: [
              // Flecha izquierda
              AnimatedOpacity(
                opacity: _canScrollLeft ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 150),
                child: InkWell(
                  onTap: _canScrollLeft ? _scrollLeft : null,
                  child: Container(
                    width: 32,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.white.withValues(alpha: 0),
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.chevron_left,
                      color: Colors.blue[800],
                      size: 20,
                    ),
                  ),
                ),
              ),

              // Lista de días
              Expanded(
                child: ListView.builder(
                  controller: _scrollCtrl,
                  scrollDirection: Axis.horizontal,
                  itemCount: state.totalDias,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                  itemBuilder: (context, index) {
                    final isSelected = state.diaSeleccionadoIndex == index;
                    return GestureDetector(
                      onTap:
                          () => context
                              .read<ItineraryBuilderCubit>()
                              .cambiarDia(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? Colors.blue[800] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                          border:
                              isSelected
                                  ? null
                                  : Border.all(color: Colors.grey[300]!),
                        ),
                        child: Center(
                          child: Text(
                            "Día ${index + 1}",
                            style: TextStyle(
                              color:
                                  isSelected ? Colors.white : Colors.grey[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Flecha derecha
              AnimatedOpacity(
                opacity: _canScrollRight ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 150),
                child: InkWell(
                  onTap: _canScrollRight ? _scrollRight : null,
                  child: Container(
                    width: 32,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0),
                          Colors.white,
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.chevron_right,
                      color: Colors.blue[800],
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================
// ZONA DE DROP: TIMELINE
// ============================================
class _TimelineDropZone extends StatelessWidget {
  const _TimelineDropZone();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItineraryBuilderCubit, ItineraryBuilderState>(
      builder: (context, state) {
        final actividades = state.actividadesDelDiaActual;

        return DragTarget<TipoActividad>(
          onWillAcceptWithDetails: (details) => true,
          // 2. Cuando el usuario suelta el ítem
          onAcceptWithDetails: (details) {
            final cubit = context.read<ItineraryBuilderCubit>();
            cubit.onActivityDropped(details.data);

            // ✨ BONUS: Auto-abrir el dialog de edición al soltar
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final actividades = cubit.state.actividadesDelDiaActual;
              if (actividades.isEmpty) return;
              final ultimaActividad = actividades.last;
              showDialog(
                // ignore: use_build_context_synchronously
                context: context,
                builder:
                    (ctx) => ActivityEditDialog(
                      actividad: ultimaActividad,
                      onSave: (updated) => cubit.updateActivity(updated),
                      onDelete: (id) => cubit.deleteActivity(id),
                    ),
              );
            });
          },
          builder: (context, candidateData, rejectedData) {
            final isHovering = candidateData.isNotEmpty;

            return Container(
              color:
                  isHovering
                      ? Colors.blue.withValues(alpha: 0.05)
                      : Colors.grey[50],
              child:
                  actividades.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: actividades.length,
                        separatorBuilder: (_, __) => _buildConnectorLine(),
                        itemBuilder: (context, index) {
                          return _ItineraryItemCard(
                            activity: actividades[index],
                          );
                        },
                      ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.add_circle_outline_outlined,
            size: 48,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            "Arrastra bloques aquí\npara construir el día",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectorLine() {
    return Container(
      margin: const EdgeInsets.only(left: 28),
      height: 20,
      width: 2,
      color: Colors.grey[300],
    );
  }
}

// ============================================
// TARJETA DE ACTIVIDAD
// ============================================
class _ItineraryItemCard extends StatelessWidget {
  final ActividadItinerario activity;

  const _ItineraryItemCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    final start =
        "${activity.horaInicio.hour}:${activity.horaInicio.minute.toString().padLeft(2, '0')}";
    final end =
        "${activity.horaFin.hour}:${activity.horaFin.minute.toString().padLeft(2, '0')}";

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Text(
              start,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(end, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
          ],
        ),
        const SizedBox(width: 12),
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.blue[800],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 2),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  _getIconForType(activity.tipo),
                  color: Colors.grey[700],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.titulo,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (activity.descripcion.isNotEmpty)
                        Text(
                          activity.descripcion,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
                  onPressed: () {
                    final cubit = context.read<ItineraryBuilderCubit>();
                    showDialog(
                      context: context,
                      builder:
                          (ctx) => ActivityEditDialog(
                            actividad: activity,
                            onSave: (updated) => cubit.updateActivity(updated),
                            onDelete: (id) => cubit.deleteActivity(id),
                          ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _getIconForType(TipoActividad tipo) {
    switch (tipo) {
      case TipoActividad.hospedaje:
        return Icons.hotel;
      case TipoActividad.comida:
        return Icons.restaurant;
      case TipoActividad.traslado:
        return Icons.directions_bus;
      case TipoActividad.cultura:
        return Icons.museum;
      case TipoActividad.aventura:
        return Icons.hiking;
      case TipoActividad.tiempoLibre:
        return Icons.beach_access;
      default:
        return Icons.local_activity;
    }
  }
}

// ============================================
// INDICADOR DE TIEMPO RESTANTE
// ============================================
class _TimeRemainingIndicator extends StatelessWidget {
  const _TimeRemainingIndicator();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItineraryBuilderCubit, ItineraryBuilderState>(
      builder: (context, state) {
        final tiempoRestante = state.tiempoRestanteHoy;
        final tiempoUsado = state.tiempoUsadoHoy;
        final tiempoTotal =
            state.horaFinDia.difference(state.horaInicioDia).inMinutes;

        final horasRestantes = tiempoRestante ~/ 60;
        final minutosRestantes = tiempoRestante % 60;
        final horasUsadas = tiempoUsado ~/ 60;
        final minutosUsados = tiempoUsado % 60;

        Color indicatorColor;
        IconData indicatorIcon;
        String statusText;

        if (tiempoRestante > 240) {
          indicatorColor = Colors.green;
          indicatorIcon = Icons.check_circle;
          statusText = "Tiempo disponible";
        } else if (tiempoRestante > 120) {
          indicatorColor = Colors.orange;
          indicatorIcon = Icons.warning;
          statusText = "Tiempo limitado";
        } else {
          indicatorColor = Colors.red;
          indicatorIcon = Icons.error;
          statusText = "Poco tiempo";
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: indicatorColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: indicatorColor, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(indicatorIcon, color: indicatorColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: indicatorColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Usado:", style: TextStyle(fontSize: 12)),
                  Text(
                    "${horasUsadas}h ${minutosUsados}m",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Restante:", style: TextStyle(fontSize: 12)),
                  Text(
                    "${horasRestantes}h ${minutosRestantes}m",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: indicatorColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: tiempoTotal > 0 ? tiempoUsado / tiempoTotal : 0,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
