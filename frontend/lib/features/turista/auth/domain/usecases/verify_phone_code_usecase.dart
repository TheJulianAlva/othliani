import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/core/usecase/usecase.dart';
import 'package:frontend/features/turista/auth/domain/repositories/auth_repository.dart';

class VerifyPhoneCodeParams {
  final String phoneNumber;
  final String code;

  VerifyPhoneCodeParams({required this.phoneNumber, required this.code});
}

class VerifyPhoneCodeUseCase implements UseCase<bool, VerifyPhoneCodeParams> {
  final AuthRepository repository;

  VerifyPhoneCodeUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(VerifyPhoneCodeParams params) async {
    return await repository.verifyPhoneCode(params.phoneNumber, params.code);
  }
}
