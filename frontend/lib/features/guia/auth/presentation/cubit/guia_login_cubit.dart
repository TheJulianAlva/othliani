import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:frontend/features/guia/auth/domain/entities/guia_user.dart';
import 'package:frontend/features/guia/auth/domain/usecases/login_guia_usecase.dart';

// ── States ────────────────────────────────────────────────────────────────

abstract class GuiaLoginState extends Equatable {
  const GuiaLoginState();
  @override
  List<Object?> get props => [];
}

class GuiaLoginInitial extends GuiaLoginState {}

class GuiaLoginLoading extends GuiaLoginState {}

class GuiaLoginSuccess extends GuiaLoginState {
  final GuiaUser user;
  const GuiaLoginSuccess(this.user);
  @override
  List<Object?> get props => [user];
}

class GuiaLoginFailure extends GuiaLoginState {
  final String message;
  const GuiaLoginFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Cubit ─────────────────────────────────────────────────────────────────

class GuiaLoginCubit extends Cubit<GuiaLoginState> {
  final LoginGuiaUseCase loginUseCase;

  GuiaLoginCubit({required this.loginUseCase}) : super(GuiaLoginInitial());

  Future<void> login(String email, String password) async {
    emit(GuiaLoginLoading());

    final result = await loginUseCase(
      LoginGuiaParams(email: email, password: password),
    );

    result.fold(
      (failure) => emit(GuiaLoginFailure(failure.message)),
      (user) => emit(GuiaLoginSuccess(user)),
    );
  }
}
