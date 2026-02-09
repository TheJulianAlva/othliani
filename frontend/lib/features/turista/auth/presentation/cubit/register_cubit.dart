import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/turista/auth/domain/usecases/register_usecase.dart';
import 'package:frontend/features/turista/auth/presentation/cubit/register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterUseCase registerUseCase;

  RegisterCubit({required this.registerUseCase}) : super(RegisterInitial());

  Future<void> register(String name, String email, String password) async {
    emit(RegisterLoading());

    final result = await registerUseCase(
      RegisterParams(name: name, email: email, password: password),
    );

    result.fold(
      (failure) => emit(RegisterFailure(failure.message)),
      (user) => emit(RegisterSuccess(user)),
    );
  }
}
