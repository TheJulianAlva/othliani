import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../domain/entities/viaje.dart';
import '../../../../domain/repositories/agencia_repository.dart';

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
  DetalleViajeLoaded(this.viaje);
  @override
  List<Object> get props => [viaje];
}

class DetalleViajeError extends DetalleViajeState {
  final String message;
  DetalleViajeError(this.message);
  @override
  List<Object> get props => [message];
}

// BLoC
class DetalleViajeBloc extends Bloc<DetalleViajeEvent, DetalleViajeState> {
  final AgenciaRepository repository;

  DetalleViajeBloc({required this.repository}) : super(DetalleViajeInitial()) {
    on<LoadDetalleViajeEvent>(_onLoadDetalleViaje);
  }

  Future<void> _onLoadDetalleViaje(
    LoadDetalleViajeEvent event,
    Emitter<DetalleViajeState> emit,
  ) async {
    emit(DetalleViajeLoading());
    final result = await repository.getDetalleViaje(event.id);
    result.fold(
      (failure) => emit(DetalleViajeError('Error al cargar detalle del viaje')),
      (viaje) => emit(DetalleViajeLoaded(viaje)),
    );
  }
}
