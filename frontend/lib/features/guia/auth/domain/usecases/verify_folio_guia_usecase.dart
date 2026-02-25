import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/core/usecase/usecase.dart';
import 'package:frontend/features/guia/auth/domain/repositories/guia_auth_repository.dart';

class VerifyFolioGuiaUseCase implements UseCase<void, VerifyFolioGuiaParams> {
  final GuiaAuthRepository repository;

  VerifyFolioGuiaUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(VerifyFolioGuiaParams params) async {
    return await repository.verifyAgencyFolio(params.folio);
  }
}

class VerifyFolioGuiaParams extends Equatable {
  final String folio;

  const VerifyFolioGuiaParams({required this.folio});

  @override
  List<Object> get props => [folio];
}
