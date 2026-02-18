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
    // Convertir TimeOfDay a DateTime y guardar para cálculos dinámicos
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

  // ✨ NUEVO: Método para recibir el Drop
  void onActivityDropped(TipoActividad tipo) {
    final int dia = state.diaSeleccionadoIndex;
    final List<ActividadItinerario> listaActual = List.from(
      state.actividadesDelDiaActual,
    );

    // 1. Calcular hora sugerida (hora de inicio del viaje o 30 min después de la última)
    DateTime horaInicio =
        state.horaInicioDia; // ✨ Usar hora de inicio del viaje
    if (listaActual.isNotEmpty) {
      horaInicio = listaActual.last.horaFin.add(const Duration(minutes: 30));
    }

    // Duración por defecto según el tipo
    final int duracionMinutos = (tipo == TipoActividad.traslado) ? 60 : 90;
    final DateTime horaFin = horaInicio.add(Duration(minutes: duracionMinutos));

    // ✨ VALIDACIÓN: Verificar que no exceda el límite de tiempo
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
      // Limpiar error después de mostrar el modal
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!isClosed) emit(state.copyWith(errorMessage: null));
      });
      return; // No agregar la actividad
    }

    // 2. Crear la nueva actividad
    final nuevaActividad = ActividadItinerario(
      id: const Uuid().v4(),
      titulo: _getTituloPorDefecto(tipo),
      descripcion: "Toca para editar detalles",
      horaInicio: horaInicio,
      horaFin: horaFin,
      tipo: tipo,
      // Ubicación vacía por ahora
    );

    listaActual.add(nuevaActividad);

    // 3. Actualizar el mapa del estado
    final nuevoMapa = Map<int, List<ActividadItinerario>>.from(
      state.actividadesPorDia,
    );
    nuevoMapa[dia] = listaActual;

    emit(state.copyWith(actividadesPorDia: nuevoMapa, errorMessage: null));
  }

  // ✨ Helper: Verificar si excedería el límite de tiempo
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
}
