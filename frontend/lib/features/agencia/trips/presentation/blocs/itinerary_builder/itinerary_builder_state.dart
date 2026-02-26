part of 'itinerary_builder_cubit.dart';

class ItineraryBuilderState extends Equatable {
  final int diaSeleccionadoIndex; // 0 para Día 1, 1 para Día 2...
  final int totalDias; // Total de días del viaje

  // Mapa de actividades por día
  final Map<int, List<ActividadItinerario>> actividadesPorDia;

  // Fecha de inicio del viaje (solo para calcular la fecha real de cada día en los tabs)
  final DateTime? horaInicioViaje;
  final DateTime? horaFinViaje;

  // Mensaje de error opcional
  final String? errorMessage;

  // Fotos sugeridas al escribir el título de la actividad
  final List<String> imagenesSugeridas;

  // Flags de guardado
  final bool isSaving;
  final bool isSaved;

  // Categorías disponibles en el toolbox
  final List<CategoriaActividad> categorias;

  ItineraryBuilderState({
    this.diaSeleccionadoIndex = 0,
    this.totalDias = 1,
    this.actividadesPorDia = const {},
    this.errorMessage,
    this.horaInicioViaje,
    this.horaFinViaje,
    this.imagenesSugeridas = const [],
    this.isSaving = false,
    this.isSaved = false,
    List<CategoriaActividad>? categorias,
  }) : categorias = categorias ?? CategoriaActividad.defaults();

  // ── Fecha base del día seleccionado (00:00 AM) con FECHA REAL ──
  DateTime get fechaBaseDiaActual {
    final base = horaInicioViaje ?? DateTime.now();
    final fechaDia = base.add(Duration(days: diaSeleccionadoIndex));
    return DateTime(fechaDia.year, fechaDia.month, fechaDia.day);
  }

  // ── Actividades del día actual ──
  List<ActividadItinerario> get actividadesDelDiaActual =>
      actividadesPorDia[diaSeleccionadoIndex] ?? [];

  // ── Una actividad "sin horario" tiene horaInicio == horaFin (duración cero) ──
  bool actividadSinHorario(ActividadItinerario a) =>
      a.horaInicio.isAtSameMomentAs(a.horaFin);

  // ── ¿Alguna actividad en TODOS los días carece de horario? ──
  bool get hayActividadesSinHorario {
    for (final lista in actividadesPorDia.values) {
      for (final a in lista) {
        if (actividadSinHorario(a)) return true;
      }
    }
    return false;
  }

  // ── ¿Hay al menos una actividad en cualquier día? ──
  bool get hayAlgunaActividad =>
      actividadesPorDia.values.any((lista) => lista.isNotEmpty);

  // ── ¿Se puede guardar? Necesita actividades y todas con horario ──
  bool get puedeGuardar => hayAlgunaActividad && !hayActividadesSinHorario;

  // ── DateTime más temprano entre todas las actividades (para el inicio del viaje) ──
  DateTime? get derivedFechaInicio {
    DateTime? minDate;
    for (final lista in actividadesPorDia.values) {
      for (final a in lista) {
        if (!actividadSinHorario(a)) {
          if (minDate == null || a.horaInicio.isBefore(minDate)) {
            minDate = a.horaInicio;
          }
        }
      }
    }
    return minDate;
  }

  // ── DateTime más tardío entre todas las actividades (para el fin del viaje) ──
  DateTime? get derivedFechaFin {
    DateTime? maxDate;
    for (final lista in actividadesPorDia.values) {
      for (final a in lista) {
        if (!actividadSinHorario(a)) {
          if (maxDate == null || a.horaFin.isAfter(maxDate)) {
            maxDate = a.horaFin;
          }
        }
      }
    }
    return maxDate;
  }

  ItineraryBuilderState copyWith({
    int? diaSeleccionadoIndex,
    int? totalDias,
    Map<int, List<ActividadItinerario>>? actividadesPorDia,
    DateTime? horaInicioViaje,
    DateTime? horaFinViaje,
    String? errorMessage,
    List<String>? imagenesSugeridas,
    bool? isSaving,
    bool? isSaved,
    List<CategoriaActividad>? categorias,
  }) {
    return ItineraryBuilderState(
      diaSeleccionadoIndex: diaSeleccionadoIndex ?? this.diaSeleccionadoIndex,
      totalDias: totalDias ?? this.totalDias,
      actividadesPorDia: actividadesPorDia ?? this.actividadesPorDia,
      horaInicioViaje: horaInicioViaje ?? this.horaInicioViaje,
      horaFinViaje: horaFinViaje ?? this.horaFinViaje,
      errorMessage: errorMessage,
      imagenesSugeridas: imagenesSugeridas ?? this.imagenesSugeridas,
      isSaving: isSaving ?? this.isSaving,
      isSaved: isSaved ?? this.isSaved,
      categorias: categorias ?? this.categorias,
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
    imagenesSugeridas,
    isSaving,
    isSaved,
    categorias,
  ];
}
