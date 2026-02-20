import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:frontend/features/guia/auth/domain/usecases/forgot_password_guia_usecase.dart';

// ── States ────────────────────────────────────────────────────────────────

abstract class GuiaForgotPasswordState extends Equatable {
  const GuiaForgotPasswordState();
  @override
  List<Object?> get props => [];
}

class GuiaForgotPasswordInitial extends GuiaForgotPasswordState {}

class GuiaForgotPasswordLoading extends GuiaForgotPasswordState {}

class GuiaForgotPasswordSuccess extends GuiaForgotPasswordState {}

class GuiaForgotPasswordFailure extends GuiaForgotPasswordState {
  final String message;
  const GuiaForgotPasswordFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Cubit ─────────────────────────────────────────────────────────────────

class GuiaForgotPasswordCubit extends Cubit<GuiaForgotPasswordState> {
  final ForgotPasswordGuiaUseCase forgotPasswordUseCase;

  GuiaForgotPasswordCubit({required this.forgotPasswordUseCase})
    : super(GuiaForgotPasswordInitial());

  Future<void> sendPasswordResetEmail(String email) async {
    emit(GuiaForgotPasswordLoading());

    final result = await forgotPasswordUseCase(
      ForgotPasswordGuiaParams(email: email),
    );

    result.fold(
      (failure) => emit(GuiaForgotPasswordFailure(failure.message)),
      (_) => emit(GuiaForgotPasswordSuccess()),
    );
  }
}
