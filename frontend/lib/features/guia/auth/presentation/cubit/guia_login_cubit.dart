import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/guia/auth/domain/usecases/login_guia_usecase.dart';
import 'package:frontend/features/guia/auth/presentation/cubit/guia_login_state.dart';

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
