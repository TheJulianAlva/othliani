import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/guia/auth/domain/usecases/forgot_password_guia_usecase.dart';
import 'package:frontend/features/guia/auth/presentation/cubit/guia_forgot_password_state.dart';

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
