import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/guia.dart';
import '../../../domain/entities/turista.dart';
import '../../../domain/repositories/agencia_repository.dart';

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
  final List<Turista> turistas;

  UsuariosLoaded({required this.guias, required this.turistas});

  @override
  List<Object> get props => [guias, turistas];
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

    // Load both guides and tourists in parallel
    final results = await Future.wait([
      repository.getListaGuias(),
      repository.getListaClientes(),
    ]);

    final guiasResult = results[0];
    final turistasResult = results[1];

    List<Guia> guiasList = [];
    List<Turista> turistasList = [];
    String? errorMessage;

    // Unpack results from Either
    guiasResult.fold(
      (failure) => errorMessage = "Error cargando guías",
      (data) => guiasList = data as List<Guia>,
    );

    turistasResult.fold(
      (failure) => errorMessage ??= "Error cargando turistas",
      (data) => turistasList = data as List<Turista>,
    );

    if (errorMessage != null) {
      emit(UsuariosError(errorMessage!));
    } else {
      emit(UsuariosLoaded(guias: guiasList, turistas: turistasList));
    }
  }
}
