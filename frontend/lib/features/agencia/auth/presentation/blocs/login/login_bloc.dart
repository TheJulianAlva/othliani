import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:frontend/core/session/agencia_session.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/entities/auth_user.dart';

// Events
abstract class LoginEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoginSubmitted extends LoginEvent {
  final String email;
  final String password;

  LoginSubmitted({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

// States
abstract class LoginState extends Equatable {
  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final AuthUser user;
  LoginSuccess(this.user);
  @override
  List<Object> get props => [user];
}

class LoginFailure extends LoginState {
  final String message;
  LoginFailure(this.message);
  @override
  List<Object> get props => [message];
}

// Bloc
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository repository;

  LoginBloc({required this.repository}) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    final result = await repository.login(event.email, event.password);
    result.fold(
      (failure) => emit(LoginFailure(failure.message)),
      (user) {
        // Registrar la sesión global para que el datasource remoto acceda al ID
        AgenciaSession.instance.inicializar(
          agenciaId: user.id,
          nombre: user.name,
        );
        emit(LoginSuccess(user));
      },
    );
  }
}
