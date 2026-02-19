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

  // ✨ Días con modo horas extra habilitado (pueden usar horas del día siguiente)
  final Set<int> modoHorasExtraPorDia;

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
    this.modoHorasExtraPorDia = const {},
  });

  // ✨ Helper: Fecha base del día seleccionado (00:00 AM) con FECHA REAL
  DateTime get fechaBaseDiaActual {
    // Usar horaInicioViaje como base, o fallback a hoy si es null
    final base = horaInicioViaje ?? DateTime.now();
    final fechaDia = base.add(Duration(days: diaSeleccionadoIndex));
    // Normalizar a 00:00:00
    return DateTime(fechaDia.year, fechaDia.month, fechaDia.day);
  }

  // ✨ Getter: hora inicio del día actual
  // Prioridad: 1) Personalizado por usuario, 2) Hora del viaje (día 1), 3) Default 6AM
  DateTime get horaInicioDia {
    final fechaBase = fechaBaseDiaActual;

    // Primero: ¿el usuario personalizó este día?
    if (horasInicioPorDia.containsKey(diaSeleccionadoIndex)) {
      final personalizada = horasInicioPorDia[diaSeleccionadoIndex]!;
      // Mantener la fecha real del día, solo usar la hora personalizada
      return DateTime(
        fechaBase.year,
        fechaBase.month,
        fechaBase.day,
        personalizada.hour,
        personalizada.minute,
      );
    }

    // Segundo: Verificar herencia nocturna (continuidad con día anterior)
    if (diaSeleccionadoIndex > 0) {
      final actividadesAyer = actividadesPorDia[diaSeleccionadoIndex - 1] ?? [];
      if (actividadesAyer.isNotEmpty) {
        final ultimaAyer = actividadesAyer.last;
        // Si la última actividad de ayer termina DENTRO de hoy (madrugada)
        // Ejemplo: Ayer termina a las 01:30 AM de hoy.
        // ✨ FIX: Si termina exactamente en la medianoche (00:00:00 de hoy) TAMBIÉN debe contar.
        // Antes solo validaba isAfter, por lo que 00:00 daba false y ponía 6:00 AM.
        if (ultimaAyer.horaFin.isAfter(fechaBase) ||
            ultimaAyer.horaFin.isAtSameMomentAs(fechaBase)) {
          // El inicio de hoy debe coincidir con el fin de ayer para dar continuidad
          return ultimaAyer.horaFin;
        }
      }
    }

    // Día 1 (index 0): usar hora de inicio del viaje si existe
    if (diaSeleccionadoIndex == 0 && horaInicioViaje != null) {
      return horaInicioViaje!;
    }

    // ✨ FIX: Último día con hora de fin en madrugada (ej: viaje termina 1:00 AM)
    // Si horaFinViaje es madrugada (hora < 6), el día "empieza" a medianoche (00:00)
    // para que la ventana de tiempo sea coherente (00:00 → 1:00 AM).
    if (diaSeleccionadoIndex == totalDias - 1 && horaFinViaje != null) {
      if (horaFinViaje!.hour < 6) {
        // El viaje termina en madrugada: el inicio del último día es medianoche
        return DateTime(fechaBase.year, fechaBase.month, fechaBase.day, 0, 0);
      }
    }

    // Otros días: 6:00 AM por defecto
    return DateTime(fechaBase.year, fechaBase.month, fechaBase.day, 6, 0);
  }

  // ✨ Getter: hora fin del día actual
  // Prioridad: 1) Personalizado por usuario, 2) Hora del viaje (último día),
  //            3) horaInicio+2h si es Día 1, 4) Default 10PM
  DateTime get horaFinDia {
    DateTime candidata;
    final fechaBase = fechaBaseDiaActual;
    // ✨ FIX: Rastrear si candidata viene de horaFinViaje (fuente de verdad absoluta)
    bool esHoraFinViaje = false;
    // ✨ FIX: Rastrear si candidata fue limitada al tope del día (23:59)
    // para que el GUARD no la empuje al día siguiente.
    bool esTopeDia = false;

    // Primero: ¿el usuario personalizó este día?
    if (horasFinPorDia.containsKey(diaSeleccionadoIndex)) {
      final personalizada = horasFinPorDia[diaSeleccionadoIndex]!;
      candidata = DateTime(
        fechaBase.year,
        fechaBase.month,
        fechaBase.day,
        personalizada.hour,
        personalizada.minute,
      );
    }
    // Último día (o único día): usar hora de fin del viaje si existe
    else if (diaSeleccionadoIndex == totalDias - 1 && horaFinViaje != null) {
      candidata = horaFinViaje!;
      esHoraFinViaje = true; // fuente de verdad absoluta, nunca sobreescribir
    }
    // Día 1 (si NO es el último día) sin personalización: usar horaInicioViaje + 2h
    // para evitar que el default de 10PM quede por debajo de una hora de inicio tardía.
    else if (diaSeleccionadoIndex == 0 && horaInicioViaje != null) {
      final sugerida = horaInicioViaje!.add(const Duration(hours: 2));
      // Si pasa de las 23:59, usar 23:59 como tope del MISMO día base.
      // ✨ FIX: Comparar usando fecha completa, no solo .day (evita bug fin de mes).
      // También marcamos esTopeDia=true para que el GUARD no la empuje al día siguiente.
      final topeDia = DateTime(
        horaInicioViaje!.year,
        horaInicioViaje!.month,
        horaInicioViaje!.day,
        23,
        59,
      );
      if (sugerida.isAfter(topeDia)) {
        candidata = topeDia;
        esTopeDia =
            true; // ✨ FIX: ya es el máximo posible, no cruzar medianoche
      } else {
        candidata = sugerida;
      }
    }
    // Otros días intermedios: 10:00 PM por defecto
    else {
      candidata = DateTime(
        fechaBase.year,
        fechaBase.month,
        fechaBase.day,
        22,
        0,
      );
    }

    // 🛡️ GUARD: horaFin NUNCA puede ser <= horaInicio (seguridad final)
    // ✨ FIX: NO aplicar el guard si:
    //   - candidata viene de horaFinViaje (fuente de verdad del formulario), O
    //   - candidata ya fue limitada al tope del día (23:59): empujarla más cruzaría medianoche.
    if (!esHoraFinViaje && !esTopeDia) {
      final inicio = horaInicioDia;
      if (!candidata.isAfter(inicio)) {
        return inicio.add(const Duration(hours: 2));
      }
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
  // Normaliza la hora de fin de la última actividad al día base (2024-01-01)
  // para evitar diferencias de 32h cuando las actividades usan DateTime(2024,1,2,...)
  int get tiempoRestanteHoy {
    final actividades = actividadesDelDiaActual;
    if (actividades.isEmpty) {
      return horaFinDia.difference(horaInicioDia).inMinutes;
    }
    // Diferencia directa con fechas reales
    return horaFinDia.difference(actividades.last.horaFin).inMinutes;
  }

  // Tiempo usado en minutos (normalizado)
  int get tiempoUsadoHoy {
    final actividades = actividadesDelDiaActual;
    if (actividades.isEmpty) return 0;
    // Diferencia directa con fechas reales
    return actividades.last.horaFin.difference(horaInicioDia).inMinutes;
  }

  // ¿El día actual tiene actividades que usan horas del día siguiente (nocturnas)?
  bool get actividadesUsanHorasNocturnas {
    final actividades = actividadesDelDiaActual;
    if (actividades.isEmpty) return false;

    final ultima = actividades.last;
    final fechaBase = fechaBaseDiaActual;

    // Es nocturna si termina después del día actual (comparando fecha YMD)
    final finYMD = DateTime(
      ultima.horaFin.year,
      ultima.horaFin.month,
      ultima.horaFin.day,
    );
    return finYMD.isAfter(fechaBase);
  }

  // ✨ Getter: actividad nocturna del día anterior que continúa en el día actual
  // Devuelve la ActividadItinerario del día anterior si su horaFin cae dentro del día actual.
  // Esto permite a la UI mostrar una "tarjeta de continuación" en el día siguiente.
  ActividadItinerario? get actividadNocturnaDelDiaAnterior {
    if (diaSeleccionadoIndex == 0) return null; // No hay día anterior

    final actividadesAyer = actividadesPorDia[diaSeleccionadoIndex - 1] ?? [];
    if (actividadesAyer.isEmpty) return null;

    final ultimaAyer = actividadesAyer.last;
    final fechaBaseHoy = fechaBaseDiaActual;

    // La actividad es "nocturna que continúa hoy" si su horaFin es posterior al inicio del día actual
    // (es decir, termina en la madrugada de hoy)
    if (ultimaAyer.horaFin.isAfter(fechaBaseHoy)) {
      return ultimaAyer;
    }
    return null;
  }

  // ¿El modo horas extra está activo para el día actual?
  bool get modoHorasExtraActivo =>
      modoHorasExtraPorDia.contains(diaSeleccionadoIndex);

  // ¿Se pueden agregar más actividades al día actual?
  // Solo si: hay tiempo restante O el modo horas extra está activo
  bool get puedeAgregarActividades {
    if (tiempoRestanteHoy > 0) return true;

    // Si es el último día (o único), NO permite horas extra aunque el flag esté activo
    if (diaSeleccionadoIndex == totalDias - 1) return false;

    if (actividadesUsanHorasNocturnas) return false; // ya en modo nocturno
    return modoHorasExtraActivo;
  }

  ItineraryBuilderState copyWith({
    int? diaSeleccionadoIndex,
    int? totalDias,
    Map<int, List<ActividadItinerario>>? actividadesPorDia,
    DateTime? horaInicioViaje,
    DateTime? horaFinViaje,
    Map<int, DateTime>? horasInicioPorDia,
    Map<int, DateTime>? horasFinPorDia,
    Set<int>? modoHorasExtraPorDia,
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
      modoHorasExtraPorDia: modoHorasExtraPorDia ?? this.modoHorasExtraPorDia,
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
    // Convertir a lista ordenada para que Equatable compare por contenido
    modoHorasExtraPorDia.toList()..sort(),
    errorMessage,
  ];
}
