part of 'itinerary_builder_cubit.dart';

class ItineraryBuilderState extends Equatable {
  final int diaSeleccionadoIndex; // 0 para Día 1, 1 para Día 2...
  final int totalDias; // Total de días del viaje
  // Mapa de actividades por día
  final Map<int, List<ActividadItinerario>> actividadesPorDia;

  // Horas del viaje original (fijas, vienen del formulario de creación)
  final DateTime? horaInicioViaje; // Hora de inicio del viaje (fija para día 1)
  final DateTime? horaFinViaje; // Hora de fin del viaje (fija para último día)

  // ✨ NUEVO: Horarios personalizados por día (elegidos por el usuario)
  final Map<int, DateTime> horasInicioPorDia;
  final Map<int, DateTime> horasFinPorDia;

  // Mensaje de error opcional
  final String? errorMessage;

  const ItineraryBuilderState({
    this.diaSeleccionadoIndex = 0,
    this.totalDias = 1,
    this.actividadesPorDia = const {},
    this.errorMessage,
    this.horaInicioViaje,
    this.horaFinViaje,
    this.horasInicioPorDia = const {},
    this.horasFinPorDia = const {},
  });

  // ✨ Getter: hora inicio del día actual
  // Prioridad: 1) Personalizado por usuario, 2) Hora del viaje (día 1), 3) Default 6AM
  DateTime get horaInicioDia {
    // Primero: ¿el usuario personalizó este día?
    if (horasInicioPorDia.containsKey(diaSeleccionadoIndex)) {
      return horasInicioPorDia[diaSeleccionadoIndex]!;
    }
    // Día 1 (index 0): usar hora de inicio del viaje si existe
    if (diaSeleccionadoIndex == 0 && horaInicioViaje != null) {
      return horaInicioViaje!;
    }
    // Otros días: 6:00 AM por defecto
    return DateTime(2024, 1, 1, 6, 0);
  }

  // ✨ Getter: hora fin del día actual
  // Prioridad: 1) Personalizado por usuario, 2) Hora del viaje (último día),
  //            3) horaInicio+2h si es Día 1, 4) Default 10PM
  DateTime get horaFinDia {
    DateTime candidata;

    // Primero: ¿el usuario personalizó este día?
    if (horasFinPorDia.containsKey(diaSeleccionadoIndex)) {
      candidata = horasFinPorDia[diaSeleccionadoIndex]!;
    }
    // Último día (y no es el primero): usar hora de fin del viaje si existe
    else if (diaSeleccionadoIndex == totalDias - 1 &&
        diaSeleccionadoIndex != 0 &&
        horaFinViaje != null) {
      candidata = horaFinViaje!;
    }
    // Día 1 sin personalización: usar horaInicioViaje + 2h para evitar
    // que el default de 10PM quede por debajo de una hora de inicio tardía.
    // Tope máximo: 23:59 (no puede cruzar la medianoche)
    else if (diaSeleccionadoIndex == 0 && horaInicioViaje != null) {
      final sugerida = horaInicioViaje!.add(const Duration(hours: 2));
      // Si pasa de las 23:59, usar 23:59 como tope
      if (sugerida.hour < horaInicioViaje!.hour ||
          (sugerida.day > horaInicioViaje!.day)) {
        candidata = DateTime(2024, 1, 1, 23, 59);
      } else {
        candidata = sugerida;
      }
    }
    // Otros días intermedios: 10:00 PM por defecto
    else {
      candidata = DateTime(2024, 1, 1, 22, 0);
    }

    // 🛡️ GUARD: horaFin NUNCA puede ser <= horaInicio (seguridad final)
    final inicio = horaInicioDia;
    if (!candidata.isAfter(inicio)) {
      return inicio.add(const Duration(hours: 2));
    }
    return candidata;
  }

  // ✨ Helpers para saber si un campo es editable o fijo
  bool get esHoraInicioFija {
    // Es fija si: es el día 1 Y no hay personalización Y hay hora de inicio del viaje
    // O si es un viaje de 1 solo día
    if (horasInicioPorDia.containsKey(diaSeleccionadoIndex)) return false;
    return diaSeleccionadoIndex == 0 && horaInicioViaje != null;
  }

  bool get esHoraFinFija {
    // Es fija si: es el último día Y no hay personalización Y hay hora de fin del viaje
    // O si es un viaje de 1 solo día
    if (horasFinPorDia.containsKey(diaSeleccionadoIndex)) return false;
    return diaSeleccionadoIndex == totalDias - 1 && horaFinViaje != null;
  }

  // Getter útil para la UI
  List<ActividadItinerario> get actividadesDelDiaActual =>
      actividadesPorDia[diaSeleccionadoIndex] ?? [];

  // Calcular tiempo restante en minutos
  int get tiempoRestanteHoy {
    final actividades = actividadesDelDiaActual;
    if (actividades.isEmpty) {
      return horaFinDia.difference(horaInicioDia).inMinutes;
    }
    final ultimaHoraFin = actividades.last.horaFin;
    return horaFinDia.difference(ultimaHoraFin).inMinutes;
  }

  // Tiempo usado en minutos
  int get tiempoUsadoHoy {
    final actividades = actividadesDelDiaActual;
    if (actividades.isEmpty) return 0;
    return actividades.last.horaFin.difference(horaInicioDia).inMinutes;
  }

  ItineraryBuilderState copyWith({
    int? diaSeleccionadoIndex,
    int? totalDias,
    Map<int, List<ActividadItinerario>>? actividadesPorDia,
    DateTime? horaInicioViaje,
    DateTime? horaFinViaje,
    Map<int, DateTime>? horasInicioPorDia,
    Map<int, DateTime>? horasFinPorDia,
    String? errorMessage,
  }) {
    return ItineraryBuilderState(
      diaSeleccionadoIndex: diaSeleccionadoIndex ?? this.diaSeleccionadoIndex,
      totalDias: totalDias ?? this.totalDias,
      actividadesPorDia: actividadesPorDia ?? this.actividadesPorDia,
      horaInicioViaje: horaInicioViaje ?? this.horaInicioViaje,
      horaFinViaje: horaFinViaje ?? this.horaFinViaje,
      horasInicioPorDia: horasInicioPorDia ?? this.horasInicioPorDia,
      horasFinPorDia: horasFinPorDia ?? this.horasFinPorDia,
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
    horasInicioPorDia,
    horasFinPorDia,
    errorMessage,
  ];
}
