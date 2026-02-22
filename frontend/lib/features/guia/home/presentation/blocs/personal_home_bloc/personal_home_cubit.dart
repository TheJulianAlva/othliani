import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/personal_home_data.dart';
import '../../../domain/usecases/get_personal_home_data_usecase.dart';

// ── Estados ───────────────────────────────────────────────────────────────────

abstract class PersonalHomeState extends Equatable {
  const PersonalHomeState();
  @override
  List<Object?> get props => [];
}

class PersonalHomeLoading extends PersonalHomeState {}

class PersonalHomeLoaded extends PersonalHomeState {
  final String nombreGuia;
  final String nombreViaje;
  final String destino;
  final String horaInicio;
  final int participantes;
  final bool viajeActivo;
  final bool modoExplorador;
  final int geocercaMetros; // 50, 200 o 500
  // Estadísticas
  final double kmRecorridos;
  final int minActivos;
  final double altitudActualM;
  final double huellaCarbono; // kg CO₂ estimado
  // Contactos y actividades
  final List<ContactoEmergencia> contactos;
  final List<ActividadItinerario> actividades;

  const PersonalHomeLoaded({
    required this.nombreGuia,
    required this.nombreViaje,
    required this.destino,
    required this.horaInicio,
    required this.participantes,
    this.viajeActivo = true,
    this.modoExplorador = false,
    this.geocercaMetros = 200,
    this.kmRecorridos = 0,
    this.minActivos = 0,
    this.altitudActualM = 0,
    this.huellaCarbono = 0,
    required this.contactos,
    required this.actividades,
  });

  PersonalHomeLoaded copyWith({bool? modoExplorador, int? geocercaMetros}) {
    return PersonalHomeLoaded(
      nombreGuia: nombreGuia,
      nombreViaje: nombreViaje,
      destino: destino,
      horaInicio: horaInicio,
      participantes: participantes,
      viajeActivo: viajeActivo,
      modoExplorador: modoExplorador ?? this.modoExplorador,
      geocercaMetros: geocercaMetros ?? this.geocercaMetros,
      kmRecorridos: kmRecorridos,
      minActivos: minActivos,
      altitudActualM: altitudActualM,
      huellaCarbono: huellaCarbono,
      contactos: contactos,
      actividades: actividades,
    );
  }

  @override
  List<Object?> get props => [
    nombreGuia,
    nombreViaje,
    modoExplorador,
    geocercaMetros,
  ];
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
      emit(
        PersonalHomeLoaded(
          nombreGuia: data.nombreGuia,
          nombreViaje: data.nombreViaje,
          destino: data.destino,
          horaInicio: data.horaInicio,
          participantes: data.participantes,
          kmRecorridos: data.kmRecorridos,
          minActivos: data.minActivos,
          altitudActualM: data.altitudActualM,
          huellaCarbono: data.huellaCarbono,
          geocercaMetros: data.geocercaMetros,
          contactos: data.contactos,
          actividades: data.actividades,
        ),
      );
    } catch (e) {
      // Manejo error
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
      emit(s.copyWith(geocercaMetros: metros));
    }
  }
}
