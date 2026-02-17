import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/turista/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:frontend/features/turista/auth/presentation/cubit/forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final ForgotPasswordUseCase forgotPasswordUseCase;

  ForgotPasswordCubit({required this.forgotPasswordUseCase})
    : super(ForgotPasswordInitial());

  Future<void> sendPasswordResetEmail(String email) async {
    emit(ForgotPasswordLoading());

    final result = await forgotPasswordUseCase(
      ForgotPasswordParams(email: email),
    );

    result.fold(
      (failure) => emit(ForgotPasswordFailure(failure.message)),
      (_) => emit(ForgotPasswordSuccess()),
    );
  }
}
