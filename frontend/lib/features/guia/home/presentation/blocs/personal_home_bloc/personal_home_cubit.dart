import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ── Modelos mock ──────────────────────────────────────────────────────────────

class ContactoEmergencia extends Equatable {
  final String nombre;
  final String relacion;
  final String telefono;

  const ContactoEmergencia({
    required this.nombre,
    required this.relacion,
    required this.telefono,
  });

  @override
  List<Object?> get props => [nombre, telefono];
}

class ActividadItinerario extends Equatable {
  final String nombre;
  final String horaInicio;
  final String horaFin;
  final bool completada;

  const ActividadItinerario({
    required this.nombre,
    required this.horaInicio,
    required this.horaFin,
    required this.completada,
  });

  @override
  List<Object?> get props => [nombre, horaInicio, completada];
}

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
  PersonalHomeCubit() : super(PersonalHomeLoading());

  Future<void> cargarDatos(String nombre) async {
    await Future.delayed(const Duration(milliseconds: 700));
    emit(
      PersonalHomeLoaded(
        nombreGuia: nombre,
        nombreViaje: 'Ruta Mazunte – Costa Oaxaqueña',
        destino: 'Puerto Escondido, Oaxaca',
        horaInicio: '08:00 AM',
        participantes: 12,
        kmRecorridos: 14.3,
        minActivos: 187,
        altitudActualM: 42,
        huellaCarbono: 3.7,
        geocercaMetros: 200,
        contactos: const [
          ContactoEmergencia(
            nombre: 'Elena Morales',
            relacion: 'Esposa',
            telefono: '722 100 2030',
          ),
          ContactoEmergencia(
            nombre: 'Javier Cruz',
            relacion: 'Hermano',
            telefono: '55 8800 1122',
          ),
          ContactoEmergencia(
            nombre: 'SEDENA Región',
            relacion: 'Autoridad',
            telefono: '800 900 0000',
          ),
        ],
        actividades: const [
          ActividadItinerario(
            nombre: 'Salida del hotel',
            horaInicio: '08:00',
            horaFin: '08:30',
            completada: true,
          ),
          ActividadItinerario(
            nombre: 'Snorkel en Punta Zicatela',
            horaInicio: '09:00',
            horaFin: '11:00',
            completada: true,
          ),
          ActividadItinerario(
            nombre: 'Almuerzo en Restaurante Playa',
            horaInicio: '12:00',
            horaFin: '13:30',
            completada: false,
          ),
          ActividadItinerario(
            nombre: 'Visita Barra de Navidad',
            horaInicio: '14:00',
            horaFin: '16:00',
            completada: false,
          ),
        ],
      ),
    );
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
