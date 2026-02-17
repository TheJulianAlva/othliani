import 'package:flutter/material.dart'; // Para DateTimeRange
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/viaje.dart';
import '../../../domain/repositories/trip_repository.dart';

// Events
abstract class ViajesEvent extends Equatable {
  const ViajesEvent(); // Usar const constructor
  @override
  List<Object?> get props => [];
}

class LoadViajesEvent extends ViajesEvent {
  final String query;
  final String field; // 'TODO', 'GUIA', 'DESTINO', 'ID'
  final String? filterStatus;
  final DateTimeRange? filterDateRange;

  const LoadViajesEvent({
    this.query = '',
    this.field = 'TODO',
    this.filterStatus = 'TODOS',
    this.filterDateRange,
  });

  @override
  List<Object?> get props => [query, field, filterStatus, filterDateRange];
}

// States
abstract class ViajesState extends Equatable {
  const ViajesState();
}

class ViajesInitial extends ViajesState {
  @override
  List<Object?> get props => [];
}

class ViajesLoading extends ViajesState {
  @override
  List<Object?> get props => [];
}

class ViajesLoaded extends ViajesState {
  final List<Viaje> viajes;
  const ViajesLoaded(this.viajes);
  @override
  List<Object?> get props => [viajes];
}

class ViajesError extends ViajesState {
  final String message;
  const ViajesError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class ViajesBloc extends Bloc<ViajesEvent, ViajesState> {
  final TripRepository repository;
  List<Viaje> _allViajes = []; // Cache local

  ViajesBloc({required this.repository}) : super(ViajesInitial()) {
    on<LoadViajesEvent>(_onLoadViajes);
  }

  Future<void> _onLoadViajes(
    LoadViajesEvent event,
    Emitter<ViajesState> emit,
  ) async {
    emit(ViajesLoading());

    // 1. Cargar datos si no hay cache (o si se quisiera forzar recarga)
    if (_allViajes.isEmpty) {
      final result = await repository.getListaViajes();
      result.fold(
        (failure) => emit(const ViajesError('Error al cargar viajes')),
        (viajes) => _allViajes = viajes,
      );
    }

    // Si falló la carga inicial y no hay datos, emitir error y salir
    if (_allViajes.isEmpty && state is ViajesError) return;

    // 2. APLICAR FILTROS EN MEMORIA
    List<Viaje> filtered =
        _allViajes.where((viaje) {
          // A. Filtro de Texto (Destino, ID o Guía según 'field')
          final q = event.query.toLowerCase();
          final field = event.field; // 'TODO', 'GUIA', 'DESTINO', 'ID'

          bool matchesQuery = false;
          if (q.isEmpty) {
            matchesQuery = true;
          } else if (field == 'GUIA') {
            matchesQuery = viaje.guiaNombre.toLowerCase().contains(q);
          } else if (field == 'DESTINO') {
            matchesQuery = viaje.destino.toLowerCase().contains(q);
          } else if (field == 'ID') {
            matchesQuery = viaje.id.toLowerCase().contains(q);
          } else {
            matchesQuery =
                viaje.destino.toLowerCase().contains(q) ||
                viaje.id.toLowerCase().contains(q) ||
                viaje.guiaNombre.toLowerCase().contains(q);
          }

          // B. Filtro de Estatus
          final matchesStatus =
              event.filterStatus == 'TODOS' ||
              event.filterStatus == null ||
              viaje.estado == event.filterStatus;

          // C. FILTRO DE FECHA INTELIGENTE 📅 (Logística PRO con Rangos)
          // Muestra viajes que se SOLAPAN con el rango seleccionado
          bool matchesDate = true;
          if (event.filterDateRange != null) {
            final rango = event.filterDateRange!;

            // Normalizamos rango filtro (Inicio 00:00, Fin 23:59:59)
            final rangoInicio = DateTime(
              rango.start.year,
              rango.start.month,
              rango.start.day,
            );
            final rangoFin = DateTime(
              rango.end.year,
              rango.end.month,
              rango.end.day,
              23,
              59,
              59,
            );

            // Viaje
            final viajeInicio = viaje.fechaInicio;
            final viajeFin = viaje.fechaFin;

            // Lógica de Solapamiento (Intersection)
            // (StartA <= EndB) and (EndA >= StartB)
            matchesDate =
                (viajeInicio.isBefore(rangoFin) ||
                    viajeInicio.isAtSameMomentAs(rangoFin)) &&
                (viajeFin.isAfter(rangoInicio) ||
                    viajeFin.isAtSameMomentAs(rangoInicio));
          }

          return matchesQuery && matchesStatus && matchesDate;
        }).toList();

    emit(ViajesLoaded(filtered));
  }
}
