import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../domain/entities/viaje.dart';
import '../../../../domain/repositories/agencia_repository.dart';

// Events
abstract class ViajesEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadViajesEvent extends ViajesEvent {
  final String? filter;
  LoadViajesEvent({this.filter});
  @override
  List<Object> get props => [filter ?? ''];
}

// States
abstract class ViajesState extends Equatable {
  @override
  List<Object> get props => [];
}

class ViajesInitial extends ViajesState {}

class ViajesLoading extends ViajesState {}

class ViajesLoaded extends ViajesState {
  final List<Viaje> viajes;
  ViajesLoaded(this.viajes);
  @override
  List<Object> get props => [viajes];
}

class ViajesError extends ViajesState {
  final String message;
  ViajesError(this.message);
  @override
  List<Object> get props => [message];
}

// BLoC
class ViajesBloc extends Bloc<ViajesEvent, ViajesState> {
  final AgenciaRepository repository;

  ViajesBloc({required this.repository}) : super(ViajesInitial()) {
    on<LoadViajesEvent>(_onLoadViajes);
  }

  Future<void> _onLoadViajes(
    LoadViajesEvent event,
    Emitter<ViajesState> emit,
  ) async {
    emit(ViajesLoading());
    final result = await repository.getListaViajes();
    result.fold(
      (failure) => emit(ViajesError('Error al cargar viajes')),
      (viajes) => emit(ViajesLoaded(viajes)),
    );
  }
}
