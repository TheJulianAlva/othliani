import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart'; // Para TimeOfDay
import 'package:frontend/features/agencia/trips/domain/entities/actividad_itinerario.dart';

part 'itinerary_builder_state.dart';

class ItineraryBuilderCubit extends Cubit<ItineraryBuilderState> {
  ItineraryBuilderCubit() : super(ItineraryBuilderState());

  // Inicializar con la duración del viaje y fechas reales
  void init(int duracionDias, {DateTime? fechaInicio, DateTime? fechaFin}) {
    emit(
      state.copyWith(
        totalDias: duracionDias,
        // Si vienen fechas nulas, el state usará DateTime.now() como base fallback
        horaInicioViaje: fechaInicio,
        horaFinViaje: fechaFin,
      ),
    );
  }

  void cambiarDia(int index) {
    if (index >= 0 && index < state.totalDias) {
      emit(state.copyWith(diaSeleccionadoIndex: index));
    }
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

  // ✨ NUEVO: Establecer hora de fin personalizada para un día
  // ✨ Corrección: Aceptar DateTime completo para manejar cruce de medianoche
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
    // Si no hay info, fallback a 6 AM del día correspondiente
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
    // Fallback a 10 PM del día correspondiente
    final base = state.horaInicioViaje ?? DateTime.now();
    final fechaDia = base.add(Duration(days: dia));
    return DateTime(fechaDia.year, fechaDia.month, fechaDia.day, 22, 0);
  }

  // Método para recibir el Drop de una actividad
  void onActivityDropped(TipoActividad tipo) {
    final int dia = state.diaSeleccionadoIndex;
    final List<ActividadItinerario> listaActual = List.from(
      state.actividadesDelDiaActual,
    );

    // 🚫 BLOQUEO: Si no hay tiempo y el modo horas extra no está activo
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

    // Fecha base del día actual con FECHA REAL
    final fechaBaseDelDia = state.fechaBaseDiaActual;

    // 1. CALCULAR HORA DE INICIO SUGERIDA (Smart Start)
    DateTime horaInicio;

    if (listaActual.isNotEmpty) {
      // CASO A: Ya hay actividades hoy → 30 min después de la última
      horaInicio = listaActual.last.horaFin.add(const Duration(minutes: 30));
    } else {
      // CASO B: Primera actividad del día → usar horaInicioDia
      final horaBase = state.horaInicioDia;
      horaInicio = DateTime(
        fechaBaseDelDia.year,
        fechaBaseDelDia.month,
        fechaBaseDelDia.day,
        horaBase.hour,
        horaBase.minute,
      );

      // 🚫 VALIDACIÓN: ¿El día anterior tiene actividad nocturna que aún está en curso?
      // 🚫 VALIDACIÓN: ¿El día anterior tiene actividad nocturna que aún está en curso?
      if (dia > 0) {
        final listaDiaAnterior = state.actividadesPorDia[dia - 1] ?? [];
        if (listaDiaAnterior.isNotEmpty) {
          final ultimaActAnterior = listaDiaAnterior.last;

          // Verificar solapamiento real usando fechas completas
          // Si la actividad anterior termina DESPUÉS del inicio propuesto para hoy
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

    // 2. Calcular hora de fin según tipo de actividad
    final int duracionMinutos = (tipo == TipoActividad.traslado) ? 60 : 90;
    DateTime horaFin = horaInicio.add(Duration(minutes: duracionMinutos));

    // 3. Validación: Smart Sizing + Auto-activación de Horas Extra
    final limiteBase = state.horaFinDia;
    final esUltimoDia = dia == state.totalDias - 1;

    // Límite Normal: Hasta fin de día configurado
    final limiteNormal = limiteBase;
    // Límite Extendido: Normal + 3h (solo si no es último día)
    final limiteExtendido =
        (!esUltimoDia) ? limiteBase.add(const Duration(hours: 3)) : limiteBase;

    bool activarHorasExtra = false;
    DateTime limiteEfectivo;

    // Lógica de decisión de límite y activación
    if (!state.modoHorasExtraActivo && !esUltimoDia) {
      // Si no está activo y es posible activarlo
      if (horaFin.isAfter(limiteNormal)) {
        // La actividad se pasa del límite normal.
        // ¿Cabe en el extendido (al menos 5 min)?
        final minutosEnExt = limiteExtendido.difference(horaInicio).inMinutes;
        if (minutosEnExt >= 5) {
          // SÍ: Activamos horas extra automáticamente
          activarHorasExtra = true;
          limiteEfectivo = limiteExtendido;
          debugPrint("AUTO-ACTIVANDO HORAS EXTRA para acomodar actividad");
        } else {
          // NO: No cabe ni con ayuda. Mantenemos límite normal para que falle el check abajo
          limiteEfectivo = limiteNormal;
        }
      } else {
        // Cabe en normal sin problemas
        limiteEfectivo = limiteNormal;
      }
    } else {
      // Ya activo o es último día: usamos el límite correspondiente al estado actual
      limiteEfectivo =
          state.modoHorasExtraActivo ? limiteExtendido : limiteNormal;
    }

    // DEBUG LOGS
    debugPrint("--- DEBUG SMART SIZING ---");
    debugPrint("Hora Inicio Propuesta: $horaInicio");
    debugPrint(
      "Limite Efectivo: $limiteEfectivo (Extra activado: $activarHorasExtra)",
    );
    debugPrint(
      "Minutos Disponibles (Calculado): ${limiteEfectivo.difference(horaInicio).inMinutes}",
    );

    if (horaFin.isAfter(limiteEfectivo)) {
      // Calcular espacio disponible
      // OJO: Puede ser negativo si el buffer de 30min ya nos sacó del día
      final minutosDisponibles =
          limiteEfectivo.difference(horaInicio).inMinutes;

      debugPrint("Minutos Disponibles (Smart Sizing): $minutosDisponibles");

      if (minutosDisponibles <= 0) {
        final limiteStr =
            "${limiteEfectivo.hour}:${limiteEfectivo.minute.toString().padLeft(2, '0')}";
        emit(
          state.copyWith(
            errorMessage:
                "No se puede agregar: El tiempo de traslado (30 min) empuja el inicio más allá del límite ($limiteStr).",
          ),
        );
        Future.delayed(const Duration(milliseconds: 3500), () {
          if (!isClosed) emit(state.copyWith(errorMessage: null));
        });
        return;
      }

      // Si hay al menos 5 minutos, ajustamos la duración
      if (minutosDisponibles >= 5) {
        debugPrint("AJUSTANDO: horaFin ahora es $limiteEfectivo");
        horaFin = limiteEfectivo;
      } else {
        // No cabe ni el mínimo
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

    // 4. Crear la nueva actividad
    final nuevaActividad = ActividadItinerario(
      id: const Uuid().v4(),
      titulo: _getTituloPorDefecto(tipo),
      descripcion: "Toca para editar detalles",
      horaInicio: horaInicio,
      horaFin: horaFin,
      tipo: tipo,
    );

    listaActual.add(nuevaActividad);

    // 5. Actualizar el mapa del estado
    final nuevoMapa = Map<int, List<ActividadItinerario>>.from(
      state.actividadesPorDia,
    );
    nuevoMapa[dia] = listaActual;

    final nuevoSetModo = Set<int>.from(state.modoHorasExtraPorDia);
    if (activarHorasExtra) {
      nuevoSetModo.add(dia);
    }

    emit(
      state.copyWith(
        actividadesPorDia: nuevoMapa,
        errorMessage: null,
        modoHorasExtraPorDia: nuevoSetModo,
      ),
    );

    // ✨ Autodesactivar si aplica
    _verificarDesactivarHorasExtra(dia, listaActual);
  }

  // Método público para verificar si una actividad cabe en el horario
  // Método público para verificar si una actividad cabe en el horario
  bool wouldActivityFit(TipoActividad tipo) {
    if (!state.puedeAgregarActividades) return false;

    // Simular lógica de onActivityDropped para calcular horaFin
    final int dia = state.diaSeleccionadoIndex;
    final List<ActividadItinerario> listaActual = state.actividadesDelDiaActual;
    final fechaBaseDelDia = state.fechaBaseDiaActual; // Fecha REAL

    DateTime horaInicio;
    if (listaActual.isNotEmpty) {
      horaInicio = listaActual.last.horaFin.add(const Duration(minutes: 30));
    } else {
      final horaBase = state.horaInicioDia;
      horaInicio = DateTime(
        fechaBaseDelDia.year,
        fechaBaseDelDia.month,
        fechaBaseDelDia.day,
        horaBase.hour,
        horaBase.minute,
      );

      // Check de solapamiento con día anterior (rápido)
      if (dia > 0) {
        final listaDiaAnterior = state.actividadesPorDia[dia - 1] ?? [];
        if (listaDiaAnterior.isNotEmpty &&
            listaDiaAnterior.last.horaFin.isAfter(horaInicio)) {
          // Solapamiento hard: no cabe
          return false;
        }
      }
    }

    final int duracionMinutos = (tipo == TipoActividad.traslado) ? 60 : 90;
    final DateTime horaFin = horaInicio.add(Duration(minutes: duracionMinutos));

    // Validar límite con Smart Sizing
    final limiteBase = state.horaFinDia;
    final esUltimoDia = dia == state.totalDias - 1;
    // Si NO es el último día, consideramos que SIEMPRE se puede extender
    final limiteAbsoluto =
        (!esUltimoDia) ? limiteBase.add(const Duration(hours: 3)) : limiteBase;

    // Si la actividad propuesta (con duración full) cabe, todo bien
    if (horaFin.isBefore(limiteAbsoluto) ||
        horaFin.isAtSameMomentAs(limiteAbsoluto)) {
      return true;
    }

    // Si se pasa, verificamos si hay espacio mínimo (Smart Sizing)
    final minutosDisponibles = limiteAbsoluto.difference(horaInicio).inMinutes;

    // Si quedan 5 mins libres en el peor de los casos (extendido o normal), aceptamos
    return minutosDisponibles >= 5;
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

      // ✨ Autodesactivar si aplica
      _verificarDesactivarHorasExtra(dia, lista);
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

    // ✨ Autodesactivar si aplica
    _verificarDesactivarHorasExtra(dia, lista);
  }

  // MÉTODO PRIVADO: Verifica si TODAS las actividades caben en el horario NORMAL.
  // Si caben, desactiva el modo "Horas Extra" automáticamente.
  void _verificarDesactivarHorasExtra(
    int dia,
    List<ActividadItinerario> actividades,
  ) {
    // Si no está activado, no hacer nada
    if (!state.modoHorasExtraPorDia.contains(dia)) return;

    // Si no hay actividades, desactivar (opcional, pero limpio)
    if (actividades.isEmpty) {
      final nuevoSet = Set<int>.from(state.modoHorasExtraPorDia)..remove(dia);
      emit(state.copyWith(modoHorasExtraPorDia: nuevoSet));
      return;
    }

    // Buscar la última hora fin de las actividades
    // (Asumimos que están ordenadas o buscamos el máximo)
    DateTime maxFin = actividades.first.horaFin;
    for (var a in actividades) {
      if (a.horaFin.isAfter(maxFin)) maxFin = a.horaFin;
    }

    // Hora fin NORMAL del día (sin extra)
    // Usamos el helper privado o asumimos que state.horaFinDia es para el día seleccionado
    // PERO state.horaFinDia depende de diaSeleccionadoIndex.
    // Si estamos modificando un día que NO es el seleccionado (raro, pero posible),
    // deberíamos tener cuidado. Pero las operaciones son sobre el día seleccionado.
    if (dia != state.diaSeleccionadoIndex) return;

    final finNormal = state.horaFinDia;

    // Si la última actividad termina ANTES o IGUAL al fin normal, desactivar.
    if (!maxFin.isAfter(finNormal)) {
      final nuevoSet = Set<int>.from(state.modoHorasExtraPorDia)..remove(dia);
      emit(state.copyWith(modoHorasExtraPorDia: nuevoSet));
    }
  }
}
