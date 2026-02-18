import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart'; // Para TimeOfDay
import 'package:frontend/features/agencia/trips/domain/entities/actividad_itinerario.dart';

part 'itinerary_builder_state.dart';

class ItineraryBuilderCubit extends Cubit<ItineraryBuilderState> {
  ItineraryBuilderCubit() : super(ItineraryBuilderState());

  // Inicializar con la duración del viaje creado previamente
  void init(int duracionDias, {TimeOfDay? horaInicio, TimeOfDay? horaFin}) {
    final DateTime? horaInicioViaje =
        horaInicio != null
            ? DateTime(2024, 1, 1, horaInicio.hour, horaInicio.minute)
            : null;

    final DateTime? horaFinViaje =
        horaFin != null
            ? DateTime(2024, 1, 1, horaFin.hour, horaFin.minute)
            : null;

    emit(
      state.copyWith(
        totalDias: duracionDias,
        horaInicioViaje: horaInicioViaje,
        horaFinViaje: horaFinViaje,
      ),
    );
  }

  void cambiarDia(int index) {
    if (index >= 0 && index < state.totalDias) {
      emit(state.copyWith(diaSeleccionadoIndex: index));
    }
  }

  // ✨ NUEVO: Establecer hora de inicio personalizada para un día
  void setHoraInicioDia(int dia, TimeOfDay hora) {
    final nuevaHora = DateTime(2024, 1, 1, hora.hour, hora.minute);

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

  // ✨ NUEVO: Establecer hora de fin personalizada para un día
  void setHoraFinDia(int dia, TimeOfDay hora) {
    final nuevaHora = DateTime(2024, 1, 1, hora.hour, hora.minute);

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

    final nuevoMapa = Map<int, DateTime>.from(state.horasFinPorDia);
    nuevoMapa[dia] = nuevaHora;
    emit(state.copyWith(horasFinPorDia: nuevoMapa, errorMessage: null));
  }

  // Helpers privados para obtener la hora efectiva de un día específico
  // (sin depender del día seleccionado actualmente en el estado)
  DateTime _getHoraInicioParaDia(int dia) {
    if (state.horasInicioPorDia.containsKey(dia)) {
      return state.horasInicioPorDia[dia]!;
    }
    if (dia == 0 && state.horaInicioViaje != null) {
      return state.horaInicioViaje!;
    }
    return DateTime(2024, 1, 1, 6, 0);
  }

  DateTime _getHoraFinParaDia(int dia) {
    if (state.horasFinPorDia.containsKey(dia)) {
      return state.horasFinPorDia[dia]!;
    }
    if (dia == state.totalDias - 1 && state.horaFinViaje != null) {
      return state.horaFinViaje!;
    }
    return DateTime(2024, 1, 1, 22, 0);
  }

  // Método para recibir el Drop de una actividad
  void onActivityDropped(TipoActividad tipo) {
    final int dia = state.diaSeleccionadoIndex;
    final List<ActividadItinerario> listaActual = List.from(
      state.actividadesDelDiaActual,
    );

    // 1. Calcular hora sugerida
    DateTime horaInicio = state.horaInicioDia;
    if (listaActual.isNotEmpty) {
      horaInicio = listaActual.last.horaFin.add(const Duration(minutes: 30));
    }

    // Duración por defecto según el tipo
    final int duracionMinutos = (tipo == TipoActividad.traslado) ? 60 : 90;
    final DateTime horaFin = horaInicio.add(Duration(minutes: duracionMinutos));

    // Validación: Verificar que no exceda el límite de tiempo
    if (_wouldExceedTimeLimit(horaFin)) {
      final horaFinStr =
          "${horaFin.hour}:${horaFin.minute.toString().padLeft(2, '0')}";
      final limiteStr =
          "${state.horaFinDia.hour}:${state.horaFinDia.minute.toString().padLeft(2, '0')}";
      emit(
        state.copyWith(
          errorMessage:
              "Esta actividad terminaría a las $horaFinStr, excediendo el horario límite de las $limiteStr.\n\nPor favor, ajusta las actividades existentes o reduce la duración.",
        ),
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!isClosed) emit(state.copyWith(errorMessage: null));
      });
      return;
    }

    // 2. Crear la nueva actividad
    final nuevaActividad = ActividadItinerario(
      id: const Uuid().v4(),
      titulo: _getTituloPorDefecto(tipo),
      descripcion: "Toca para editar detalles",
      horaInicio: horaInicio,
      horaFin: horaFin,
      tipo: tipo,
    );

    listaActual.add(nuevaActividad);

    // 3. Actualizar el mapa del estado
    final nuevoMapa = Map<int, List<ActividadItinerario>>.from(
      state.actividadesPorDia,
    );
    nuevoMapa[dia] = listaActual;

    emit(state.copyWith(actividadesPorDia: nuevoMapa, errorMessage: null));
  }

  // Helper: Verificar si excedería el límite de tiempo
  bool _wouldExceedTimeLimit(DateTime proposedEndTime) {
    return proposedEndTime.isAfter(state.horaFinDia);
  }

  String _getTituloPorDefecto(TipoActividad tipo) {
    switch (tipo) {
      case TipoActividad.hospedaje:
        return "Check-in Hotel";
      case TipoActividad.comida:
        return "Alimentos";
      case TipoActividad.traslado:
        return "Traslado";
      case TipoActividad.cultura:
        return "Visita Cultural";
      case TipoActividad.aventura:
        return "Actividad Aventura";
      case TipoActividad.tiempoLibre:
        return "Tiempo Libre";
      default:
        return "Nueva Actividad";
    }
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
      // Mantenemos el orden cronológico siempre
      lista.sort((a, b) => a.horaInicio.compareTo(b.horaInicio));

      final nuevoMapa = Map<int, List<ActividadItinerario>>.from(
        state.actividadesPorDia,
      );
      nuevoMapa[dia] = lista;
      emit(state.copyWith(actividadesPorDia: nuevoMapa));
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
  }
}
