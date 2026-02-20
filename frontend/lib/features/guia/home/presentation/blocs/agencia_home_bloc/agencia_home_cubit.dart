import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ── Enums ─────────────────────────────────────────────────────────────────────

enum EstadoParticipante { sincronizado, offline, alerta }

// ── Modelos mock ──────────────────────────────────────────────────────────────

class ParticipanteMock extends Equatable {
  final String nombre;
  final EstadoParticipante estado;

  const ParticipanteMock({required this.nombre, required this.estado});

  @override
  List<Object?> get props => [nombre, estado];
}

class AlertaHistorial extends Equatable {
  final String descripcion;
  final String hora;

  const AlertaHistorial({required this.descripcion, required this.hora});

  @override
  List<Object?> get props => [descripcion, hora];
}

// ── Estados ───────────────────────────────────────────────────────────────────

abstract class AgenciaHomeState extends Equatable {
  const AgenciaHomeState();
  @override
  List<Object?> get props => [];
}

class AgenciaHomeLoading extends AgenciaHomeState {}

class AgenciaHomeLoaded extends AgenciaHomeState {
  final String nombreViaje;
  final String folio;
  final String destino;
  final int totalParticipantes;
  final List<ParticipanteMock> participantes;
  final List<AlertaHistorial> historialAlertas;
  final String geocercaRadio; // descripción legible de la geocerca

  const AgenciaHomeLoaded({
    required this.nombreViaje,
    required this.folio,
    required this.destino,
    required this.totalParticipantes,
    required this.participantes,
    required this.historialAlertas,
    required this.geocercaRadio,
  });

  int get sincronizados =>
      participantes
          .where((p) => p.estado == EstadoParticipante.sincronizado)
          .length;
  int get offline =>
      participantes.where((p) => p.estado == EstadoParticipante.offline).length;
  int get enAlerta =>
      participantes.where((p) => p.estado == EstadoParticipante.alerta).length;

  @override
  List<Object?> get props => [nombreViaje, folio, destino, totalParticipantes];
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

class AgenciaHomeCubit extends Cubit<AgenciaHomeState> {
  AgenciaHomeCubit() : super(AgenciaHomeLoading());

  Future<void> cargarDatos(String folio) async {
    await Future.delayed(const Duration(milliseconds: 700));
    emit(
      AgenciaHomeLoaded(
        nombreViaje: 'Tour Teotihuacán 2026',
        folio: folio,
        destino: 'Teotihuacán, Estado de México',
        totalParticipantes: 24,
        geocercaRadio: '300 m · Zona Arqueológica',
        participantes: const [
          ParticipanteMock(
            nombre: 'María García',
            estado: EstadoParticipante.sincronizado,
          ),
          ParticipanteMock(
            nombre: 'Carlos López',
            estado: EstadoParticipante.sincronizado,
          ),
          ParticipanteMock(
            nombre: 'Ana Martínez',
            estado: EstadoParticipante.offline,
          ),
          ParticipanteMock(
            nombre: 'Roberto Silva',
            estado: EstadoParticipante.sincronizado,
          ),
          ParticipanteMock(
            nombre: 'Sofía Ramírez',
            estado: EstadoParticipante.alerta,
          ),
          ParticipanteMock(
            nombre: 'Luis Hernández',
            estado: EstadoParticipante.sincronizado,
          ),
          ParticipanteMock(
            nombre: 'Paola Torres',
            estado: EstadoParticipante.offline,
          ),
        ],
        historialAlertas: const [
          AlertaHistorial(
            descripcion: 'Ana Martínez salió de geocerca',
            hora: '09:42',
          ),
          AlertaHistorial(
            descripcion: 'Sofía Ramírez: batería crítica (<10%)',
            hora: '10:15',
          ),
          AlertaHistorial(
            descripcion: 'Paola Torres sin señal GPS',
            hora: '11:03',
          ),
        ],
      ),
    );
  }
}
