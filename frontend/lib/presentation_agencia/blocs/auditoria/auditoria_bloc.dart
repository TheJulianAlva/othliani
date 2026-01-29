import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../domain/entities/log_auditoria.dart';
import '../../../../domain/repositories/agencia_repository.dart';

// Events
abstract class AuditoriaEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadAuditoriaEvent extends AuditoriaEvent {
  final String? filterNivel;
  LoadAuditoriaEvent({this.filterNivel});
  @override
  List<Object> get props => [filterNivel ?? ''];
}

// States
abstract class AuditoriaState extends Equatable {
  @override
  List<Object> get props => [];
}

class AuditoriaInitial extends AuditoriaState {}

class AuditoriaLoading extends AuditoriaState {}

class AuditoriaLoaded extends AuditoriaState {
  final List<LogAuditoria> logs;
  AuditoriaLoaded(this.logs);
  @override
  List<Object> get props => [logs];
}

class AuditoriaError extends AuditoriaState {
  final String message;
  AuditoriaError(this.message);
  @override
  List<Object> get props => [message];
}

// BLoC
class AuditoriaBloc extends Bloc<AuditoriaEvent, AuditoriaState> {
  final AgenciaRepository repository;

  AuditoriaBloc({required this.repository}) : super(AuditoriaInitial()) {
    on<LoadAuditoriaEvent>(_onLoadAuditoria);
  }

  Future<void> _onLoadAuditoria(
    LoadAuditoriaEvent event,
    Emitter<AuditoriaState> emit,
  ) async {
    emit(AuditoriaLoading());
    final result = await repository.getAuditLogs();
    result.fold(
      (failure) => emit(AuditoriaError('Error al cargar auditoría')),
      (logs) => emit(AuditoriaLoaded(logs)),
    );
  }
}
