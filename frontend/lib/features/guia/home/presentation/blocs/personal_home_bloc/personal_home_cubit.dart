import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/personal_home_data.dart';

import '../../../domain/usecases/get_personal_home_data_usecase.dart';

// ── Estados ───────────────────────────────────────────────────────────────────

enum FiltroEstado { todas, pendientes, completadas }

abstract class PersonalHomeState extends Equatable {
  const PersonalHomeState();
  @override
  List<Object?> get props => [];
}

class PersonalHomeLoading extends PersonalHomeState {}

class PersonalHomeError extends PersonalHomeState {
  final String message;
  const PersonalHomeError(this.message);

  @override
  List<Object?> get props => [message];
}

class PersonalHomeLoaded extends PersonalHomeState {
  final PersonalHomeData data;
  final bool modoExplorador;
  final FiltroEstado filtroActivo;

  const PersonalHomeLoaded({
    required this.data,
    this.modoExplorador = false,
    this.filtroActivo = FiltroEstado.todas,
  });

  PersonalHomeLoaded copyWith({
    PersonalHomeData? data,
    bool? modoExplorador,
    FiltroEstado? filtroActivo,
  }) {
    return PersonalHomeLoaded(
      data: data ?? this.data,
      modoExplorador: modoExplorador ?? this.modoExplorador,
      filtroActivo: filtroActivo ?? this.filtroActivo,
    );
  }

  @override
  List<Object?> get props => [data, modoExplorador, filtroActivo];
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

class PersonalHomeCubit extends Cubit<PersonalHomeState> {
  final GetPersonalHomeDataUseCase getPersonalHomeDataUseCase;

  PersonalHomeCubit({required this.getPersonalHomeDataUseCase})
    : super(PersonalHomeLoading());

  Future<void> cargarDatos(String nombre) async {
    try {
      emit(PersonalHomeLoading());
      final data = await getPersonalHomeDataUseCase(nombre);
      emit(PersonalHomeLoaded(data: data));
    } catch (e) {
      emit(PersonalHomeError(e.toString()));
    }
  }

  void toggleModoExplorador() {
    final s = state;
    if (s is PersonalHomeLoaded) {
      emit(s.copyWith(modoExplorador: !s.modoExplorador));
    }
  }

  void cambiarGeocerca(int metros) {
    final s = state;
    if (s is PersonalHomeLoaded) {
      emit(s.copyWith(data: s.data.copyWith(geocercaMetros: metros)));
    }
  }

  void cambiarFiltro(FiltroEstado nuevoFiltro) {
    final s = state;
    if (s is PersonalHomeLoaded) {
      emit(s.copyWith(filtroActivo: nuevoFiltro));
    }
  }
}
