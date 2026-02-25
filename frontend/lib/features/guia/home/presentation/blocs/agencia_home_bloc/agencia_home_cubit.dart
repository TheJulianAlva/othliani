import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/agencia_home_data.dart';
import '../../../domain/usecases/get_agencia_home_data_usecase.dart';

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
        ),
      );
    } catch (e) {
      // Manejo de error si es necesario
    }
  }
}
