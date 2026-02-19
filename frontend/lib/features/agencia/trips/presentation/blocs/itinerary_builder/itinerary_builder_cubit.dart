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

  // ✨ Establecer hora de fin personalizada para un día.
  // AUMENTAR: siempre permitido. Si horas extra activas y última actividad ya
  //           cabe en el nuevo límite → desactiva horas extra automáticamente.
  // DISMINUIR: bloqueado si cualquier actividad (regular o extra) termina
  //            después de la nueva hora fin.
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
      // CASO A: Ya hay actividades hoy → buffer adaptativo después de la última
      // El buffer normal es 30 min, pero si el tiempo restante es escaso,
      // lo reducimos para que Smart Sizing pueda ajustar la duración.
      final ultimaFin = listaActual.last.horaFin;
      final limiteDelDia = state.horaFinDia;
      final minutosRestantesSinBuffer =
          limiteDelDia.difference(ultimaFin).inMinutes;

      // Buffer adaptativo: 30 min normalmente, pero reducido si hay poco tiempo
      // Mínimo 0 min (actividad inmediatamente después de la anterior)
      final int bufferMinutos;
      if (minutosRestantesSinBuffer <= 5) {
        // Sin espacio ni para el buffer mínimo → bloquear (Smart Sizing lo manejará)
        bufferMinutos = 30;
      } else if (minutosRestantesSinBuffer <= 35) {
        // Poco tiempo: buffer reducido a 0 para maximizar espacio disponible
        bufferMinutos = 0;
      } else if (minutosRestantesSinBuffer <= 60) {
        // Tiempo moderado: buffer reducido a 10 min
        bufferMinutos = 10;
      } else {
        // Tiempo suficiente: buffer normal de 30 min
        bufferMinutos = 30;
      }

      horaInicio = ultimaFin.add(Duration(minutes: bufferMinutos));
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

    // 3. Validación: Smart Sizing dentro del límite vigente
    final limiteBase = state.horaFinDia;
    final esUltimoDia = dia == state.totalDias - 1;

    // Límite extendido SOLO si el usuario ya lo activó manualmente
    final limiteExtendido =
        (!esUltimoDia) ? limiteBase.add(const Duration(hours: 3)) : limiteBase;

    // Nunca auto-activamos horas extra: el usuario decide manualmente
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
        // Smart Sizing: recortar duración al tiempo disponible
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

    emit(state.copyWith(actividadesPorDia: nuevoMapa, errorMessage: null));

    // ✨ Autodesactivar si aplica
    _verificarDesactivarHorasExtra(dia, listaActual);
  }

  // Método público para verificar si una actividad cabe en el horario
  // Método público para verificar si una actividad cabe en el horario
  bool wouldActivityFit(TipoActividad tipo) {
    if (!state.puedeAgregarActividades) return false;

    final int dia = state.diaSeleccionadoIndex;
    final List<ActividadItinerario> listaActual = state.actividadesDelDiaActual;
    final fechaBaseDelDia = state.fechaBaseDiaActual;

    DateTime horaInicio;
    if (listaActual.isNotEmpty) {
      // ✨ Buffer adaptativo (igual que onActivityDropped)
      final ultimaFin = listaActual.last.horaFin;
      final limiteDelDia = state.horaFinDia;
      final minutosRestantesSinBuffer =
          limiteDelDia.difference(ultimaFin).inMinutes;

      final int bufferMinutos;
      if (minutosRestantesSinBuffer <= 5) {
        bufferMinutos = 30; // Sin espacio: Smart Sizing lo bloqueará
      } else if (minutosRestantesSinBuffer <= 35) {
        bufferMinutos = 0; // Poco tiempo: sin buffer
      } else if (minutosRestantesSinBuffer <= 60) {
        bufferMinutos = 10; // Tiempo moderado: buffer reducido
      } else {
        bufferMinutos = 30; // Normal
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

    final int duracionMinutos = (tipo == TipoActividad.traslado) ? 60 : 90;
    final DateTime horaFin = horaInicio.add(Duration(minutes: duracionMinutos));

    final limiteBase = state.horaFinDia;
    final esUltimoDia = dia == state.totalDias - 1;
    final limiteAbsoluto =
        (!esUltimoDia) ? limiteBase.add(const Duration(hours: 3)) : limiteBase;

    if (horaFin.isBefore(limiteAbsoluto) ||
        horaFin.isAtSameMomentAs(limiteAbsoluto)) {
      return true;
    }

    // Smart Sizing: ¿quedan al menos 5 min?
    final minutosDisponibles = limiteAbsoluto.difference(horaInicio).inMinutes;
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

  // 🗑️ SINCRONIZACIÓN NOCTURNA: Eliminar actividad de un día específico
  // Usado cuando el usuario elimina una actividad nocturna desde la tarjeta de continuación
  // del día siguiente (la actividad vive en el día anterior, no en el actual).
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

    // ✨ Autodesactivar modo horas extra si ya no hay actividades nocturnas
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
