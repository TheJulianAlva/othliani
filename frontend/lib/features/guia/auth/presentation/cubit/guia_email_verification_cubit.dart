import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:frontend/features/guia/auth/domain/usecases/verify_email_guia_usecase.dart';

// ── States ────────────────────────────────────────────────────────────────

abstract class GuiaEmailVerificationState extends Equatable {
  const GuiaEmailVerificationState();
  @override
  List<Object?> get props => [];
}

class GuiaEmailVerificationInitial extends GuiaEmailVerificationState {}

class GuiaEmailVerificationLoading extends GuiaEmailVerificationState {}

class GuiaEmailVerificationSuccess extends GuiaEmailVerificationState {}

class GuiaEmailVerificationFailure extends GuiaEmailVerificationState {
  final String message;
  const GuiaEmailVerificationFailure(this.message);
  @override
  List<Object> get props => [message];
}

// ── Cubit ─────────────────────────────────────────────────────────────────

class GuiaEmailVerificationCubit extends Cubit<GuiaEmailVerificationState> {
  final VerifyEmailGuiaUseCase verifyEmailUseCase;

  GuiaEmailVerificationCubit({required this.verifyEmailUseCase})
    : super(GuiaEmailVerificationInitial());

  Future<void> verifyEmailCode(String codigo) async {
    emit(GuiaEmailVerificationLoading());

    final result = await verifyEmailUseCase(
      VerifyEmailGuiaParams(codigo: codigo),
    );

    result.fold(
      (failure) => emit(GuiaEmailVerificationFailure(failure.message)),
      (_) => emit(GuiaEmailVerificationSuccess()),
    );
  }
}
