import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/itinerary_builder/itinerary_builder_cubit.dart';
import '../../domain/entities/actividad_itinerario.dart'; // Para TipoActividad
import '../widgets/itinerary_builder/activity_edit_dialog.dart'; // ✨ Fase 4
import 'package:frontend/core/di/service_locator.dart' as di; // ✨ Fase 5: DI
import '../../domain/repositories/trip_repository.dart'; // ✨ Fase 5
import 'itinerary_builder_route_map.dart'; // ✨ Widget del mapa de ruta
import '../../domain/entities/viaje.dart'; // ✨ Import necesario
import 'package:frontend/features/agencia/trips/data/datasources/trip_local_data_source.dart'; // 💾 Import necesario
import '../../../shared/presentation/widgets/draft_guard_widget.dart'; // 🛡️ Draft Guard
import 'package:frontend/core/services/unsaved_changes_service.dart';

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
  final Viaje viajeBase; // ✨ AHORA: Recibimos todo el objeto

  const ItineraryBuilderScreen({super.key, required this.viajeBase});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => ItineraryBuilderCubit(
            repository: di.sl<TripRepository>(), // ✨ FASE 5: Inyectar repo
            localDataSource: di.sl<TripLocalDataSource>(), // 💾 Persistencia
            unsavedChangesService: di.sl<UnsavedChangesService>(),
          )..init(
            // Calculamos duración aquí o en el Cubit.
            // Si es 1 día, duration es 1. Si son fechas diferentes, diff + 1.
            // Calculamos duración en días calendario (ignorando horas)
            DateTime(
                      viajeBase.fechaFin.year,
                      viajeBase.fechaFin.month,
                      viajeBase.fechaFin.day,
                    )
                    .difference(
                      DateTime(
                        viajeBase.fechaInicio.year,
                        viajeBase.fechaInicio.month,
                        viajeBase.fechaInicio.day,
                      ),
                    )
                    .inDays +
                1,
            fechaInicio: viajeBase.fechaInicio,
            fechaFin: viajeBase.fechaFin,
          ),
      child: BlocBuilder<ItineraryBuilderCubit, ItineraryBuilderState>(
        builder: (context, state) {
          // Condición: Si hay actividades en el mapa, advertimos
          final bool hayCambios = state.actividadesPorDia.isNotEmpty;
          // O si ya se guardó exitosamente, NO advertimos al salir
          final bool yaGuardo = state.isSaved;

          return DraftGuardWidget(
            shouldWarn: hayCambios && !yaGuardo,
            child: Scaffold(
              backgroundColor: Colors.grey[50],
              appBar: AppBar(
                title: const Text("Constructor de Itinerario"),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                elevation: 0.5,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed:
                      () => Navigator.maybePop(context), // Trigger PopScope
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: BlocBuilder<
                      ItineraryBuilderCubit,
                      ItineraryBuilderState
                    >(
                      builder: (context, state) {
                        return ElevatedButton.icon(
                          onPressed:
                              state.isSaving
                                  ? null
                                  : () {
                                    context
                                        .read<ItineraryBuilderCubit>()
                                        .saveFullTrip(viajeBase);
                                  },
                          icon:
                              state.isSaving
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Icon(Icons.save),
                          label: Text(
                            state.isSaving ? "Guardando..." : "Finalizar Viaje",
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[800],
                            foregroundColor: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              body: BlocListener<ItineraryBuilderCubit, ItineraryBuilderState>(
                listener: (context, state) {
                  if (state.isSaved) {
                    // ✨ ÉXITO: Navegar al Dashboard / Lista de Viajes
                    Navigator.of(
                      context,
                    ).pop(); // Regresar a la lista (refresh auto?)
                  }

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
                                onPressed:
                                    () => Navigator.of(dialogContext).pop(),
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
        },
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
              Expanded(flex: 1, child: const DayRouteMap()),
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
                  // ✨ Corrección: usar fechas reales del día
                  final fechaBase = state.fechaBaseDiaActual;
                  final pickedDt = DateTime(
                    fechaBase.year,
                    fechaBase.month,
                    fechaBase.day,
                    picked.hour,
                    picked.minute,
                  );

                  // 1. Validar contra el día anterior (continuidad)
                  if (state.diaSeleccionadoIndex > 0) {
                    final actividadesAyer =
                        state.actividadesPorDia[state.diaSeleccionadoIndex - 1];
                    if (actividadesAyer != null && actividadesAyer.isNotEmpty) {
                      final ultimaAyer = actividadesAyer.last;
                      if (pickedDt.isBefore(ultimaAyer.horaFin)) {
                        if (context.mounted) {
                          showDialog(
                            context: context,
                            builder:
                                (ctx) => Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.warning_amber_rounded,
                                          size: 48,
                                          color: Colors.orange,
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          "Horario Inválido",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          "La actividad anterior termina a las ${formatHora(ultimaAyer.horaFin)}.\nNo puedes iniciar este día antes de esa hora.",
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(height: 1.5),
                                        ),
                                        const SizedBox(height: 24),
                                        SizedBox(
                                          width: double.infinity,
                                          child: FilledButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            style: FilledButton.styleFrom(
                                              backgroundColor: Colors.orange,
                                            ),
                                            child: const Text("Entendido"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          );
                        }
                        return;
                      }
                    }
                  }

                  // 1.5 Validar contra primera actividad del día actual
                  if (state.actividadesDelDiaActual.isNotEmpty) {
                    final primeraActividad =
                        state.actividadesDelDiaActual.first;
                    // Si la primera actividad empieza ANTES o igual que la nueva hora inicio...
                    // La hora de inicio del día DEBE ser <= hora inicio primera actividad.
                    if (pickedDt.isAfter(primeraActividad.horaInicio)) {
                      if (context.mounted) {
                        showDialog(
                          context: context,
                          builder:
                              (ctx) => Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.warning_amber_rounded,
                                        size: 48,
                                        color: Colors.orange,
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        "Horario Inválido",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        "Ya tienes una actividad a las ${formatHora(primeraActividad.horaInicio)}.\nLa hora de inicio del día no puede ser posterior a tus actividades.",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(height: 1.5),
                                      ),
                                      const SizedBox(height: 24),
                                      SizedBox(
                                        width: double.infinity,
                                        child: FilledButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          style: FilledButton.styleFrom(
                                            backgroundColor: Colors.orange,
                                          ),
                                          child: const Text("Entendido"),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        );
                      }
                      return;
                    }
                  }

                  // 2. Validar contra el fin del mismo día
                  if (!pickedDt.isBefore(state.horaFinDia)) {
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        builder:
                            (ctx) => Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade100,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.schedule,
                                        size: 40,
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "Hora Inválida",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "La hora de inicio debe ser anterior a la hora de fin (${formatHora(state.horaFinDia)}).",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.orange.shade600,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          "Entendido",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                  // ✨ Corrección: usar fechas reales del día
                  final fechaBase = state.fechaBaseDiaActual;
                  var pickedDt = DateTime(
                    fechaBase.year,
                    fechaBase.month,
                    fechaBase.day,
                    picked.hour,
                    picked.minute,
                  );

                  // ❌ ELIMINADO: No asumir día siguiente automáticamente.
                  // Si el usuario quiere terminar al día siguiente, debería ser explícito o
                  // entender que "02:00 AM" < "08:00 AM" -> Error.
                  // Pero el usuario pidió explícitamente que NO se auto-corrigiera ni se asumiera,
                  // sino que "indicara que algo anda mal".

                  // Validar contra inicio
                  if (!pickedDt.isAfter(state.horaInicioDia)) {
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        builder:
                            (ctx) => Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade100,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.schedule,
                                        size: 40,
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "Hora Inválida",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "La hora de fin debe ser posterior a la hora de inicio (${formatHora(state.horaInicioDia)}).",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.orange.shade600,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          "Entendido",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      );
                    }
                    return;
                  }
                  // ignore: use_build_context_synchronously
                  cubit.setHoraFinDia(diaActual, pickedDt);
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
        // ✨ SINCRONIZACIÓN NOCTURNA: actividad del día anterior que continúa hoy
        final actividadContinuacion = state.actividadNocturnaDelDiaAnterior;
        final diaAnterior = state.diaSeleccionadoIndex - 1;

        return DragTarget<TipoActividad>(
          // Bloquear el drop si no hay tiempo y el modo horas extra no está activo
          onWillAcceptWithDetails: (details) {
            final tipoActividad = details.data;
            final cubit = context.read<ItineraryBuilderCubit>();
            // Verificar si la actividad cabe en el tiempo restante
            return cubit.wouldActivityFit(tipoActividad);
          },
          // 2. Cuando el usuario suelta el ítem
          onAcceptWithDetails: (details) {
            final cubit = context.read<ItineraryBuilderCubit>();
            // Guardar cuántas actividades había ANTES del drop
            final cantidadAntes = cubit.state.actividadesDelDiaActual.length;
            cubit.onActivityDropped(details.data);

            // ✨ BONUS: Auto-abrir el dialog de edición al soltar
            // Solo si realmente se agregó una actividad nueva
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final actividadesDespues = cubit.state.actividadesDelDiaActual;
              // Verificar que la lista creció (se agregó una actividad)
              if (actividadesDespues.length <= cantidadAntes) return;
              final ultimaActividad = actividadesDespues.last;
              // Calcular minTime correctamente sincronizado con fecha base del día
              // Calcular minTime y maxTime usando fechas reales del state
              final minTime = cubit.state.horaInicioDia;
              final limiteBase = cubit.state.horaFinDia;

              final esUltimoDia =
                  cubit.state.diaSeleccionadoIndex == cubit.state.totalDias - 1;
              final permiteHorasExtra =
                  cubit.state.modoHorasExtraActivo && !esUltimoDia;

              final maxTime =
                  permiteHorasExtra
                      ? limiteBase.add(const Duration(hours: 3))
                      : limiteBase;

              showDialog(
                // ignore: use_build_context_synchronously
                context: context,
                barrierDismissible: false,
                builder:
                    (ctx) => BlocProvider.value(
                      value: cubit,
                      child: ActivityEditDialog(
                        actividad: ultimaActividad,
                        onSave: (updated) => cubit.updateActivity(updated),
                        onDelete: (id) => cubit.deleteActivity(id),
                        isNew: true,
                        actividadesDelDia: cubit.state.actividadesDelDiaActual,
                        minTime: minTime,
                        maxTime: maxTime,
                      ),
                    ),
              );
            });
          },
          builder: (context, candidateData, rejectedData) {
            final isHovering = candidateData.isNotEmpty;
            final isRejected = rejectedData.isNotEmpty;

            // Construir la lista combinada: continuación nocturna + actividades del día
            final tieneContenido =
                actividadContinuacion != null || actividades.isNotEmpty;

            return Stack(
              children: [
                Container(
                  color:
                      isRejected
                          ? Colors.red.withValues(alpha: 0.06)
                          : isHovering
                          ? Colors.blue.withValues(alpha: 0.05)
                          : Colors.grey[50],
                  child:
                      !tieneContenido
                          ? _buildEmptyState()
                          : ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              // ✨ Tarjeta de continuación nocturna (si existe)
                              if (actividadContinuacion != null) ...[
                                _ContinuationCard(
                                  activity: actividadContinuacion,
                                  diaOrigen: diaAnterior,
                                ),
                                // Conector hacia las actividades propias del día
                                if (actividades.isNotEmpty)
                                  _buildConnectorLine(),
                              ],
                              // Actividades propias del día actual
                              ...List.generate(actividades.length, (index) {
                                return Column(
                                  children: [
                                    _ItineraryItemCard(
                                      activity: actividades[index],
                                      usaHorasExtra:
                                          state.modoHorasExtraActivo &&
                                          actividades[index].horaFin.isAfter(
                                            state.horaFinDia,
                                          ),
                                    ),
                                    if (index < actividades.length - 1)
                                      _buildConnectorLine(),
                                  ],
                                );
                              }),
                            ],
                          ),
                ),
                // Banner de rechazo: aparece al intentar soltar sin tiempo
                if (isRejected)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      color: Colors.red.shade700,
                      child: Builder(
                        builder: (context) {
                          final cubit = context.watch<ItineraryBuilderCubit>();
                          final esUltimoDia =
                              cubit.state.diaSeleccionadoIndex ==
                              cubit.state.totalDias - 1;
                          final esViajeLargo = cubit.state.totalDias > 1;

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.block,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                cubit.state.actividadesUsanHorasNocturnas
                                    ? "Límite: Solo una actividad nocturna por día"
                                    : (esViajeLargo &&
                                        !esUltimoDia &&
                                        !cubit.state.modoHorasExtraActivo)
                                    ? "Sin tiempo — activa las horas extra para continuar"
                                    : "Sin tiempo disponible — límite de horario alcanzado",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
              ],
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
  final bool usaHorasExtra;

  const _ItineraryItemCard({
    required this.activity,
    this.usaHorasExtra = false,
  });

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
                      // ✨ Badge de Horas Extra
                      if (usaHorasExtra)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.indigo.shade200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.nightlight_round,
                                size: 10,
                                color: Colors.indigo.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Horas Extra",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
                  onPressed: () {
                    final cubit = context.read<ItineraryBuilderCubit>();

                    // Calcular límites para validación en edición
                    final minTime = cubit.state.horaInicioDia;
                    final limiteBase = cubit.state.horaFinDia;
                    final esUltimoDia =
                        cubit.state.diaSeleccionadoIndex ==
                        cubit.state.totalDias - 1;
                    final permiteHorasExtra =
                        cubit.state.modoHorasExtraActivo && !esUltimoDia;
                    final maxTime =
                        permiteHorasExtra
                            ? limiteBase.add(const Duration(hours: 3))
                            : limiteBase;

                    showDialog(
                      context: context,
                      builder:
                          (ctx) => BlocProvider.value(
                            value: cubit,
                            child: ActivityEditDialog(
                              actividad: activity,
                              onSave:
                                  (updated) => cubit.updateActivity(updated),
                              onDelete: (id) => cubit.deleteActivity(id),
                              actividadesDelDia:
                                  cubit.state.actividadesDelDiaActual,
                              minTime: minTime,
                              maxTime: maxTime,
                            ),
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
// ✨ TARJETA DE CONTINUACIÓN NOCTURNA
// ============================================
class _ContinuationCard extends StatelessWidget {
  final ActividadItinerario activity;
  final int diaOrigen; // Índice del día donde vive la actividad (0-based)

  const _ContinuationCard({required this.activity, required this.diaOrigen});

  String _formatHora(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final periodo = h >= 12 ? 'PM' : 'AM';
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$h12:$m $periodo';
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

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ItineraryBuilderCubit>();
    final startStr = _formatHora(activity.horaInicio);
    final endStr = _formatHora(activity.horaFin);

    return Container(
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.indigo.shade300,
          width: 1.5,
          // Simular borde punteado con un borde sólido suave
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge superior
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.indigo.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(9),
                topRight: Radius.circular(9),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.nightlight_round,
                  size: 13,
                  color: Colors.indigo.shade700,
                ),
                const SizedBox(width: 6),
                Text(
                  '↩ Continúa del Día ${diaOrigen + 1}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.indigo.shade700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          // Contenido de la tarjeta
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Columna de horas
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      startStr,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.indigo.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      endStr,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.indigo.shade400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                // Punto de timeline
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade400,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
                const SizedBox(width: 10),
                // Contenido de la actividad
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        _getIconForType(activity.tipo),
                        color: Colors.indigo.shade400,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity.titulo,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.indigo.shade900,
                              ),
                            ),
                            if (activity.descripcion.isNotEmpty)
                              Text(
                                activity.descripcion,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.indigo.shade400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      // Botón eliminar con confirmación
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: Colors.indigo.shade300,
                        ),
                        tooltip: 'Eliminar actividad nocturna',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder:
                                (ctx) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  icon: Icon(
                                    Icons.nightlight_round,
                                    color: Colors.indigo.shade400,
                                    size: 36,
                                  ),
                                  title: const Text(
                                    'Eliminar actividad nocturna',
                                  ),
                                  content: Text(
                                    '"${activity.titulo}" fue creada en el Día ${diaOrigen + 1} '
                                    'y continúa hasta las $endStr de este día.\n\n'
                                    '¿Deseas eliminarla completamente?',
                                    textAlign: TextAlign.center,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Cancelar'),
                                    ),
                                    FilledButton(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.indigo,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        cubit.deleteActivityFromDay(
                                          activity.id,
                                          diaOrigen,
                                        );
                                      },
                                      child: const Text('Eliminar'),
                                    ),
                                  ],
                                ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
        // ✨ CASO ESPECIAL: Actividades nocturnas (cruzan medianoche)
        if (state.actividadesUsanHorasNocturnas) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.indigo.shade300, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.nightlight_round,
                      color: Colors.indigo.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Actividad nocturna",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Este día usa horas del día siguiente. El Día ${state.diaSeleccionadoIndex + 2} comenzará más tarde automáticamente.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.indigo.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder:
                          (ctx) => AlertDialog(
                            title: const Row(
                              children: [
                                Icon(
                                  Icons.nightlight_round,
                                  color: Colors.indigo,
                                ),
                                SizedBox(width: 10),
                                Text("Actividades Nocturnas"),
                              ],
                            ),
                            content: const Text(
                              "Para mantener la coherencia del itinerario, solo se permite una actividad nocturna por día (que cruce la medianoche).\n\n"
                              "Si deseas agregar más actividades después de esta, ve al Día siguiente. El sistema ajustará automáticamente la hora de inicio para que coincida con el final de tu actividad nocturna.",
                              style: TextStyle(height: 1.5),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text("Entendido"),
                              ),
                            ],
                          ),
                    );
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.help_outline,
                          size: 16,
                          color: Colors.indigo.shade500,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "¿Por qué solo una actividad?",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.indigo.shade600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final tiempoRestante = state.tiempoRestanteHoy;
        final tiempoUsado = state.tiempoUsadoHoy;
        final tiempoTotal =
            state.horaFinDia.difference(state.horaInicioDia).inMinutes;

        // Proteger contra valores negativos inesperados
        final tiempoRestanteSafe = tiempoRestante.clamp(0, tiempoTotal);
        final tiempoUsadoSafe = tiempoUsado.clamp(0, tiempoTotal);

        final horasRestantes = tiempoRestanteSafe ~/ 60;
        final minutosRestantes = tiempoRestanteSafe % 60;
        final horasUsadas = tiempoUsadoSafe ~/ 60;
        final minutosUsados = tiempoUsadoSafe % 60;

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
        } else if (tiempoRestante > 0) {
          indicatorColor = Colors.red;
          indicatorIcon = Icons.error;
          statusText = "Poco tiempo";
        } else {
          indicatorColor = Colors.red.shade900;
          indicatorIcon = Icons.block;
          statusText = "Sin tiempo disponible";
        }

        // Mostrar botón desde "Tiempo limitado" (≤ 4h) hasta "Sin tiempo"
        // SOLO si el viaje tiene más de 1 día y NO es el último día
        final esUltimoDia = state.diaSeleccionadoIndex >= state.totalDias - 1;
        final sinTiempo = tiempoRestante <= 240 && !esUltimoDia;
        final modoExtra = state.modoHorasExtraActivo;

        // ✨ Calcular minutos extra consumidos (last activity beyond normal limit)
        int minutosExtra = 0;
        if (modoExtra) {
          final actividades = state.actividadesDelDiaActual;
          if (actividades.isNotEmpty) {
            final limiteNormal = state.horaFinDia;
            final ultimaFin = actividades.last.horaFin;
            if (ultimaFin.isAfter(limiteNormal)) {
              minutosExtra = ultimaFin.difference(limiteNormal).inMinutes;
            }
          }
        }
        final horasExtra = minutosExtra ~/ 60;
        final minsExtra = minutosExtra % 60;
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
                  value: tiempoTotal > 0 ? tiempoUsadoSafe / tiempoTotal : 0,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
                  minHeight: 6,
                ),
              ),

              // ✨ BOTÓN HORAS EXTRA: Solo visible cuando no hay tiempo
              if (sinTiempo) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap:
                        () =>
                            context
                                .read<ItineraryBuilderCubit>()
                                .toggleModoHorasExtra(),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color:
                            modoExtra
                                ? Colors.indigo.shade600
                                : Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.indigo.shade400,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                modoExtra
                                    ? Icons.nightlight_round
                                    : Icons.nightlight_outlined,
                                size: 18,
                                color:
                                    modoExtra
                                        ? Colors.white
                                        : Colors.indigo.shade600,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                modoExtra
                                    ? "Horas extra activas"
                                    : "Activar horas extra",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      modoExtra
                                          ? Colors.white
                                          : Colors.indigo.shade700,
                                ),
                              ),
                              if (modoExtra) ...[
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.check_circle,
                                  size: 16,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ],
                            ],
                          ),
                          // ✨ Badge de horas extra consumidas (línea separada)
                          if (modoExtra && minutosExtra > 0) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                horasExtra > 0
                                    ? "+${horasExtra}h ${minsExtra}m en horas extra"
                                    : "+${minsExtra}m en horas extra",
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  modoExtra
                      ? "Margen de +3h habilitado. Puedes programar actividades más allá del cierre normal del día."
                      : "Añade un margen de 3 horas al final del día. Úsalo para extender tu itinerario o conectar con la madrugada siguiente.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.indigo.shade400,
                    height: 1.3,
                  ),
                ),
              ],

              if (tiempoRestante <= 0 && state.totalDias == 1) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "El viaje termina hoy. No se puede extender más el horario.",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
