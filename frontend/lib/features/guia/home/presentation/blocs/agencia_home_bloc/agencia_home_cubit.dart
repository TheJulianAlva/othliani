import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/guia/trips/domain/entities/actividad_itinerario.dart';
import 'package:frontend/features/agencia/users/domain/entities/turista.dart';
import '../../../domain/entities/agencia_home_data.dart';
import '../../../domain/usecases/get_agencia_home_data_usecase.dart';

// ── Filtro compartido (mismo enum que PersonalHomeCubit) ─────────────────────
// TODO: Mover FiltroEstado a un archivo compartido si se desea unificar
enum FiltroEstadoAgencia { todas, pendientes, completadas }

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
  final List<Participante> participantes;
  final List<AlertaHistorial> historialAlertas;
  final String geocercaRadio; // descripción legible de la geocerca
  final List<ActividadItinerario> actividades;
  final List<Turista> listaTuristas;
  final FiltroEstadoAgencia filtroActivo;

  const AgenciaHomeLoaded({
    required this.nombreViaje,
    required this.folio,
    required this.destino,
    required this.totalParticipantes,
    required this.participantes,
    required this.historialAlertas,
    required this.geocercaRadio,
    this.actividades = const [],
    this.listaTuristas = const [],
    this.filtroActivo = FiltroEstadoAgencia.todas,
  });

  int get sincronizados =>
      participantes
          .where((p) => p.estado == EstadoParticipante.sincronizado)
          .length;
  int get offline =>
      participantes.where((p) => p.estado == EstadoParticipante.offline).length;
  int get enAlerta =>
      participantes.where((p) => p.estado == EstadoParticipante.alerta).length;

  AgenciaHomeLoaded copyWith({
    String? nombreViaje,
    String? folio,
    String? destino,
    int? totalParticipantes,
    List<Participante>? participantes,
    List<AlertaHistorial>? historialAlertas,
    String? geocercaRadio,
    List<ActividadItinerario>? actividades,
    List<Turista>? listaTuristas,
    FiltroEstadoAgencia? filtroActivo,
  }) {
    return AgenciaHomeLoaded(
      nombreViaje: nombreViaje ?? this.nombreViaje,
      folio: folio ?? this.folio,
      destino: destino ?? this.destino,
      totalParticipantes: totalParticipantes ?? this.totalParticipantes,
      participantes: participantes ?? this.participantes,
      historialAlertas: historialAlertas ?? this.historialAlertas,
      geocercaRadio: geocercaRadio ?? this.geocercaRadio,
      actividades: actividades ?? this.actividades,
      listaTuristas: listaTuristas ?? this.listaTuristas,
      filtroActivo: filtroActivo ?? this.filtroActivo,
    );
  }

  @override
  List<Object?> get props => [
    nombreViaje, folio, destino, totalParticipantes, filtroActivo,
    actividades, listaTuristas,
  ];
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

class AgenciaHomeCubit extends Cubit<AgenciaHomeState> {
  final GetAgenciaHomeDataUseCase getAgenciaHomeDataUseCase;

  AgenciaHomeCubit({required this.getAgenciaHomeDataUseCase})
    : super(AgenciaHomeLoading());

  Future<void> cargarDatos(String folio) async {
    try {
      emit(AgenciaHomeLoading());
      final data = await getAgenciaHomeDataUseCase(folio);
      emit(
        AgenciaHomeLoaded(
          nombreViaje: data.nombreViaje,
          folio: data.folio,
          destino: data.destino,
          totalParticipantes: data.totalParticipantes,
          geocercaRadio: data.geocercaRadio,
          participantes: data.participantes,
          historialAlertas: data.historialAlertas,
          actividades: data.actividades,
          listaTuristas: data.listaTuristas,
        ),
      );
    } catch (e) {
      // Manejo de error si es necesario
    }
  }

  void cambiarFiltro(FiltroEstadoAgencia nuevoFiltro) {
    final s = state;
    if (s is AgenciaHomeLoaded) {
      emit(s.copyWith(filtroActivo: nuevoFiltro));
    }
  }
}

