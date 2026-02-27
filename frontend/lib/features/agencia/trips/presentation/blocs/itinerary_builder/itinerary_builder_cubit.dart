import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart'; // Para TimeOfDay
import 'package:frontend/features/agencia/trips/domain/entities/actividad_itinerario.dart';
import 'package:frontend/features/agencia/trips/domain/entities/viaje.dart'; // ✨ Import necesario
import 'package:frontend/features/agencia/trips/domain/repositories/trip_repository.dart';

import 'package:frontend/features/agencia/trips/data/datasources/trip_local_data_source.dart'; // 💾 Persistencia
import 'package:frontend/features/agencia/trips/data/models/trip_draft_model.dart'; // 💾 Modelo
import 'package:frontend/core/services/unsaved_changes_service.dart';
import 'package:frontend/features/agencia/trips/domain/entities/categoria_actividad.dart';
import 'package:frontend/features/agencia/trips/domain/repositories/categorias_repository.dart';
import 'package:frontend/features/agencia/trips/data/datasources/csv_itinerary_parser.dart';
import 'package:frontend/features/agencia/trips/domain/services/itinerary_import_service.dart'; // ✨ Nueva dependencia
part 'itinerary_builder_state.dart';

class ItineraryBuilderCubit extends Cubit<ItineraryBuilderState> {
  final TripRepository _repository;
  final TripLocalDataSource _localDataSource;
  final UnsavedChangesService _unsavedChangesService;
  final CategoriasRepository _categoriasRepository;
  final ItineraryImportService _importService; // ✨ Nueva dependencia
  Timer? _debounce;

  /// ID de agencia — placeholder hasta que llegue auth (se usa para el repositorio).
  static const String _agenciaId = 'agencia_default';

  ItineraryBuilderCubit({
    required TripRepository repository,
    required TripLocalDataSource localDataSource,
    required UnsavedChangesService unsavedChangesService,
    required CategoriasRepository categoriasRepository,
    required ItineraryImportService importService, // Inyectarlo
  }) : _repository = repository,
       _localDataSource = localDataSource,
       _unsavedChangesService = unsavedChangesService,
       _categoriasRepository = categoriasRepository,
       _importService = importService,
       super(ItineraryBuilderState());

  // --- AUTOGUARDADO ---
  void _autoSave() {
    // Aplanamos todas las actividades
    List<ActividadItinerario> todas = [];
    state.actividadesPorDia.forEach((_, lista) => todas.addAll(lista));

    // Recuperamos draft existente para mantener TODOS los datos del Paso 1
    _localDataSource.getDraft().then((currentDraft) {
      if (currentDraft != null) {
        final updatedDraft = TripDraftModel(
          // ─── Datos Paso 1 (preservar todos) ───────────────────────────
          claveBase:
              currentDraft.claveBase, // 🔑 IMPORTANTE: preservar la clave
          destino: currentDraft.destino,
          fechaInicio: currentDraft.fechaInicio,
          fechaFin: currentDraft.fechaFin,
          isMultiDay: currentDraft.isMultiDay,
          guiaId: currentDraft.guiaId,
          coGuiasIds: currentDraft.coGuiasIds,
          fotoPortadaUrl: currentDraft.fotoPortadaUrl,
          lat: currentDraft.lat,
          lng: currentDraft.lng,
          // ─── Paso 2: Actualizamos solo las actividades ──────────────
          actividades: todas,
        );
        _localDataSource.saveDraft(updatedDraft);
      }
    });
    _unsavedChangesService.setDirty(true); // 📝 Trabajo en progreso
  }

  // Inicializar con la duración del viaje y fechas reales,
  // y restaurar actividades guardadas en el borrador
  Future<void> init(
    int duracionDias, {
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? csvDataAImportar,
  }) async {
    emit(
      state.copyWith(
        totalDias: duracionDias,
        horaInicioViaje: fechaInicio,
        horaFinViaje: fechaFin,
      ),
    );

    // Si vienen datos del CSV desde la pantalla pre-builder, cargarlos directamente
    if (csvDataAImportar != null && csvDataAImportar.isNotEmpty) {
      await procesarCsvImportado(csvDataAImportar);
      return;
    }

    // 💾 Restaurar actividades del borrador guardadas en disco
    final existingDraft = await _localDataSource.getDraft();
    if (existingDraft != null && existingDraft.actividades.isNotEmpty) {
      final actividadesPorDia = <int, List<ActividadItinerario>>{};

      for (final actividad in existingDraft.actividades) {
        int dia = 0;
        if (fechaInicio != null) {
          final fechaBase = DateTime(
            fechaInicio.year,
            fechaInicio.month,
            fechaInicio.day,
          );
          final fechaAct = DateTime(
            actividad.horaInicio.year,
            actividad.horaInicio.month,
            actividad.horaInicio.day,
          );
          dia = fechaAct
              .difference(fechaBase)
              .inDays
              .clamp(0, duracionDias - 1);
        }
        actividadesPorDia.putIfAbsent(dia, () => []).add(actividad);
      }

      // Ordenar cada día cronológicamente
      for (final key in actividadesPorDia.keys) {
        actividadesPorDia[key]!.sort(
          (a, b) => a.horaInicio.compareTo(b.horaInicio),
        );
      }

      if (!isClosed) {
        emit(state.copyWith(actividadesPorDia: actividadesPorDia));
      }
    } // fin if existingDraft

    // 🎭 Cargar categorías desde el Repositorio
    try {
      final categorias = await _categoriasRepository.obtenerCategorias(
        _agenciaId,
      );
      if (!isClosed) {
        emit(state.copyWith(categorias: categorias));
      }
    } catch (_) {
      // Si falla el datasource, usamos los defaults quemados como fallback
    }
  } // fin init()

  // 🎭 Agregar una categoría personalizada creada por la agencia
  Future<void> agregarCategoriaPersonalizada(CategoriaActividad nueva) async {
    final todasLasCategorias = [...state.categorias, nueva];
    emit(state.copyWith(categorias: todasLasCategorias));
    await _categoriasRepository.guardarCategoriaPersonalizada(
      _agenciaId,
      nueva,
    );
    final frescas = await _categoriasRepository.obtenerCategorias(_agenciaId);
    if (!isClosed) emit(state.copyWith(categorias: frescas));
  }

  void cambiarDia(int index) {
    if (index >= 0 && index < state.totalDias) {
      emit(state.copyWith(diaSeleccionadoIndex: index));
    }
  }

  // ✨ Búsqueda de fotos al escribir el título (debounce 800ms)
  void onTituloChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (query.trim().length <= 3) {
      emit(state.copyWith(imagenesSugeridas: []));
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 800), () async {
      final fotos = await _repository.buscarFotosDestino(query.trim());
      emit(state.copyWith(imagenesSugeridas: fotos));
    });
  }

  // ✨ Limpiar sugerencias al cerrar el modal de actividad
  void clearSuggestions() {
    _debounce?.cancel();
    emit(state.copyWith(imagenesSugeridas: []));
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }

  // Método para recibir el Drop de una actividad
  // La actividad se crea SIN horario (horaInicio == horaFin = medianoche del día)
  // El usuario configurará el horario en el diálogo de edición.
  void onActivityDropped(CategoriaActividad categoria) {
    final int dia = state.diaSeleccionadoIndex;
    final List<ActividadItinerario> listaActual = List.from(
      state.actividadesDelDiaActual,
    );

    final fechaBaseDelDia = state.fechaBaseDiaActual;

    // ✨ NUEVA LÓGICA: Siempre crear la actividad SIN horario
    // La actividad se coloca en la sección "Sin Horario" para que el usuario
    // la acomode con el lapicito después de haber agregado todas las actividades.
    // horaInicio == horaFin (duración = 0) es la señal de "sin horario" en el estado.
    final sinHorario = DateTime(
      fechaBaseDelDia.year,
      fechaBaseDelDia.month,
      fechaBaseDelDia.day,
    );

    final nuevaActividad = ActividadItinerario(
      id: const Uuid().v4(),
      titulo: '',
      descripcion: '',
      horaInicio: sinHorario,
      horaFin: sinHorario, // Igual al inicio => "sin horario"
      tipo: categoria.toTipoActividad(),
      categoriaSnapshot: categoria,
    );

    listaActual.add(nuevaActividad);

    final nuevoMapa = Map<int, List<ActividadItinerario>>.from(
      state.actividadesPorDia,
    );
    nuevoMapa[dia] = listaActual;

    emit(state.copyWith(actividadesPorDia: nuevoMapa, errorMessage: null));
    _autoSave(); // 💾 Autoguardado
  }

  // ✨ FASE 4: ACTUALIZAR ACTIVIDAD EXISTENTE
  void updateActivity(ActividadItinerario actividadActualizada) {
    final int dia = state.diaSeleccionadoIndex;
    final List<ActividadItinerario> lista = List.from(
      state.actividadesPorDia[dia] ?? [],
    );

    final index = lista.indexWhere((a) => a.id == actividadActualizada.id);
    if (index != -1) {
      lista[index] = actividadActualizada;
      // Ordena solo si ambas tienen horario definido; las sin-horario van al final
      lista.sort((a, b) {
        final aSinHorario = state.actividadSinHorario(a);
        final bSinHorario = state.actividadSinHorario(b);
        if (aSinHorario && bSinHorario) return 0;
        if (aSinHorario) return 1;
        if (bSinHorario) return -1;
        return a.horaInicio.compareTo(b.horaInicio);
      });

      final nuevoMapa = Map<int, List<ActividadItinerario>>.from(
        state.actividadesPorDia,
      );
      nuevoMapa[dia] = lista;
      emit(state.copyWith(actividadesPorDia: nuevoMapa));

      _autoSave(); // 💾 Autoguardado
    }
  }

  // 🗑️ FASE 4: ELIMINAR ACTIVIDAD
  void deleteActivity(String id) {
    final int dia = state.diaSeleccionadoIndex;
    final List<ActividadItinerario> lista = List.from(
      state.actividadesPorDia[dia] ?? [],
    );

    lista.removeWhere((a) => a.id == id);

    final nuevoMapa = Map<int, List<ActividadItinerario>>.from(
      state.actividadesPorDia,
    );
    nuevoMapa[dia] = lista;
    emit(state.copyWith(actividadesPorDia: nuevoMapa));

    _autoSave(); // 💾 Autoguardado
  }

  // 🗑️ Eliminar actividad de un día específico
  void deleteActivityFromDay(String id, int dia) {
    final List<ActividadItinerario> lista = List.from(
      state.actividadesPorDia[dia] ?? [],
    );

    lista.removeWhere((a) => a.id == id);

    final nuevoMapa = Map<int, List<ActividadItinerario>>.from(
      state.actividadesPorDia,
    );
    nuevoMapa[dia] = lista;
    emit(state.copyWith(actividadesPorDia: nuevoMapa));
    _autoSave(); // 💾 Autoguardado
  }

  /// 🔁 Reordena sin-horario por ID — llamado desde LongPressDraggable.
  void reordenarSinHorarioPorId(String idMovido, String idDestino) {
    final int dia = state.diaSeleccionadoIndex;
    final List<ActividadItinerario> todas = List.from(
      state.actividadesPorDia[dia] ?? [],
    );
    final conHorario =
        todas.where((a) => !state.actividadSinHorario(a)).toList();
    final sinHorario =
        todas.where((a) => state.actividadSinHorario(a)).toList();

    final fromIdx = sinHorario.indexWhere((a) => a.id == idMovido);
    final toIdx = sinHorario.indexWhere((a) => a.id == idDestino);
    if (fromIdx == -1 || toIdx == -1 || fromIdx == toIdx) return;

    final item = sinHorario.removeAt(fromIdx);
    sinHorario.insert(toIdx, item);

    final nuevoMapa = Map<int, List<ActividadItinerario>>.from(
      state.actividadesPorDia,
    );
    nuevoMapa[dia] = [...sinHorario, ...conHorario];
    emit(state.copyWith(actividadesPorDia: nuevoMapa));
    _autoSave();
  }

  /// 🔄 Intercambia el horario entre una sin-horario y una con-horario.
  void intercambiarHorario(String idSinHorario, String idConHorario) {
    final int dia = state.diaSeleccionadoIndex;
    final List<ActividadItinerario> todas = List.from(
      state.actividadesPorDia[dia] ?? [],
    );

    final idxSin = todas.indexWhere((a) => a.id == idSinHorario);
    final idxCon = todas.indexWhere((a) => a.id == idConHorario);
    if (idxSin == -1 || idxCon == -1) return;

    final sinAct = todas[idxSin];
    final conAct = todas[idxCon];
    final fb = state.fechaBaseDiaActual;
    final base = DateTime(fb.year, fb.month, fb.day);

    todas[idxSin] = sinAct.copyWith(
      horaInicio: conAct.horaInicio,
      horaFin: conAct.horaFin,
    );
    todas[idxCon] = conAct.copyWith(horaInicio: base, horaFin: base);

    todas.sort((a, b) {
      final as_ = state.actividadSinHorario(a);
      final bs_ = state.actividadSinHorario(b);
      if (as_ && bs_) return 0;
      if (as_) return -1;
      if (bs_) return 1;
      return a.horaInicio.compareTo(b.horaInicio);
    });

    final nuevoMapa = Map<int, List<ActividadItinerario>>.from(
      state.actividadesPorDia,
    );
    nuevoMapa[dia] = todas;
    emit(state.copyWith(actividadesPorDia: nuevoMapa));
    _autoSave();
  }

  /// ⏰→📋 Quita el horario a una actividad y la mueve a sin-horario.
  void quitarHorario(String idActividad) {
    final int dia = state.diaSeleccionadoIndex;
    final List<ActividadItinerario> todas = List.from(
      state.actividadesPorDia[dia] ?? [],
    );
    final idx = todas.indexWhere((a) => a.id == idActividad);
    if (idx == -1) return;

    final fb = state.fechaBaseDiaActual;
    final base = DateTime(fb.year, fb.month, fb.day);
    todas[idx] = todas[idx].copyWith(horaInicio: base, horaFin: base);

    todas.sort((a, b) {
      final as_ = state.actividadSinHorario(a);
      final bs_ = state.actividadSinHorario(b);
      if (as_ && bs_) return 0;
      if (as_) return -1;
      if (bs_) return 1;
      return a.horaInicio.compareTo(b.horaInicio);
    });

    final nuevoMapa = Map<int, List<ActividadItinerario>>.from(
      state.actividadesPorDia,
    );
    nuevoMapa[dia] = todas;
    emit(state.copyWith(actividadesPorDia: nuevoMapa));
    _autoSave();
  }

  Future<void> saveFullTrip(Viaje viajeBase) async {
    // Validación: todas las actividades deben tener horario
    if (!state.puedeGuardar) {
      emit(
        state.copyWith(
          errorMessage:
              state.hayAlgunaActividad
                  ? "Todas las actividades deben tener horario configurado antes de guardar."
                  : "Agrega al menos una actividad antes de guardar.",
        ),
      );
      Future.delayed(const Duration(milliseconds: 3000), () {
        if (!isClosed) emit(state.copyWith(errorMessage: null));
      });
      return;
    }

    emit(state.copyWith(isSaving: true));

    try {
      // 1. Aplanar el mapa de actividades a una sola lista
      List<ActividadItinerario> listaCompleta = [];
      state.actividadesPorDia.forEach((dia, actividades) {
        listaCompleta.addAll(actividades);
      });

      // 2. Derivar hora de inicio y fin del viaje desde las actividades
      final inicioReal = state.derivedFechaInicio ?? viajeBase.fechaInicio;
      final finReal = state.derivedFechaFin ?? viajeBase.fechaFin;

      // 3. Fusionar: Viaje Base + Itinerario Completo + Tiempos reales
      final viajeFinal = viajeBase.copyWith(
        itinerario: listaCompleta,
        fechaInicio: inicioReal,
        fechaFin: finReal,
      );

      // 4. Mandar al repositorio
      await _repository.crearViaje(viajeFinal);

      // 5. Limpiar borrador si se guardó con éxito
      await _localDataSource.clearDraft(); // 🗑️ Limpieza

      if (!isClosed) {
        emit(state.copyWith(isSaving: false, isSaved: true));
        _unsavedChangesService.setDirty(false); // 📝 Guardado final = Limpio
      }
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isSaving: false,
            errorMessage: "Error al guardar el viaje: $e",
            isSaved: false,
          ),
        );
      }
      debugPrint("Error guardando viaje: $e");
    }
  }

  // ── Importar actividades de CSV para el día actual ──
  void importDayFromCsv(String csvContent) {
    try {
      final fechaBase = state.fechaBaseDiaActual;
      final actividades = CsvItineraryParser.parseSingleDay(
        csvContent,
        fechaBase,
      );

      final nuevoMapa = Map<int, List<ActividadItinerario>>.from(
        state.actividadesPorDia,
      );
      nuevoMapa[state.diaSeleccionadoIndex] = actividades;

      emit(state.copyWith(actividadesPorDia: nuevoMapa, errorMessage: null));
      _autoSave();
    } on FormatException catch (e) {
      emit(state.copyWith(errorMessage: e.message));
      Future.delayed(const Duration(seconds: 5), () {
        if (!isClosed) emit(state.copyWith(errorMessage: null));
      });
    }
  }

  // ── Importar viaje completo desde CSV ──
  void importFullTripFromCsv(String csvContent, DateTime fechaInicio) {
    try {
      final mapa = CsvItineraryParser.parseFullTrip(csvContent, fechaInicio);

      final nuevoMapa = Map<int, List<ActividadItinerario>>.from(
        state.actividadesPorDia,
      );
      mapa.forEach((dia, actividades) {
        nuevoMapa[dia] = actividades;
      });

      emit(state.copyWith(actividadesPorDia: nuevoMapa, errorMessage: null));
      _autoSave();
    } on FormatException catch (e) {
      emit(state.copyWith(errorMessage: e.message));
      Future.delayed(const Duration(seconds: 5), () {
        if (!isClosed) emit(state.copyWith(errorMessage: null));
      });
    }
  }

  /// Devuelve las coordenadas del destino del viaje guardadas en el borrador.
  /// Se usa para centrar el mapa al seleccionar la ubicación de una actividad.
  Future<(double lat, double lng)?> getDestinoCentro() async {
    final draft = await _localDataSource.getDraft();
    if (draft?.lat != null && draft?.lng != null) {
      return (draft!.lat!, draft.lng!);
    }
    return null;
  }

  // ✨ NUEVO MÉTODO MAESTRO DE IMPORTACIÓN
  Future<void> procesarCsvImportado(String csvContent) async {
    emit(state.copyWith(isImporting: true));

    try {
      final actividadesNuevas = await _importService.parseCsv(csvContent);
      final nuevoMapa = Map<int, List<ActividadItinerario>>.from(
        state.actividadesPorDia,
      );

      int actividadesConErroresRescatadas = 0; // ✨ Contador de advertencias

      for (var item in actividadesNuevas) {
        final diaIndex = item.diaIndex;

        // Si la actividad fue auto-completada con nuestra bandera de alerta, sumamos al contador
        if (item.actividad.titulo.contains('⚠️')) {
          actividadesConErroresRescatadas++;
        }

        if (diaIndex < state.totalDias) {
          final fechaBaseDelDia = (state.horaInicioViaje ?? DateTime.now()).add(
            Duration(days: diaIndex),
          );

          final act = item.actividad;
          final horaInicioReal = DateTime(
            fechaBaseDelDia.year,
            fechaBaseDelDia.month,
            fechaBaseDelDia.day,
            act.horaInicio.hour,
            act.horaInicio.minute,
          );
          final horaFinReal = DateTime(
            fechaBaseDelDia.year,
            fechaBaseDelDia.month,
            fechaBaseDelDia.day,
            act.horaFin.hour,
            act.horaFin.minute,
          );

          final actividadAjustada = act.copyWith(
            horaInicio: horaInicioReal,
            horaFin: horaFinReal,
          );

          final listaDelDia = nuevoMapa[diaIndex] ?? [];
          listaDelDia.add(actividadAjustada);
          listaDelDia.sort((a, b) => a.horaInicio.compareTo(b.horaInicio));
          nuevoMapa[diaIndex] = listaDelDia;
        }
      }

      // ✨ PREPARAMOS EL MENSAJE FINAL
      String? mensajeAlerta;
      if (actividadesConErroresRescatadas > 0) {
        mensajeAlerta =
            "Importación exitosa, pero $actividadesConErroresRescatadas actividad(es) estaban incompletas en el archivo. Busca las tarjetas con '⚠️' y edítalas.";
      }

      emit(
        state.copyWith(
          actividadesPorDia: nuevoMapa,
          isImporting: false,
          errorMessage: mensajeAlerta,
        ),
      );

      _autoSave();

      if (mensajeAlerta != null) {
        Future.delayed(const Duration(seconds: 6), () {
          if (!isClosed) emit(state.copyWith(errorMessage: null));
        });
      }
    } catch (e) {
      emit(
        state.copyWith(
          isImporting: false,
          errorMessage: "Error crítico leyendo el archivo CSV.",
        ),
      );
      Future.delayed(const Duration(seconds: 3), () {
        if (!isClosed) emit(state.copyWith(errorMessage: null));
      });
    }
  }
}
