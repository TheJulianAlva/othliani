import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/core/usecase/usecase.dart';
import 'package:frontend/features/guia/auth/domain/entities/guia_user.dart';
import 'package:frontend/features/guia/auth/domain/repositories/guia_auth_repository.dart';

class VerifyAgencyPhoneGuiaUseCase
    implements UseCase<GuiaUser, VerifyAgencyPhoneGuiaParams> {
  final GuiaAuthRepository repository;

  VerifyAgencyPhoneGuiaUseCase(this.repository);

  @override
  Future<Either<Failure, GuiaUser>> call(
    VerifyAgencyPhoneGuiaParams params,
  ) async {
    return await repository.loginWithAgencyAccess(params.folio, params.phone);
  }
}

class VerifyAgencyPhoneGuiaParams extends Equatable {
  final String folio;
  final String phone;

  const VerifyAgencyPhoneGuiaParams({required this.folio, required this.phone});

  @override
  List<Object> get props => [folio, phone];
}
