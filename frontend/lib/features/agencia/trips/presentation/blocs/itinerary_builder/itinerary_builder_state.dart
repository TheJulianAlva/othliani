part of 'itinerary_builder_cubit.dart';

class ItineraryBuilderState extends Equatable {
  final int diaSeleccionadoIndex; // 0 para Día 1, 1 para Día 2...
  final int totalDias; // Total de días del viaje
  // ✨ NUEVO: Mapa de actividades por día
  final Map<int, List<ActividadItinerario>> actividadesPorDia;

  // ✨ Horas del viaje original (para calcular rangos por día)
  final DateTime? horaInicioViaje; // Hora de inicio del viaje (solo para día 1)
  final DateTime? horaFinViaje; // Hora de fin del viaje (solo para último día)

  // Mensaje de error opcional
  final String? errorMessage;

  const ItineraryBuilderState({
    this.diaSeleccionadoIndex = 0,
    this.totalDias = 1,
    this.actividadesPorDia = const {},
    this.errorMessage,
    this.horaInicioViaje,
    this.horaFinViaje,
  });

  // ✨ Getters dinámicos para límites de tiempo según el día
  DateTime get horaInicioDia {
    // Día 1 (index 0): usar hora de inicio del viaje si existe
    if (diaSeleccionadoIndex == 0 && horaInicioViaje != null) {
      return horaInicioViaje!;
    }
    // Otros días: 6:00 AM
    return DateTime(2024, 1, 1, 6, 0);
  }

  DateTime get horaFinDia {
    // Último día: usar hora de fin del viaje si existe
    if (diaSeleccionadoIndex == totalDias - 1 && horaFinViaje != null) {
      return horaFinViaje!;
    }
    // Otros días: 10:00 PM
    return DateTime(2024, 1, 1, 22, 0);
  }

  // Getter útil para la UI
  List<ActividadItinerario> get actividadesDelDiaActual =>
      actividadesPorDia[diaSeleccionadoIndex] ?? [];

  // ✨ NUEVO: Calcular tiempo restante en minutos
  int get tiempoRestanteHoy {
    final actividades = actividadesDelDiaActual;
    if (actividades.isEmpty) {
      // Tiempo total disponible
      return horaFinDia.difference(horaInicioDia).inMinutes;
    }

    // Tiempo desde la última actividad hasta el fin del día
    final ultimaHoraFin = actividades.last.horaFin;
    return horaFinDia.difference(ultimaHoraFin).inMinutes;
  }

  // ✨ NUEVO: Tiempo usado en minutos
  int get tiempoUsadoHoy {
    final actividades = actividadesDelDiaActual;
    if (actividades.isEmpty) return 0;

    // Desde inicio del día hasta fin de última actividad
    return actividades.last.horaFin.difference(horaInicioDia).inMinutes;
  }

  ItineraryBuilderState copyWith({
    int? diaSeleccionadoIndex,
    int? totalDias,
    Map<int, List<ActividadItinerario>>? actividadesPorDia,
    DateTime? horaInicioViaje,
    DateTime? horaFinViaje,
    String? errorMessage,
  }) {
    return ItineraryBuilderState(
      diaSeleccionadoIndex: diaSeleccionadoIndex ?? this.diaSeleccionadoIndex,
      totalDias: totalDias ?? this.totalDias,
      actividadesPorDia: actividadesPorDia ?? this.actividadesPorDia,
      horaInicioViaje: horaInicioViaje ?? this.horaInicioViaje,
      horaFinViaje: horaFinViaje ?? this.horaFinViaje,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    diaSeleccionadoIndex,
    totalDias,
    actividadesPorDia,
    horaInicioViaje,
    horaFinViaje,
    errorMessage,
  ];
}
