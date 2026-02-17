import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/usecase/usecase.dart';
import 'package:frontend/features/turista/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:frontend/features/turista/auth/domain/usecases/logout_usecase.dart';
import 'package:frontend/features/turista/auth/presentation/bloc/auth_event.dart';
import 'package:frontend/features/turista/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthBloc({
    required CheckAuthStatusUseCase checkAuthStatusUseCase,
    required LogoutUseCase logoutUseCase,
  }) : _checkAuthStatusUseCase = checkAuthStatusUseCase,
       _logoutUseCase = logoutUseCase,
       super(const AuthState.unknown()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthLoggedIn>(_onAuthLoggedIn);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _checkAuthStatusUseCase(NoParams());
    result.fold((_) => emit(const AuthState.unauthenticated()), (user) {
      if (user != null) {
        emit(AuthState.authenticated(user));
      } else {
        emit(const AuthState.unauthenticated());
      }
    });
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _logoutUseCase(NoParams());
    emit(const AuthState.unauthenticated());
  }

  void _onAuthLoggedIn(AuthLoggedIn event, Emitter<AuthState> emit) {
    emit(AuthState.authenticated(event.user));
  }
}
