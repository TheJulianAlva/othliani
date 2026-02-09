import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/turista/auth/domain/usecases/verify_folio_usecase.dart';
import 'package:frontend/features/turista/auth/domain/usecases/request_phone_code_usecase.dart';
import 'package:frontend/features/turista/auth/domain/usecases/verify_phone_code_usecase.dart';
import 'package:frontend/features/turista/auth/domain/usecases/resend_email_verification_usecase.dart';
import 'package:frontend/features/turista/auth/presentation/cubit/verification_state.dart';

class VerificationCubit extends Cubit<VerificationState> {
  final VerifyFolioUseCase verifyFolioUseCase;
  final RequestPhoneCodeUseCase requestPhoneCodeUseCase;
  final VerifyPhoneCodeUseCase verifyPhoneCodeUseCase;
  final ResendEmailVerificationUseCase resendEmailVerificationUseCase;

  VerificationCubit({
    required this.verifyFolioUseCase,
    required this.requestPhoneCodeUseCase,
    required this.verifyPhoneCodeUseCase,
    required this.resendEmailVerificationUseCase,
  }) : super(VerificationInitial());

  Future<void> verifyFolio(String folio) async {
    emit(VerificationLoading());
    final result = await verifyFolioUseCase(folio);
    result.fold((failure) => emit(VerificationError(failure.message)), (
      isValid,
    ) {
      if (isValid) {
        emit(const FolioVerified(true));
      } else {
        emit(const VerificationError('Folio inválido'));
      }
    });
  }

  Future<void> requestPhoneCode(String phoneNumber) async {
    emit(VerificationLoading());
    final result = await requestPhoneCodeUseCase(phoneNumber);
    result.fold(
      (failure) => emit(VerificationError(failure.message)),
      (_) => emit(PhoneCodeSent()),
    );
  }

  Future<void> verifyPhoneCode(String phoneNumber, String code) async {
    emit(VerificationLoading());
    final result = await verifyPhoneCodeUseCase(
      VerifyPhoneCodeParams(phoneNumber: phoneNumber, code: code),
    );
    result.fold((failure) => emit(VerificationError(failure.message)), (
      isValid,
    ) {
      if (isValid) {
        emit(const PhoneVerified(true));
      } else {
        emit(const VerificationError('Código inválido'));
      }
    });
  }

  Future<void> resendEmail(String email) async {
    emit(VerificationLoading());
    final result = await resendEmailVerificationUseCase(email);
    result.fold(
      (failure) => emit(VerificationError(failure.message)),
      (_) => emit(EmailSent()),
    );
  }
}
