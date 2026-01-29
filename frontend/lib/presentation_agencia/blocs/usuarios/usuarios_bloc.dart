import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../domain/entities/guia.dart';
import '../../../../domain/repositories/agencia_repository.dart';

// Events
abstract class UsuariosEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadUsuariosEvent extends UsuariosEvent {}

// States
abstract class UsuariosState extends Equatable {
  @override
  List<Object> get props => [];
}

class UsuariosInitial extends UsuariosState {}

class UsuariosLoading extends UsuariosState {}

class UsuariosLoaded extends UsuariosState {
  final List<Guia> guias;
  UsuariosLoaded(this.guias);
  @override
  List<Object> get props => [guias];
}

class UsuariosError extends UsuariosState {
  final String message;
  UsuariosError(this.message);
  @override
  List<Object> get props => [message];
}

// BLoC
class UsuariosBloc extends Bloc<UsuariosEvent, UsuariosState> {
  final AgenciaRepository repository;

  UsuariosBloc({required this.repository}) : super(UsuariosInitial()) {
    on<LoadUsuariosEvent>(_onLoadUsuarios);
  }

  Future<void> _onLoadUsuarios(
    LoadUsuariosEvent event,
    Emitter<UsuariosState> emit,
  ) async {
    emit(UsuariosLoading());
    final result = await repository.getListaGuias();
    result.fold(
      (failure) => emit(UsuariosError('Error al cargar usuarios')),
      (guias) => emit(UsuariosLoaded(guias)),
    );
  }
}
