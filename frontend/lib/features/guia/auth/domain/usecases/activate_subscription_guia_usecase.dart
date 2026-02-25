import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/core/usecase/usecase.dart';
import 'package:frontend/features/guia/auth/domain/repositories/guia_auth_repository.dart';

class ActivateSubscriptionGuiaUseCase
    extends UseCase<void, ActivateSubscriptionGuiaParams> {
  final GuiaAuthRepository repository;
  ActivateSubscriptionGuiaUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ActivateSubscriptionGuiaParams params) =>
      repository.activateSubscription(params);
}

class ActivateSubscriptionGuiaParams extends Equatable {
  final String plan;
  final double precioPorMes;
  final String titularTarjeta;
  final String numeroTarjeta;
  final String fechaVencimiento;
  final String cvv;

  const ActivateSubscriptionGuiaParams({
    required this.plan,
    required this.precioPorMes,
    required this.titularTarjeta,
    required this.numeroTarjeta,
    required this.fechaVencimiento,
    required this.cvv,
  });

  @override
  List<Object> get props => [
    plan,
    precioPorMes,
    titularTarjeta,
    numeroTarjeta,
    fechaVencimiento,
    cvv,
  ];
}
