import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:frontend/features/agencia/trips/domain/entities/viaje.dart';
import 'package:frontend/features/agencia/users/domain/entities/turista.dart';
import 'package:frontend/features/agencia/trips/domain/repositories/trip_repository.dart';

// Events
abstract class DetalleViajeEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadDetalleViajeEvent extends DetalleViajeEvent {
  final String id;
  LoadDetalleViajeEvent({required this.id});
  @override
  List<Object> get props => [id];
}

// States
abstract class DetalleViajeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DetalleViajeInitial extends DetalleViajeState {}

class DetalleViajeLoading extends DetalleViajeState {}

class DetalleViajeLoaded extends DetalleViajeState {
  final Viaje viaje;
  final List<Turista> turistas;

  DetalleViajeLoaded({required this.viaje, required this.turistas});

  @override
  List<Object> get props => [viaje, turistas];
}

class DetalleViajeError extends DetalleViajeState {
  final String message;
  DetalleViajeError(this.message);
  @override
  List<Object> get props => [message];
}

// BLoC
class DetalleViajeBloc extends Bloc<DetalleViajeEvent, DetalleViajeState> {
  final TripRepository repository;

  DetalleViajeBloc({required this.repository}) : super(DetalleViajeInitial()) {
    on<LoadDetalleViajeEvent>(_onLoadDetalleViaje);
  }

  Future<void> _onLoadDetalleViaje(
    LoadDetalleViajeEvent event,
    Emitter<DetalleViajeState> emit,
  ) async {
    emit(DetalleViajeLoading());

    // Load trip details
    final viajeResult = await repository.getDetalleViaje(event.id);

    await viajeResult.fold(
      (failure) async {
        emit(DetalleViajeError('Error al cargar detalle del viaje'));
      },
      (viaje) async {
        // Load tourists for this trip
        final turistasResult = await repository.getTuristasPorViaje(event.id);

        turistasResult.fold(
          (failure) =>
              emit(DetalleViajeError('Error al cargar turistas del viaje')),
          (turistas) =>
              emit(DetalleViajeLoaded(viaje: viaje, turistas: turistas)),
        );
      },
    );
  }
}
