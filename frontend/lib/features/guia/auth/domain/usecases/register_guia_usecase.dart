import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/core/usecase/usecase.dart';
import 'package:frontend/features/guia/auth/domain/entities/guia_user.dart';
import 'package:frontend/features/guia/auth/domain/repositories/guia_auth_repository.dart';

class RegisterGuiaUseCase extends UseCase<GuiaUser, RegisterGuiaParams> {
  final GuiaAuthRepository repository;
  RegisterGuiaUseCase(this.repository);

  @override
  Future<Either<Failure, GuiaUser>> call(RegisterGuiaParams params) =>
      repository.register(params);
}

class RegisterGuiaParams extends Equatable {
  final String nombre;
  final String apellido;
  final String correo;
  final String telefono;
  final String password;
  final String? contactoEmergencia;

  const RegisterGuiaParams({
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.telefono,
    required this.password,
    this.contactoEmergencia,
  });

  @override
  List<Object?> get props => [
    nombre,
    apellido,
    correo,
    telefono,
    password,
    contactoEmergencia,
  ];
}
