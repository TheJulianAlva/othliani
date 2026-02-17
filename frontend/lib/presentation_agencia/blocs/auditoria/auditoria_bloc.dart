import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../domain/entities/log_auditoria.dart';
import '../../../../domain/repositories/agencia_repository.dart';

// Events
abstract class AuditoriaEvent extends Equatable {
  const AuditoriaEvent();
  @override
  List<Object?> get props => [];
}

class LoadAuditoriaEvent extends AuditoriaEvent {
  final String? filterNivel; // Opcional: 'CRITICO', 'INFO', etc.
  const LoadAuditoriaEvent({this.filterNivel});
  @override
  List<Object?> get props => [filterNivel];
}

// States
abstract class AuditoriaState extends Equatable {
  const AuditoriaState();
  @override
  List<Object?> get props => [];
}

class AuditoriaInitial extends AuditoriaState {}

class AuditoriaLoading extends AuditoriaState {}

class AuditoriaLoaded extends AuditoriaState {
  final List<LogAuditoria> logs; // Lista filtrada
  final String? activeFilter;

  const AuditoriaLoaded({required this.logs, this.activeFilter});
  @override
  List<Object?> get props => [logs, activeFilter];
}

class AuditoriaError extends AuditoriaState {
  final String message;
  const AuditoriaError(this.message);
  @override
  List<Object> get props => [message];
}

// BLoC
class AuditoriaBloc extends Bloc<AuditoriaEvent, AuditoriaState> {
  final AgenciaRepository repository;

  AuditoriaBloc({required this.repository}) : super(AuditoriaLoading()) {
    on<LoadAuditoriaEvent>(_onLoadAuditoria);
  }

  Future<void> _onLoadAuditoria(
    LoadAuditoriaEvent event,
    Emitter<AuditoriaState> emit,
  ) async {
    emit(AuditoriaLoading());

    final result = await repository.getAuditLogs();

    result.fold(
      (failure) => emit(const AuditoriaError("Error cargando logs")),
      (allLogs) {
        // Lógica de Filtrado Local
        List<LogAuditoria> filteredLogs = allLogs;

        if (event.filterNivel != null && event.filterNivel!.isNotEmpty) {
          // Normalizamos a mayúsculas para comparar
          final filter = event.filterNivel!.toUpperCase();
          filteredLogs = allLogs.where((log) => log.nivel == filter).toList();
        }

        // Ordenamos por fecha descendente (lo más nuevo arriba)
        filteredLogs.sort((a, b) => b.fecha.compareTo(a.fecha));

        emit(
          AuditoriaLoaded(logs: filteredLogs, activeFilter: event.filterNivel),
        );
      },
    );
  }
}
