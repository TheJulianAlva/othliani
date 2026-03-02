import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/itinerary_builder/itinerary_builder_cubit.dart';
import '../../domain/entities/actividad_itinerario.dart'; // Para TipoActividad
import '../../domain/entities/categoria_actividad.dart'; // 🎭 Categorías dinámicas
import '../widgets/itinerary_builder/activity_edit_dialog.dart'; // ✨ Fase 4
import '../widgets/itinerary_builder/new_category_modal.dart'; // 🎭 Modal nueva categoría
import 'package:frontend/core/di/service_locator.dart' as di; // ✨ Fase 5: DI
import '../../domain/repositories/trip_repository.dart'; // ✨ Fase 5
import '../../domain/repositories/categorias_repository.dart'; // 🎭 Clean Arch
import 'itinerary_builder_route_map.dart'; // ✨ Widget del mapa de ruta
import '../../domain/entities/viaje.dart'; // ✨ Import necesario
import 'package:frontend/features/agencia/trips/data/datasources/trip_local_data_source.dart'; // 💾 Import necesario
import 'package:frontend/core/services/unsaved_changes_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import '../../domain/services/itinerary_import_service.dart'; // ✨ Csv Import

// ── Notifier global de drag activo ────────────────────────────────────
// Cuando una actividad empieza a arrastrarse, se pone en true para que
// el panel izquierdo muestre la zona de papálera de forma inmediata.
final _isDraggingActivity = ValueNotifier<bool>(false);

// El catálogo de herramientas ahora viene de ItineraryBuilderState.categorias
// y se construye dinámicamente (defaults + personalizadas de la agencia).

class ItineraryBuilderScreen extends StatelessWidget {
  final Viaje viajeBase; // ✨ AHORA: Recibimos todo el objeto
  final String? csvDataAImportar; // ✨ Datos CSV precargados
  final bool
  reemplazarCsvInicial; // ✨ si true, limpia el borrador antes de importar

  const ItineraryBuilderScreen({
    super.key,
    required this.viajeBase,
    this.csvDataAImportar,
    this.reemplazarCsvInicial = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => ItineraryBuilderCubit(
            repository: di.sl<TripRepository>(),
            localDataSource: di.sl<TripLocalDataSource>(),
            unsavedChangesService: di.sl<UnsavedChangesService>(),
            categoriasRepository: di.sl<CategoriasRepository>(),
            importService: di.sl<ItineraryImportService>(), // ✨ Csv Import
          )..init(
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
            csvDataAImportar: csvDataAImportar,
            reemplazarCsvInicial: reemplazarCsvInicial,
          ),
      child: BlocBuilder<ItineraryBuilderCubit, ItineraryBuilderState>(
        builder: (context, state) {
          // El itinerary builder NO intercepta el back — deja que el
          // DraftGuardWidget del TripCreationScreen maneje eso.
          return Scaffold(
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
                // Botón Importar CSV del día
                Padding(
                  padding: const EdgeInsets.only(right: 4, top: 8, bottom: 8),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.upload_file, size: 18),
                    label: const Text('CSV'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue[800],
                      side: BorderSide(color: Colors.blue[300]!),
                    ),
                    onPressed: () async {
                      final cubit = context.read<ItineraryBuilderCubit>();
                      final estadoActual = cubit.state;
                      bool reemplazar = false;

                      // ── Paso 1: Si hay actividades → pregunta si quiere reemplazar
                      if (estadoActual.hayAlgunaActividad) {
                        if (!context.mounted) return;
                        final decision = await showDialog<String>(
                          context: context,
                          builder:
                              (ctx) => AlertDialog(
                                icon: const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.orange,
                                  size: 44,
                                ),
                                title: const Text('Ya existe un itinerario'),
                                content: const Text(
                                  'El constructor ya tiene actividades guardadas.\n\n'
                                  '¿Qué deseas hacer con el nuevo CSV?',
                                  textAlign: TextAlign.center,
                                ),
                                actionsAlignment: MainAxisAlignment.spaceEvenly,
                                actions: [
                                  TextButton.icon(
                                    icon: const Icon(Icons.close),
                                    label: const Text('Cancelar'),
                                    onPressed:
                                        () => Navigator.of(ctx).pop('cancelar'),
                                  ),
                                  OutlinedButton.icon(
                                    icon: const Icon(Icons.playlist_add),
                                    label: const Text('Agregar'),
                                    onPressed:
                                        () => Navigator.of(ctx).pop('agregar'),
                                  ),
                                  FilledButton.icon(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.orange[700],
                                    ),
                                    icon: const Icon(Icons.swap_horiz),
                                    label: const Text('Reemplazar'),
                                    onPressed:
                                        () =>
                                            Navigator.of(ctx).pop('reemplazar'),
                                  ),
                                ],
                              ),
                        );
                        if (decision == null || decision == 'cancelar') return;
                        reemplazar = decision == 'reemplazar';
                      }

                      // ── Paso 2: Diálogo instructivo de formato
                      if (!context.mounted) return;
                      final resultado = await showDialog<bool>(
                        context: context,
                        builder:
                            (ctx) => AlertDialog(
                              icon: Icon(
                                Icons.description_outlined,
                                color: Colors.blue[800],
                                size: 40,
                              ),
                              title: const Text(
                                'Importar Viaje Completo (CSV)',
                              ),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'El archivo CSV debe tener esta estructura:',
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                      child: const Text(
                                        'Día,Hora_Inicio,Hora_Fin,Título,Descripción,Tipo\n'
                                        '1,08:00,09:00,Check-in,Registro en hotel,hospedaje\n'
                                        '1,09:00,10:00,Desayuno,Restaurante Centro,comida\n'
                                        '2,10:30,13:00,Tour Histórico,Visita guiada,cultura',
                                        style: TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Tipos válidos: hospedaje, alimentos, traslado, cultura, aventura, tiempoLibre',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Formato de hora: HH:mm (24 horas)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.folder_open),
                                  label: const Text('Seleccionar CSV'),
                                  onPressed: () => Navigator.pop(ctx, true),
                                ),
                              ],
                            ),
                      );
                      if (resultado != true) return;
                      if (!context.mounted) return;

                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['csv'],
                        withData: true,
                      );
                      if (result != null && result.files.single.bytes != null) {
                        final csvContent = utf8.decode(
                          result.files.single.bytes!,
                        );
                        if (!context.mounted) return;
                        cubit.procesarCsvImportado(
                          csvContent,
                          reemplazar: reemplazar,
                        );
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: BlocBuilder<
                    ItineraryBuilderCubit,
                    ItineraryBuilderState
                  >(
                    builder: (context, state) {
                      final podemos = state.puedeGuardar;
                      return Tooltip(
                        message:
                            !podemos && !state.isSaving
                                ? (state.hayAlgunaActividad
                                    ? 'Configura el horario de todas las actividades'
                                    : 'Agrega al menos una actividad')
                                : '',
                        child: ElevatedButton.icon(
                          onPressed:
                              state.isSaving || !podemos
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
                                  : state.hayActividadesSinHorario
                                  ? const Icon(
                                    Icons.schedule,
                                    color: Colors.orange,
                                  )
                                  : const Icon(Icons.save),
                          label: Text(
                            state.isSaving
                                ? "Guardando..."
                                : "Finalizar Itinerario",
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[800],
                            foregroundColor: Colors.white,
                          ),
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
          );
        },
      ),
    );
  }
}

class _BodyContent extends StatefulWidget {
  const _BodyContent();

  @override
  State<_BodyContent> createState() => _BodyContentState();
}

class _BodyContentState extends State<_BodyContent> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ---------------------------------------------
        // PANEL IZQUIERDO: CAJA DE HERRAMIENTAS (20%)
        // ---------------------------------------------
        Expanded(
          flex: 2,
          child: Stack(
            children: [
              // ── CONTENIDO NORMAL DEL PANEL ─────────────────────────────
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bloques de Actividad',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Arrastra al itinerario',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: BlocBuilder<
                        ItineraryBuilderCubit,
                        ItineraryBuilderState
                      >(
                        buildWhen:
                            (prev, curr) => prev.categorias != curr.categorias,
                        builder: (context, state) {
                          return ListView.builder(
                            itemCount: state.categorias.length + 1,
                            itemBuilder: (context, index) {
                              if (index == state.categorias.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: OutlinedButton.icon(
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                      size: 18,
                                    ),
                                    label: const Text('Nueva Actividad'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF1B263B),
                                      side: const BorderSide(
                                        color: Color(0xFF1B263B),
                                        style: BorderStyle.solid,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () async {
                                      final nueva = await showModalBottomSheet<
                                        CategoriaActividad
                                      >(
                                        context: context,
                                        isScrollControlled: true,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20),
                                          ),
                                        ),
                                        builder:
                                            (_) => const NewCategoryModal(),
                                      );
                                      if (nueva != null && context.mounted) {
                                        context
                                            .read<ItineraryBuilderCubit>()
                                            .agregarCategoriaPersonalizada(
                                              nueva,
                                            );
                                      }
                                    },
                                  ),
                                );
                              }
                              return _buildDraggableToolItem(
                                categoria: state.categorias[index],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // ── DRAG TARGET OVERLAY — CUBRE TODO EL PANEL ──────────────
              Positioned.fill(
                child: DragTarget<ActividadItinerario>(
                  onWillAcceptWithDetails: (_) => true,
                  onLeave: (_) {},
                  onAcceptWithDetails: (details) async {
                    final act = details.data;
                    if (!context.mounted) return;
                    final cubit = context.read<ItineraryBuilderCubit>();
                    final confirmar = await showDialog<bool>(
                      context: context,
                      builder:
                          (ctx) => AlertDialog(
                            icon: const Icon(
                              Icons.delete_forever_rounded,
                              color: Colors.red,
                              size: 44,
                            ),
                            title: const Text('¿Eliminar actividad?'),
                            content: Text(
                              '¿Estás seguro de que deseas eliminar '
                              '"${act.titulo.isNotEmpty ? act.titulo : 'esta actividad'}"?\n\n'
                              'Esta acción no se puede deshacer.',
                              textAlign: TextAlign.center,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Cancelar'),
                              ),
                              FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.red[700],
                                ),
                                icon: const Icon(Icons.delete_forever),
                                label: const Text('Sí, eliminar'),
                                onPressed: () => Navigator.of(ctx).pop(true),
                              ),
                            ],
                          ),
                    );
                    if (confirmar == true) {
                      cubit.deleteActivityFromDay(
                        act.id,
                        cubit.state.diaSeleccionadoIndex,
                      );
                    }
                  },
                  builder: (context, candidateData, _) {
                    final hovering = candidateData.isNotEmpty;
                    return ValueListenableBuilder<bool>(
                      valueListenable: _isDraggingActivity,
                      builder: (ctx, isDragging, _) {
                        // Mostrar overlay rojo completo si hay drag activo
                        // (desde que empieza) o si el cursor ya está encima
                        if (!hovering && !isDragging) {
                          return IgnorePointer(
                            child: ColoredBox(
                              color: Colors.transparent,
                              child: const SizedBox.expand(),
                            ),
                          );
                        }
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(
                              alpha: hovering ? 0.20 : 0.10,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color:
                                        hovering
                                            ? Colors.red[600]
                                            : Colors.red[400],
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.delete_forever_rounded,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  hovering
                                      ? '¡Suelta para eliminar!'
                                      : 'Arrastra aquí para eliminar',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        hovering ? Colors.red : Colors.red[300],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
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
              const _DayImportHeader(), // 📥 Banner de importación por día
              Expanded(child: const _TimelineDropZone()),
            ],
          ),
        ),

        const VerticalDivider(width: 1, thickness: 1),

        // ---------------------------------------------
        // PANEL DERECHO: MAPA + STATS (30%)
        // ---------------------------------------------
        Expanded(
          flex: 3,
          child: Column(
            children: [
              // Mapa
              Expanded(flex: 1, child: const DayRouteMap()),
              const Divider(height: 1),
              // Panel de estadísticas
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
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

  Widget _buildDraggableToolItem({required CategoriaActividad categoria}) {
    final color = Color(
      int.parse(categoria.colorHex.replaceFirst('#', '0xFF')),
    );

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
            child: Text(categoria.emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoria.nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '${categoria.duracionDefaultMinutos} min',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          const Icon(Icons.drag_indicator, color: Colors.grey, size: 16),
        ],
      ),
    );

    return Draggable<CategoriaActividad>(
      data: categoria,
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
// ENCABEZADO DEL DÍA CON BOTÓN DE IMPORTACIÓN
// ============================================
class _DayImportHeader extends StatelessWidget {
  const _DayImportHeader();

  /// Construye la etiqueta del día activo (ej: "Vie 27 Feb" o "Día 3")
  String _labelDia(ItineraryBuilderState state) {
    final idx = state.diaSeleccionadoIndex;
    final fechaInicio = state.horaInicioViaje;
    if (fechaInicio != null) {
      final fecha = fechaInicio.add(Duration(days: idx));
      const diasSemana = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
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
      return '${diasSemana[fecha.weekday - 1]} ${fecha.day} ${meses[fecha.month - 1]}';
    }
    return 'Día ${idx + 1}';
  }

  Future<void> _onImportPressed(
    BuildContext context,
    ItineraryBuilderState state,
  ) async {
    final cubit = context.read<ItineraryBuilderCubit>();
    // ✅ Siempre leemos del cubit directamente para evitar estado "stale"
    //    del BlocBuilder (que solo reconstruye en diaSeleccionadoIndex / isImporting)
    final estadoFresco = cubit.state;
    final diaIndex = estadoFresco.diaSeleccionadoIndex;
    final actividadesActuales = estadoFresco.actividadesPorDia[diaIndex] ?? [];
    bool reemplazar = false;

    if (actividadesActuales.isNotEmpty) {
      // ─── El día YA tiene actividades → pregunta si quiere reemplazar ────
      final cantidad = actividadesActuales.length;
      final labelDia = _labelDia(state);
      if (!context.mounted) return;
      final confirmar = await showDialog<bool>(
        context: context,
        builder:
            (ctx) => AlertDialog(
              icon: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 42,
              ),
              title: Text('¿Reemplazar actividades del $labelDia?'),
              content: Text(
                'El $labelDia ya tiene $cantidad actividad${cantidad == 1 ? '' : 'es'} '
                'en su itinerario.\n\n'
                '¿Deseas reemplazarlas con las del nuevo archivo CSV?',
                textAlign: TextAlign.center,
              ),
              actionsAlignment: MainAxisAlignment.spaceEvenly,
              actions: [
                TextButton.icon(
                  icon: const Icon(Icons.close),
                  label: const Text('Cancelar'),
                  onPressed: () => Navigator.of(ctx).pop(false),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.orange[700],
                  ),
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Sí, reemplazar'),
                  onPressed: () => Navigator.of(ctx).pop(true),
                ),
              ],
            ),
      );
      if (confirmar != true) return;
      reemplazar = true;
    } else {
      // ─── El día está VACÍO → muestra instrucciones de formato CSV ───────
      if (!context.mounted) return;
      final labelDia = _labelDia(state);
      final proceder = await showDialog<bool>(
        context: context,
        builder:
            (ctx) => AlertDialog(
              icon: Icon(
                Icons.upload_file_outlined,
                color: Colors.blue[700],
                size: 44,
              ),
              title: Text('Importar CSV al $labelDia'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'El archivo CSV para un día no necesita la columna "Día". '
                      'Todas las filas se cargarán en este día automáticamente.',
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Text(
                        'Inicio,Termino,Actividad,Categoria,Detalles\n'
                        '08:00,09:00,Desayuno en la cabaña,Comida,Huevos y cafe\n'
                        '09:30,13:30,Rafting en los rápidos,Aventura,Nivel intermedio\n'
                        '14:00,,Comida a la orilla del rio,Comida,',
                        style: TextStyle(fontFamily: 'monospace', fontSize: 11),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '💡 Si falta la hora de término, el sistema calculará +1h automáticamente y marcará la actividad con ⚠️.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Seleccionar CSV'),
                  onPressed: () => Navigator.of(ctx).pop(true),
                ),
              ],
            ),
      );
      if (proceder != true) return;
    }

    // ─── Abrir selector de archivo ────────────────────────────────────────
    if (!context.mounted) return;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );
    if (result == null || result.files.single.bytes == null) return;
    final csvContent = utf8.decode(result.files.single.bytes!);
    if (!context.mounted) return;

    cubit.procesarCsvPorDia(csvContent, diaIndex, reemplazar: reemplazar);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItineraryBuilderCubit, ItineraryBuilderState>(
      buildWhen:
          (prev, curr) =>
              prev.diaSeleccionadoIndex != curr.diaSeleccionadoIndex ||
              prev.isImporting != curr.isImporting,
      builder: (context, state) {
        final labelDia = _labelDia(state);
        return Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Row(
            children: [
              // Ícono de calendario
              Icon(
                Icons.calendar_today_outlined,
                size: 15,
                color: Colors.grey[500],
              ),
              const SizedBox(width: 6),
              Text(
                labelDia,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const Spacer(),
              // ─── BOTÓN IMPORTAR CSV A ESTE DÍA ─────────────────────────
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue[700],
                  side: BorderSide(color: Colors.blue[300]!),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 0,
                  ),
                  minimumSize: const Size(0, 32),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon:
                    state.isImporting
                        ? SizedBox(
                          width: 13,
                          height: 13,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.blue[700],
                          ),
                        )
                        : const Icon(Icons.upload_file_outlined, size: 15),
                label: Text(
                  state.isImporting
                      ? 'Importando...'
                      : 'Importar CSV a este día',
                ),
                onPressed:
                    state.isImporting
                        ? null
                        : () => _onImportPressed(context, state),
              ),
            ],
          ),
        );
      },
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

  /// Construye la etiqueta de cada pestaña de día.
  /// Si [fechaInicio] está disponible, muestra la fecha real en 2 líneas
  /// (ej: "Sáb" y "28 Feb"). Si no, hace fallback a "Día N".
  Widget _buildDayLabel({
    required int index,
    required DateTime? fechaInicio,
    required bool isSelected,
  }) {
    final color = isSelected ? Colors.white : Colors.grey[700]!;
    if (fechaInicio != null) {
      final fecha = fechaInicio.add(Duration(days: index));
      const diasSemana = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
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
      final diaSemana = diasSemana[fecha.weekday - 1];
      final mes = meses[fecha.month - 1];
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            diaSemana,
            style: TextStyle(
              color: color.withValues(alpha: 0.85),
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
          Text(
            '${fecha.day} $mes',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      );
    }
    // Fallback: sin fecha de inicio
    return Text(
      'Día ${index + 1}',
      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
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
                    vertical: 6,
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
                          child: _buildDayLabel(
                            index: index,
                            fechaInicio: state.horaInicioViaje,
                            isSelected: isSelected,
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
class _TimelineDropZone extends StatefulWidget {
  const _TimelineDropZone();

  @override
  State<_TimelineDropZone> createState() => _TimelineDropZoneState();
}

class _TimelineDropZoneState extends State<_TimelineDropZone> {
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startScrolling(double speed) {
    _scrollTimer?.cancel();
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!_scrollController.hasClients) return;
      final offset = (_scrollController.offset + speed).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
      _scrollController.jumpTo(offset);
    });
  }

  void _stopScrolling() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItineraryBuilderCubit, ItineraryBuilderState>(
      builder: (context, state) {
        // Ordenar actividades por horaInicio (las sin horario al final)
        final todasLasActividades = List<ActividadItinerario>.from(
          state.actividadesDelDiaActual,
        );
        final conHorario =
            todasLasActividades
                .where((a) => !state.actividadSinHorario(a))
                .toList()
              ..sort((a, b) => a.horaInicio.compareTo(b.horaInicio));
        final sinHorario =
            todasLasActividades
                .where((a) => state.actividadSinHorario(a))
                .toList();

        // Lista combinada para el timeline: sin horario al inicio (prioridad), luego con horario
        final actividades = [...sinHorario, ...conHorario];

        return DragTarget<CategoriaActividad>(
          // Siempre acepta — las restricciones de tiempo ya no aplican
          onWillAcceptWithDetails: (_) => true,
          onAcceptWithDetails: (details) {
            final cubit = context.read<ItineraryBuilderCubit>();
            final cantidadAntes = cubit.state.actividadesDelDiaActual.length;
            cubit.onActivityDropped(details.data);

            // Auto-abrir el dialog de edición al soltar
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final actividadesDespues = cubit.state.actividadesDelDiaActual;
              if (actividadesDespues.length <= cantidadAntes) return;
              final ultimaActividad = actividadesDespues.last;

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
                      ),
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
                      : Stack(
                        children: [
                          // ─── Contenido con scroll ───────────────────────
                          SingleChildScrollView(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _buildTimelineItems(
                                context,
                                conHorario,
                                sinHorario,
                                state.fechaBaseDiaActual,
                              ),
                            ),
                          ),
                          // ─── Zona auto-scroll superior ────────────────
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: 60,
                            child: DragTarget<ActividadItinerario>(
                              onWillAcceptWithDetails: (d) {
                                _startScrolling(-8);
                                return false; // no consume el drop
                              },
                              onLeave: (_) => _stopScrolling(),
                              builder: (_, __, ___) => const SizedBox.expand(),
                            ),
                          ),
                          // ─── Zona auto-scroll inferior ────────────────
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 60,
                            child: DragTarget<ActividadItinerario>(
                              onWillAcceptWithDetails: (d) {
                                _startScrolling(8);
                                return false; // no consume el drop
                              },
                              onLeave: (_) => _stopScrolling(),
                              builder: (_, __, ___) => const SizedBox.expand(),
                            ),
                          ),
                        ],
                      ),
            );
          },
        );
      },
    );
  }

  /// Construye la lista de items del timeline intercalando bloques
  /// de Tiempo Libre cuando hay huecos entre actividades con horario.
  /// [diaBase] es las 00:00 h del día actual — se usa para mostrar
  /// tiempo libre antes de la primera actividad.
  List<Widget> _buildTimelineItems(
    BuildContext context,
    List<ActividadItinerario> conHorario,
    List<ActividadItinerario> sinHorario,
    DateTime diaBase,
  ) {
    final widgets = <Widget>[];
    final cubit = context.read<ItineraryBuilderCubit>();
    final state = cubit.state;

    // ─── SECCIÓN SIN HORARIO (al inicio) ────────────────────────────────────
    if (sinHorario.isNotEmpty) {
      // El encabezado + lista se envuelven en DragTarget para recibir
      // actividades con-horario que quieran perder su horario.
      widgets.add(
        DragTarget<ActividadItinerario>(
          onWillAcceptWithDetails:
              (details) =>
                  !state.actividadSinHorario(details.data) &&
                  details.data.tipo != TipoActividad.tiempoLibre,
          onAcceptWithDetails: (details) {
            final act = details.data;
            showDialog<bool>(
              context: context,
              builder:
                  (dlgCtx) => AlertDialog(
                    title: const Text('¿Quitar horario?'),
                    content: Text(
                      '¿Deseas quitarle el horario a "${act.titulo.isNotEmpty ? act.titulo : 'esta actividad'}"?\n'
                      'Pasará a la lista de actividades pendientes.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dlgCtx).pop(false),
                        child: const Text('Cancelar'),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.of(dlgCtx).pop(true);
                          cubit.quitarHorario(act.id);
                        },
                        child: const Text('Sí, quitar horario'),
                      ),
                    ],
                  ),
            );
          },
          builder: (context, candidateData, _) {
            final isTarget = candidateData.isNotEmpty;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border:
                    isTarget
                        ? Border.all(color: Colors.orange.shade300, width: 2)
                        : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Separador de sección sin horario
                  _buildSectionDivider('Sin Horario', color: Colors.red[400]),
                  const SizedBox(height: 4),
                  // Tarjetas sin-horario: LongPressDraggable + DragTarget
                  ...sinHorario.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final act = entry.value;
                    return Column(
                      key: ValueKey(act.id),
                      children: [
                        if (idx > 0) _buildConnectorLine(),
                        Draggable<ActividadItinerario>(
                          data: act,
                          onDragStarted: () => _isDraggingActivity.value = true,
                          onDragEnd: (_) => _isDraggingActivity.value = false,
                          onDraggableCanceled:
                              (_, __) => _isDraggingActivity.value = false,
                          onDragCompleted:
                              () => _isDraggingActivity.value = false,
                          feedback: Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 420,
                              child: Opacity(
                                opacity: 0.9,
                                child: _ItineraryItemCard(activity: act),
                              ),
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.3,
                            child: _ItineraryItemCard(activity: act),
                          ),
                          child: DragTarget<ActividadItinerario>(
                            // Acepta otras sin-horario para reordenar
                            onWillAcceptWithDetails:
                                (details) =>
                                    state.actividadSinHorario(details.data) &&
                                    details.data.id != act.id,
                            onAcceptWithDetails: (details) {
                              cubit.reordenarSinHorarioPorId(
                                details.data.id,
                                act.id,
                              );
                            },
                            builder: (context, candidateData, _) {
                              final hovering = candidateData.isNotEmpty;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      hovering
                                          ? Border.all(
                                            color: Colors.blue.shade300,
                                            width: 2,
                                          )
                                          : null,
                                ),
                                child: _ItineraryItemCard(activity: act),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            );
          },
        ),
      );

      // Separador antes de las actividades con horario
      if (conHorario.isNotEmpty) {
        widgets.add(_buildConnectorLine());
        widgets.add(_buildSectionDivider('Actividades del Día'));
        widgets.add(_buildConnectorLine());
      }
    }

    // ─── SECCIÓN CON HORARIO ─────────────────────────────────────────────────
    if (conHorario.isNotEmpty) {
      // Tiempo libre antes de la primera actividad
      final gapInicio =
          conHorario.first.horaInicio.difference(diaBase).inMinutes;
      if (gapInicio > 0) {
        widgets.add(_FreeTimeBlock(duracionMinutos: gapInicio));
        widgets.add(_buildConnectorLine());
      }

      for (int i = 0; i < conHorario.length; i++) {
        final act = conHorario[i];
        final esTiempoLibre = act.tipo == TipoActividad.tiempoLibre;

        // Las actividades con-horario (no TL) son LongPressDraggable
        // y DragTarget para recibir sin-horario (swap)
        final cardWidget =
            esTiempoLibre
                ? _ItineraryItemCard(activity: act) // TL no es draggable
                : DragTarget<ActividadItinerario>(
                  onWillAcceptWithDetails:
                      (details) => state.actividadSinHorario(details.data),
                  onAcceptWithDetails: (details) {
                    final sinAct = details.data;
                    showDialog<bool>(
                      context: context,
                      builder:
                          (dlgCtx) => AlertDialog(
                            title: const Text('¿Intercambiar horario?'),
                            content: Text(
                              '¿Deseas asignarle el horario de '
                              '"${act.titulo.isNotEmpty ? act.titulo : 'esta actividad'}" '
                              'a "${sinAct.titulo.isNotEmpty ? sinAct.titulo : 'la actividad sin horario'}"?\n\n'
                              'La actividad que tenía el horario pasará a pendientes.',
                            ),
                            actions: [
                              TextButton(
                                onPressed:
                                    () => Navigator.of(dlgCtx).pop(false),
                                child: const Text('Cancelar'),
                              ),
                              FilledButton(
                                onPressed: () {
                                  Navigator.of(dlgCtx).pop(true);
                                  cubit.intercambiarHorario(sinAct.id, act.id);
                                },
                                child: const Text('Sí, intercambiar'),
                              ),
                            ],
                          ),
                    );
                  },
                  builder: (context, candidateData, _) {
                    final hovering = candidateData.isNotEmpty;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border:
                            hovering
                                ? Border.all(
                                  color: Colors.green.shade400,
                                  width: 2,
                                )
                                : null,
                      ),
                      child: Draggable<ActividadItinerario>(
                        data: act,
                        onDragStarted: () => _isDraggingActivity.value = true,
                        onDragEnd: (_) => _isDraggingActivity.value = false,
                        onDraggableCanceled:
                            (_, __) => _isDraggingActivity.value = false,
                        onDragCompleted:
                            () => _isDraggingActivity.value = false,
                        feedback: Material(
                          elevation: 8,
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 420,
                            child: Opacity(
                              opacity: 0.9,
                              child: _ItineraryItemCard(activity: act),
                            ),
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: _ItineraryItemCard(activity: act),
                        ),
                        child: _ItineraryItemCard(activity: act),
                      ),
                    );
                  },
                );

        widgets.add(cardWidget);

        if (i < conHorario.length - 1) {
          final siguiente = conHorario[i + 1];
          final gapMinutos =
              siguiente.horaInicio.difference(act.horaFin).inMinutes;
          if (gapMinutos > 0) {
            widgets.add(_buildConnectorLine());
            widgets.add(_FreeTimeBlock(duracionMinutos: gapMinutos));
            widgets.add(_buildConnectorLine());
          } else {
            widgets.add(_buildConnectorLine());
          }
        }
      }
    }

    return widgets;
  }

  Widget _buildSectionDivider(String label, {Color? color}) {
    final c = color ?? Colors.blue[400]!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: Divider(color: c.withValues(alpha: 0.5), thickness: 1),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: c,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Divider(color: c.withValues(alpha: 0.5), thickness: 1),
          ),
        ],
      ),
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

  // Una actividad "sin horario" tiene horaInicio == horaFin
  bool get _sinHorario =>
      activity.horaInicio.isAtSameMomentAs(activity.horaFin);

  @override
  Widget build(BuildContext context) {
    final start =
        "${activity.horaInicio.hour.toString().padLeft(2, '0')}:${activity.horaInicio.minute.toString().padLeft(2, '0')}";
    final end =
        "${activity.horaFin.hour.toString().padLeft(2, '0')}:${activity.horaFin.minute.toString().padLeft(2, '0')}";

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna de hora (o indicador sin horario)
        SizedBox(
          width: 54,
          child:
              _sinHorario
                  ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.schedule,
                        color: Colors.red.shade600,
                        size: 22,
                      ),
                    ],
                  )
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        start,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        end,
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      ),
                    ],
                  ),
        ),
        const SizedBox(width: 12),
        // Punto en la línea de tiempo (más pequeño para sin-horario)
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _sinHorario ? Colors.red.shade300 : Colors.blue[800],
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
              border:
                  _sinHorario
                      ? Border.all(color: Colors.red.shade200, width: 1)
                      : null,
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
                        activity.titulo.isEmpty
                            ? (activity.categoriaSnapshot?.nombre ??
                                'Actividad')
                            : activity.titulo,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              activity.titulo.isEmpty ? Colors.grey[500] : null,
                          fontStyle:
                              activity.titulo.isEmpty
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                        ),
                      ),
                      if (_sinHorario)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            "Toca ✏️ para configurar el horario",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.red.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      else if (activity.descripcion.isNotEmpty)
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
                  icon: Icon(
                    Icons.edit,
                    size: 18,
                    color: _sinHorario ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    final cubit = context.read<ItineraryBuilderCubit>();
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
// BLOQUE DE TIEMPO LIBRE
// ============================================
class _FreeTimeBlock extends StatelessWidget {
  final int duracionMinutos;

  const _FreeTimeBlock({required this.duracionMinutos});

  String get _label {
    if (duracionMinutos < 60) return '$duracionMinutos min';
    final h = duracionMinutos ~/ 60;
    final m = duracionMinutos % 60;
    return m == 0 ? '$h h' : '$h h $m min';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 54,
          child: Center(
            child: Icon(
              Icons.hourglass_bottom,
              size: 14,
              color: Colors.teal[300],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.teal[200],
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.teal.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.beach_access_outlined,
                  color: Colors.teal[600],
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tiempo Libre',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.teal[700],
                        ),
                      ),
                      Text(
                        'Cada quien decide que hacer',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.teal[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
