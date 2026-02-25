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
part 'itinerary_builder_state.dart';

class ItineraryBuilderCubit extends Cubit<ItineraryBuilderState> {
  final TripRepository _repository;
  final TripLocalDataSource _localDataSource;
  final UnsavedChangesService _unsavedChangesService;
  final CategoriasRepository _categoriasRepository;
  Timer? _debounce;

  /// ID de agencia — placeholder hasta que llegue auth (se usa para el repositorio).
  static const String _agenciaId = 'agencia_default';

  ItineraryBuilderCubit({
    required TripRepository repository,
    required TripLocalDataSource localDataSource,
    required UnsavedChangesService unsavedChangesService,
    required CategoriasRepository categoriasRepository,
  }) : _repository = repository,
       _localDataSource = localDataSource,
       _unsavedChangesService = unsavedChangesService,
       _categoriasRepository = categoriasRepository,
       super(ItineraryBuilderState());

  // --- AUTOGUARDADO (Fase 13) ---
  void _autoSave() {
    // Aplanamos todas las actividades
    List<ActividadItinerario> todas = [];
    state.actividadesPorDia.forEach((_, lista) => todas.addAll(lista));

    // Recuperamos draft existente para mantener TODOS los datos del Paso 1
    _localDataSource.getDraft().then((currentDraft) {
      if (currentDraft != null) {
        final updatedDraft = TripDraftModel(
          // ─── Datos Paso 1 (preservar todos) ───────────────────────────
          destino: currentDraft.destino,
          fechaInicio: currentDraft.fechaInicio,
          fechaFin: currentDraft.fechaFin,
          horaInicio: currentDraft.horaInicio, // ✅ Hora inicio viaje
          horaFin: currentDraft.horaFin, // ✅ Hora fin viaje
          isMultiDay: currentDraft.isMultiDay, // ✅ Modo multi-día
          guiaId: currentDraft.guiaId,
          coGuiasIds: currentDraft.coGuiasIds, // ✅ Guías auxiliares
          fotoPortadaUrl: currentDraft.fotoPortadaUrl, // ✅ Foto de portada
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
  }) async {
    emit(
      state.copyWith(
        totalDias: duracionDias,
        horaInicioViaje: fechaInicio,
        horaFinViaje: fechaFin,
      ),
    );

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

    // 🎭 Cargar categorías desde el Repositorio (mock ahora, API real después)
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
    // 1. Actualizar UI inmediatamente (optimistic update)
    final todasLasCategorias = [...state.categorias, nueva];
    emit(state.copyWith(categorias: todasLasCategorias));
    // 2. Persistir a través del Repositorio
    await _categoriasRepository.guardarCategoriaPersonalizada(
      _agenciaId,
      nueva,
    );
    // 3. Reload desde la fuente de verdad
    final frescas = await _categoriasRepository.obtenerCategorias(_agenciaId);
    if (!isClosed) emit(state.copyWith(categorias: frescas));
  }

  void cambiarDia(int index) {
    if (index >= 0 && index < state.totalDias) {
      emit(state.copyWith(diaSeleccionadoIndex: index));
    }
  }

  // ✨ FASE 5: Búsqueda de fotos al escribir el título (debounce 800ms)
  void onTituloChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    // Limpiar sugerencias si el texto es muy corto
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

  // ✨ Activar/desactivar modo horas extra para el día actual
  void toggleModoHorasExtra() {
    final dia = state.diaSeleccionadoIndex;
    final nuevoSet = Set<int>.from(state.modoHorasExtraPorDia);
    if (nuevoSet.contains(dia)) {
      nuevoSet.remove(dia);
    } else {
      nuevoSet.add(dia);
    }
    emit(state.copyWith(modoHorasExtraPorDia: nuevoSet));
  }

  // ✨ NUEVO: Establecer hora de inicio personalizada para un día
  void setHoraInicioDia(int dia, TimeOfDay hora) {
    final base = state.horaInicioViaje ?? DateTime.now();
    final fechaDia = base.add(Duration(days: dia));
    final nuevaHora = DateTime(
      fechaDia.year,
      fechaDia.month,
      fechaDia.day,
      hora.hour,
      hora.minute,
    );

    // Validar que la hora inicio sea menor que la hora fin del día
    final horaFinActual = _getHoraFinParaDia(dia);
    if (nuevaHora.isAfter(horaFinActual) ||
        nuevaHora.isAtSameMomentAs(horaFinActual)) {
      final finStr =
          "${horaFinActual.hour}:${horaFinActual.minute.toString().padLeft(2, '0')}";
      emit(
        state.copyWith(
          errorMessage:
              "La hora de inicio debe ser anterior a la hora de fin ($finStr).",
        ),
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!isClosed) emit(state.copyWith(errorMessage: null));
      });
      return;
    }

    final nuevoMapa = Map<int, DateTime>.from(state.horasInicioPorDia);
    nuevoMapa[dia] = nuevaHora;
    emit(state.copyWith(horasInicioPorDia: nuevoMapa, errorMessage: null));
  }

  // ✨ Establecer hora de fin personalizada para un día.
  void setHoraFinDia(int dia, DateTime nuevaHora) {
    // Validar que la hora fin sea mayor que la hora inicio del día
    final horaInicioActual = _getHoraInicioParaDia(dia);
    if (nuevaHora.isBefore(horaInicioActual) ||
        nuevaHora.isAtSameMomentAs(horaInicioActual)) {
      final inicioStr =
          "${horaInicioActual.hour}:${horaInicioActual.minute.toString().padLeft(2, '0')}";
      emit(
        state.copyWith(
          errorMessage:
              "La hora de fin debe ser posterior a la hora de inicio ($inicioStr).",
        ),
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!isClosed) emit(state.copyWith(errorMessage: null));
      });
      return;
    }

    final horaFinActual = _getHoraFinParaDia(dia);
    final actividades = state.actividadesPorDia[dia] ?? [];

    final estaAumentando = nuevaHora.isAfter(horaFinActual);
    final estaDisminuyendo = nuevaHora.isBefore(horaFinActual);

    // DISMINUIR: bloquear si alguna actividad termina después de la nueva hora
    if (estaDisminuyendo && actividades.isNotEmpty) {
      final ultimaFin = actividades.last.horaFin;
      if (ultimaFin.isAfter(nuevaHora)) {
        final ultimaStr =
            "${ultimaFin.hour}:${ultimaFin.minute.toString().padLeft(2, '0')}";
        emit(
          state.copyWith(
            errorMessage:
                "No puedes reducir la hora de fin: hay una actividad que termina a las $ultimaStr.",
          ),
        );
        Future.delayed(const Duration(milliseconds: 2500), () {
          if (!isClosed) emit(state.copyWith(errorMessage: null));
        });
        return;
      }
    }

    // Guardar la nueva hora fin
    final nuevoMapaFin = Map<int, DateTime>.from(state.horasFinPorDia);
    nuevoMapaFin[dia] = nuevaHora;

    // AUMENTAR con horas extra activas: auto-desactivar si la última actividad
    // ya cabe dentro del nuevo límite normal
    final nuevoSetModo = Set<int>.from(state.modoHorasExtraPorDia);
    if (estaAumentando &&
        nuevoSetModo.contains(dia) &&
        actividades.isNotEmpty) {
      final ultimaFin = actividades.last.horaFin;
      if (!ultimaFin.isAfter(nuevaHora)) {
        nuevoSetModo.remove(dia);
      }
    }

    emit(
      state.copyWith(
        horasFinPorDia: nuevoMapaFin,
        modoHorasExtraPorDia: nuevoSetModo,
        errorMessage: null,
      ),
    );
  }

  // Helpers privados
  DateTime _getHoraInicioParaDia(int dia) {
    if (state.horasInicioPorDia.containsKey(dia)) {
      return state.horasInicioPorDia[dia]!;
    }
    if (dia == 0 && state.horaInicioViaje != null) {
      return state.horaInicioViaje!;
    }
    final base = state.horaInicioViaje ?? DateTime.now();
    final fechaDia = base.add(Duration(days: dia));
    return DateTime(fechaDia.year, fechaDia.month, fechaDia.day, 6, 0);
  }

  DateTime _getHoraFinParaDia(int dia) {
    if (state.horasFinPorDia.containsKey(dia)) {
      return state.horasFinPorDia[dia]!;
    }
    if (dia == state.totalDias - 1 && state.horaFinViaje != null) {
      return state.horaFinViaje!;
    }
    final base = state.horaInicioViaje ?? DateTime.now();
    final fechaDia = base.add(Duration(days: dia));
    return DateTime(fechaDia.year, fechaDia.month, fechaDia.day, 22, 0);
  }

  // Método para recibir el Drop de una actividad
  void onActivityDropped(CategoriaActividad categoria) {
    final int dia = state.diaSeleccionadoIndex;
    final List<ActividadItinerario> listaActual = List.from(
      state.actividadesDelDiaActual,
    );

    if (!state.puedeAgregarActividades) {
      String msg =
          "No hay tiempo disponible. Activa las horas extra para agregar actividades nocturnas.";

      if (state.actividadesUsanHorasNocturnas) {
        msg =
            "Solo se permite una actividad nocturna por día. Elimina la existente para agregar otra.";
      }

      emit(state.copyWith(errorMessage: msg));
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (!isClosed) emit(state.copyWith(errorMessage: null));
      });
      return;
    }

    final fechaBaseDelDia = state.fechaBaseDiaActual;

    DateTime horaInicio;

    if (listaActual.isNotEmpty) {
      final ultimaFin = listaActual.last.horaFin;
      final limiteDelDia = state.horaFinDia;
      final minutosRestantesSinBuffer =
          limiteDelDia.difference(ultimaFin).inMinutes;

      final int bufferMinutos;
      if (minutosRestantesSinBuffer <= 5) {
        bufferMinutos = 30;
      } else if (minutosRestantesSinBuffer <= 35) {
        bufferMinutos = 0;
      } else if (minutosRestantesSinBuffer <= 60) {
        bufferMinutos = 10;
      } else {
        bufferMinutos = 30;
      }

      horaInicio = ultimaFin.add(Duration(minutes: bufferMinutos));
    } else {
      final horaBase = state.horaInicioDia;
      horaInicio = DateTime(
        fechaBaseDelDia.year,
        fechaBaseDelDia.month,
        fechaBaseDelDia.day,
        horaBase.hour,
        horaBase.minute,
      );

      if (dia > 0) {
        final listaDiaAnterior = state.actividadesPorDia[dia - 1] ?? [];
        if (listaDiaAnterior.isNotEmpty) {
          final ultimaActAnterior = listaDiaAnterior.last;
          if (ultimaActAnterior.horaFin.isAfter(horaInicio)) {
            final h = ultimaActAnterior.horaFin.hour;
            final m = ultimaActAnterior.horaFin.minute.toString().padLeft(
              2,
              '0',
            );
            final periodo = h >= 12 ? 'PM' : 'AM';
            final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);

            emit(
              state.copyWith(
                errorMessage:
                    "El Día $dia tiene una actividad nocturna que termina a las $h12:$m $periodo. "
                    "El Día ${dia + 1} no puede iniciar actividades antes de esa hora.",
              ),
            );
            Future.delayed(const Duration(milliseconds: 2500), () {
              if (!isClosed) emit(state.copyWith(errorMessage: null));
            });
            return;
          }
        }
      }
    }

    // 🎭 Usar duracionDefaultMinutos de la categoría dinámica
    final int duracionMinutos = categoria.duracionDefaultMinutos;
    DateTime horaFin = horaInicio.add(Duration(minutes: duracionMinutos));

    final limiteBase = state.horaFinDia;
    final esUltimoDia = dia == state.totalDias - 1;
    final limiteExtendido =
        (!esUltimoDia) ? limiteBase.add(const Duration(hours: 3)) : limiteBase;
    final limiteEfectivo =
        state.modoHorasExtraActivo ? limiteExtendido : limiteBase;

    if (horaFin.isAfter(limiteEfectivo)) {
      final minutosDisponibles =
          limiteEfectivo.difference(horaInicio).inMinutes;

      if (minutosDisponibles <= 0) {
        final limiteStr =
            "${limiteEfectivo.hour}:${limiteEfectivo.minute.toString().padLeft(2, '0')}";
        emit(
          state.copyWith(
            errorMessage:
                "No se puede agregar: el inicio ya supera el límite del día ($limiteStr).",
          ),
        );
        Future.delayed(const Duration(milliseconds: 3500), () {
          if (!isClosed) emit(state.copyWith(errorMessage: null));
        });
        return;
      }

      if (minutosDisponibles >= 5) {
        horaFin = limiteEfectivo;
      } else {
        emit(
          state.copyWith(
            errorMessage:
                "Espacio insuficiente ($minutosDisponibles min). Se requieren al menos 5 min libres.",
          ),
        );
        Future.delayed(const Duration(milliseconds: 2500), () {
          if (!isClosed) emit(state.copyWith(errorMessage: null));
        });
        return;
      }
    }

    final nuevaActividad = ActividadItinerario(
      id: const Uuid().v4(),
      titulo:
          '', // Vacío: el diálogo asigna el placeholder, Pexels no se dispara
      descripcion: '', // Vacío: el diálogo asigna el placeholder
      horaInicio: horaInicio,
      horaFin: horaFin,
      tipo: categoria.toTipoActividad(), // Compatibilidad con el modelo legacy
      categoriaSnapshot: categoria, // 📸 Snapshot completo → borrador autónomo
    );

    listaActual.add(nuevaActividad);

    final nuevoMapa = Map<int, List<ActividadItinerario>>.from(
      state.actividadesPorDia,
    );
    nuevoMapa[dia] = listaActual;

    emit(state.copyWith(actividadesPorDia: nuevoMapa, errorMessage: null));

    _verificarDesactivarHorasExtra(dia, listaActual);
    _autoSave(); // 💾 Autoguardado
  }

  // Método público para verificar si una actividad cabe en el horario
  bool wouldActivityFit(CategoriaActividad categoria) {
    if (!state.puedeAgregarActividades) return false;

    final int dia = state.diaSeleccionadoIndex;
    final List<ActividadItinerario> listaActual = state.actividadesDelDiaActual;
    final fechaBaseDelDia = state.fechaBaseDiaActual;

    DateTime horaInicio;
    if (listaActual.isNotEmpty) {
      final ultimaFin = listaActual.last.horaFin;
      final limiteDelDia = state.horaFinDia;
      final minutosRestantesSinBuffer =
          limiteDelDia.difference(ultimaFin).inMinutes;

      final int bufferMinutos;
      if (minutosRestantesSinBuffer <= 5) {
        bufferMinutos = 30;
      } else if (minutosRestantesSinBuffer <= 35) {
        bufferMinutos = 0;
      } else if (minutosRestantesSinBuffer <= 60) {
        bufferMinutos = 10;
      } else {
        bufferMinutos = 30;
      }

      horaInicio = ultimaFin.add(Duration(minutes: bufferMinutos));
    } else {
      final horaBase = state.horaInicioDia;
      horaInicio = DateTime(
        fechaBaseDelDia.year,
        fechaBaseDelDia.month,
        fechaBaseDelDia.day,
        horaBase.hour,
        horaBase.minute,
      );

      if (dia > 0) {
        final listaDiaAnterior = state.actividadesPorDia[dia - 1] ?? [];
        if (listaDiaAnterior.isNotEmpty &&
            listaDiaAnterior.last.horaFin.isAfter(horaInicio)) {
          return false;
        }
      }
    }

    final int duracionMinutos = categoria.duracionDefaultMinutos;
    final DateTime horaFin = horaInicio.add(Duration(minutes: duracionMinutos));

    final limiteBase = state.horaFinDia;
    final esUltimoDia = dia == state.totalDias - 1;
    final limiteAbsoluto =
        (!esUltimoDia) ? limiteBase.add(const Duration(hours: 3)) : limiteBase;

    if (horaFin.isBefore(limiteAbsoluto) ||
        horaFin.isAtSameMomentAs(limiteAbsoluto)) {
      return true;
    }

    final minutosDisponibles = limiteAbsoluto.difference(horaInicio).inMinutes;
    return minutosDisponibles >= 5;
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
      lista.sort((a, b) => a.horaInicio.compareTo(b.horaInicio));

      final nuevoMapa = Map<int, List<ActividadItinerario>>.from(
        state.actividadesPorDia,
      );
      nuevoMapa[dia] = lista;
      emit(state.copyWith(actividadesPorDia: nuevoMapa));

      _verificarDesactivarHorasExtra(dia, lista);
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

    _verificarDesactivarHorasExtra(dia, lista);
    _autoSave(); // 💾 Autoguardado
  }

  // 🗑️ SINCRONIZACIÓN NOCTURNA: Eliminar actividad de un día específico
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

    _verificarDesactivarHorasExtra(dia, lista);
    _autoSave(); // 💾 Autoguardado
  }

  void _verificarDesactivarHorasExtra(
    int dia,
    List<ActividadItinerario> actividades,
  ) {
    if (!state.modoHorasExtraPorDia.contains(dia)) return;

    if (actividades.isEmpty) {
      final nuevoSet = Set<int>.from(state.modoHorasExtraPorDia)..remove(dia);
      emit(state.copyWith(modoHorasExtraPorDia: nuevoSet));
      return;
    }

    DateTime maxFin = actividades.first.horaFin;
    for (var a in actividades) {
      if (a.horaFin.isAfter(maxFin)) maxFin = a.horaFin;
    }

    if (dia != state.diaSeleccionadoIndex) return;

    final finNormal = state.horaFinDia;

    if (!maxFin.isAfter(finNormal)) {
      final nuevoSet = Set<int>.from(state.modoHorasExtraPorDia)..remove(dia);
      emit(state.copyWith(modoHorasExtraPorDia: nuevoSet));
    }
  }

  Future<void> saveFullTrip(Viaje viajeBase) async {
    if (state.isSaving) return;

    emit(state.copyWith(isSaving: true));

    try {
      // 1. Aplanar el mapa de actividades a una sola lista
      List<ActividadItinerario> listaCompleta = [];
      state.actividadesPorDia.forEach((dia, actividades) {
        listaCompleta.addAll(actividades);
      });

      // 2. Fusionar: Viaje Base + Itinerario Completo
      final viajeFinal = viajeBase.copyWith(itinerario: listaCompleta);

      // 3. Mandar al repositorio
      await _repository.crearViaje(viajeFinal);

      // 4. Limpiar borrador si se guardó con éxito
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
}
