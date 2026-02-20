import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/core/usecase/usecase.dart';
import 'package:frontend/features/guia/auth/domain/entities/guia_user.dart';
import 'package:frontend/features/guia/auth/domain/repositories/guia_auth_repository.dart';

class LoginGuiaUseCase implements UseCase<GuiaUser, LoginGuiaParams> {
  final GuiaAuthRepository repository;

  LoginGuiaUseCase(this.repository);

  @override
  Future<Either<Failure, GuiaUser>> call(LoginGuiaParams params) async {
    return await repository.login(params.email, params.password);
  }
}

class LoginGuiaParams extends Equatable {
  final String email;
  final String password;

  const LoginGuiaParams({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}
