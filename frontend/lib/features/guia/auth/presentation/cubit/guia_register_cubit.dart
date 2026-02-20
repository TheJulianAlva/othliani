import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:frontend/features/guia/auth/domain/entities/guia_user.dart';
import 'package:frontend/features/guia/auth/domain/usecases/register_guia_usecase.dart';

// ── States ────────────────────────────────────────────────────────────────

abstract class GuiaRegisterState extends Equatable {
  const GuiaRegisterState();
  @override
  List<Object?> get props => [];
}

class GuiaRegisterInitial extends GuiaRegisterState {}

class GuiaRegisterLoading extends GuiaRegisterState {}

class GuiaRegisterSuccess extends GuiaRegisterState {
  final GuiaUser user;
  const GuiaRegisterSuccess(this.user);
  @override
  List<Object> get props => [user];
}

class GuiaRegisterFailure extends GuiaRegisterState {
  final String message;
  const GuiaRegisterFailure(this.message);
  @override
  List<Object> get props => [message];
}

// ── Cubit ─────────────────────────────────────────────────────────────────

class GuiaRegisterCubit extends Cubit<GuiaRegisterState> {
  final RegisterGuiaUseCase registerUseCase;

  GuiaRegisterCubit({required this.registerUseCase})
    : super(GuiaRegisterInitial());

  Future<void> register({
    required String nombre,
    required String apellido,
    required String correo,
    required String telefono,
    required String password,
    String? contactoEmergencia,
  }) async {
    emit(GuiaRegisterLoading());

    final result = await registerUseCase(
      RegisterGuiaParams(
        nombre: nombre,
        apellido: apellido,
        correo: correo,
        telefono: telefono,
        password: password,
        contactoEmergencia: contactoEmergencia,
      ),
    );

    result.fold(
      (failure) => emit(GuiaRegisterFailure(failure.toString())),
      (user) => emit(GuiaRegisterSuccess(user)),
    );
  }
}
