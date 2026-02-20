import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/core/usecase/usecase.dart';
import 'package:frontend/features/guia/auth/domain/repositories/guia_auth_repository.dart';

class ForgotPasswordGuiaUseCase
    implements UseCase<void, ForgotPasswordGuiaParams> {
  final GuiaAuthRepository repository;

  ForgotPasswordGuiaUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ForgotPasswordGuiaParams params) async {
    return await repository.sendPasswordResetEmail(params.email);
  }
}

class ForgotPasswordGuiaParams extends Equatable {
  final String email;

  const ForgotPasswordGuiaParams({required this.email});

  @override
  List<Object> get props => [email];
}
