import 'package:equatable/equatable.dart';
import '../../../trips/domain/entities/actividad_itinerario.dart';
import 'package:frontend/features/agencia/users/domain/entities/turista.dart';
export '../../../trips/domain/entities/actividad_itinerario.dart';
export 'package:frontend/features/agencia/users/domain/entities/turista.dart';

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

class PersonalHomeData extends Equatable {
  final String nombreGuia;
  final String nombreViaje;
  final String destino;
  final DateTime horaInicio;
  final int participantes;
  final bool viajeActivo;
  final int geocercaMetros;
  final double kmRecorridos;
  final int minActivos;
  final double altitudActualM;
  final double huellaCarbono;
  final List<ContactoEmergencia> contactos;
  final List<ActividadItinerario> actividades;
  final List<Turista> listaTuristas;

  const PersonalHomeData({
    required this.nombreGuia,
    required this.nombreViaje,
    required this.destino,
    required this.horaInicio,
    required this.participantes,
    this.viajeActivo = true,
    this.geocercaMetros = 200,
    this.kmRecorridos = 0,
    this.minActivos = 0,
    this.altitudActualM = 0,
    this.huellaCarbono = 0,
    required this.contactos,
    required this.actividades,
    this.listaTuristas = const [],
  });

  PersonalHomeData copyWith({
    String? nombreGuia,
    String? nombreViaje,
    String? destino,
    DateTime? horaInicio,
    int? participantes,
    bool? viajeActivo,
    int? geocercaMetros,
    double? kmRecorridos,
    int? minActivos,
    double? altitudActualM,
    double? huellaCarbono,
    List<ContactoEmergencia>? contactos,
    List<ActividadItinerario>? actividades,
    List<Turista>? listaTuristas,
  }) {
    return PersonalHomeData(
      nombreGuia: nombreGuia ?? this.nombreGuia,
      nombreViaje: nombreViaje ?? this.nombreViaje,
      destino: destino ?? this.destino,
      horaInicio: horaInicio ?? this.horaInicio,
      participantes: participantes ?? this.participantes,
      viajeActivo: viajeActivo ?? this.viajeActivo,
      geocercaMetros: geocercaMetros ?? this.geocercaMetros,
      kmRecorridos: kmRecorridos ?? this.kmRecorridos,
      minActivos: minActivos ?? this.minActivos,
      altitudActualM: altitudActualM ?? this.altitudActualM,
      huellaCarbono: huellaCarbono ?? this.huellaCarbono,
      contactos: contactos ?? this.contactos,
      actividades: actividades ?? this.actividades,
      listaTuristas: listaTuristas ?? this.listaTuristas,
    );
  }

  @override
  List<Object?> get props => [
    nombreGuia,
    nombreViaje,
    destino,
    geocercaMetros,
    viajeActivo,
    listaTuristas,
  ];
}
