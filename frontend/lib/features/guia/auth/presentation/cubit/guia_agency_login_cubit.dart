import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:frontend/features/guia/auth/domain/entities/guia_user.dart';
import 'package:frontend/features/guia/auth/domain/usecases/verify_folio_guia_usecase.dart';
import 'package:frontend/features/guia/auth/domain/usecases/verify_agency_phone_guia_usecase.dart';

// ── Estados ───────────────────────────────────────────────────────────────────

abstract class GuiaAgencyLoginState extends Equatable {
  const GuiaAgencyLoginState();
  @override
  List<Object?> get props => [];
}

/// Estado inicial
class GuiaAgencyLoginInitial extends GuiaAgencyLoginState {}

/// Petición en curso (folio o teléfono)
class GuiaAgencyLoginLoading extends GuiaAgencyLoginState {}

/// Folio válido → pedir número de teléfono
class GuiaAgencyFolioValidated extends GuiaAgencyLoginState {
  final String folio;
  const GuiaAgencyFolioValidated(this.folio);
  @override
  List<Object?> get props => [folio];
}

/// Acceso concedido
class GuiaAgencyAuthenticated extends GuiaAgencyLoginState {
  final GuiaUser user;
  const GuiaAgencyAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}

/// Error (folio inválido o teléfono incorrecto)
class GuiaAgencyLoginFailure extends GuiaAgencyLoginState {
  final String message;
  const GuiaAgencyLoginFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

class GuiaAgencyLoginCubit extends Cubit<GuiaAgencyLoginState> {
  final VerifyFolioGuiaUseCase verifyFolioUseCase;
  final VerifyAgencyPhoneGuiaUseCase verifyAgencyPhoneUseCase;

  GuiaAgencyLoginCubit({
    required this.verifyFolioUseCase,
    required this.verifyAgencyPhoneUseCase,
  }) : super(GuiaAgencyLoginInitial());

  /// Paso 1: Valida que el folio exista en la base de datos de la agencia
  Future<void> submitFolio(String folio) async {
    if (folio.trim().isEmpty) {
      emit(const GuiaAgencyLoginFailure('Por favor ingresa tu folio'));
      return;
    }
    emit(GuiaAgencyLoginLoading());

    final result = await verifyFolioUseCase(
      VerifyFolioGuiaParams(folio: folio.trim()),
    );

    result.fold(
      (failure) => emit(GuiaAgencyLoginFailure(failure.message)),
      (_) => emit(GuiaAgencyFolioValidated(folio.trim().toUpperCase())),
    );
  }

  /// Paso 2: Valida cruce folio + teléfono y genera la sesión
  Future<void> submitPhone(String folio, String phone) async {
    if (phone.trim().isEmpty) {
      emit(
        const GuiaAgencyLoginFailure('Por favor ingresa tu número de teléfono'),
      );
      return;
    }
    emit(GuiaAgencyLoginLoading());

    final result = await verifyAgencyPhoneUseCase(
      VerifyAgencyPhoneGuiaParams(folio: folio, phone: phone.trim()),
    );

    result.fold(
      (failure) => emit(GuiaAgencyLoginFailure(failure.message)),
      (user) => emit(GuiaAgencyAuthenticated(user)),
    );
  }
}
