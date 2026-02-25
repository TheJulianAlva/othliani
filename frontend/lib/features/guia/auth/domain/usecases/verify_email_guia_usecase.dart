import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/core/usecase/usecase.dart';
import 'package:frontend/features/guia/auth/domain/repositories/guia_auth_repository.dart';

class VerifyEmailGuiaUseCase extends UseCase<void, VerifyEmailGuiaParams> {
  final GuiaAuthRepository repository;
  VerifyEmailGuiaUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(VerifyEmailGuiaParams params) =>
      repository.verifyEmailCode(params.codigo);
}

class VerifyEmailGuiaParams extends Equatable {
  final String codigo;
  const VerifyEmailGuiaParams({required this.codigo});

  @override
  List<Object> get props => [codigo];
}
