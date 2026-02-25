import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/guia/auth/domain/entities/guia_user.dart';
import 'package:frontend/features/guia/auth/domain/usecases/verify_agency_phone_guia_usecase.dart';
import 'package:frontend/features/guia/auth/domain/usecases/verify_folio_guia_usecase.dart';
import 'package:frontend/features/guia/auth/presentation/cubit/guia_agency_login_cubit.dart';

class MockVerifyFolioGuiaUseCase extends Mock
    implements VerifyFolioGuiaUseCase {}

class MockVerifyAgencyPhoneGuiaUseCase extends Mock
    implements VerifyAgencyPhoneGuiaUseCase {}

class FakeVerifyFolioParams extends Fake implements VerifyFolioGuiaParams {}

class FakeVerifyPhoneParams extends Fake
    implements VerifyAgencyPhoneGuiaParams {}

void main() {
  late GuiaAgencyLoginCubit cubit;
  late MockVerifyFolioGuiaUseCase mockVerifyFolioUseCase;
  late MockVerifyAgencyPhoneGuiaUseCase mockVerifyAgencyPhoneUseCase;

  setUpAll(() {
    registerFallbackValue(FakeVerifyFolioParams());
    registerFallbackValue(FakeVerifyPhoneParams());
  });

  setUp(() {
    mockVerifyFolioUseCase = MockVerifyFolioGuiaUseCase();
    mockVerifyAgencyPhoneUseCase = MockVerifyAgencyPhoneGuiaUseCase();

    cubit = GuiaAgencyLoginCubit(
      verifyFolioUseCase: mockVerifyFolioUseCase,
      verifyAgencyPhoneUseCase: mockVerifyAgencyPhoneUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  const tFolio = 'AG-2024-MX';
  const tPhone = '1234567890';
  const tGuiaUser = GuiaUser(
    id: '123',
    name: 'Guía B2B',
    email: 'guia@agencia.com',
    phone: tPhone,
  );

  group('GuiaAgencyLoginCubit - submitFolio', () {
    blocTest<GuiaAgencyLoginCubit, GuiaAgencyLoginState>(
      'Debe emitir [Failure] directo si el folio está vacío',
      build: () => cubit,
      act: (cubit) => cubit.submitFolio('   '),
      expect: () => [isA<GuiaAgencyLoginFailure>()],
    );

    blocTest<GuiaAgencyLoginCubit, GuiaAgencyLoginState>(
      'Debe emitir [Loading, Validated] si el folio es válido en BD de agencia',
      build: () {
        when(
          () => mockVerifyFolioUseCase(any()),
        ).thenAnswer((_) async => const Right(null));
        return cubit;
      },
      act: (cubit) => cubit.submitFolio(tFolio),
      expect:
          () => [
            isA<GuiaAgencyLoginLoading>(),
            isA<GuiaAgencyFolioValidated>(),
          ],
      verify: (_) {
        verify(
          () => mockVerifyFolioUseCase(
            const VerifyFolioGuiaParams(folio: tFolio),
          ),
        ).called(1);
      },
    );

    blocTest<GuiaAgencyLoginCubit, GuiaAgencyLoginState>(
      'Debe emitir [Loading, Failure] si el folio es rechazado o caducó',
      build: () {
        when(
          () => mockVerifyFolioUseCase(any()),
        ).thenAnswer((_) async => const Left(ServerFailure('Folio inválido')));
        return cubit;
      },
      act: (cubit) => cubit.submitFolio(tFolio),
      expect:
          () => [isA<GuiaAgencyLoginLoading>(), isA<GuiaAgencyLoginFailure>()],
    );
  });

  group('GuiaAgencyLoginCubit - submitPhone', () {
    blocTest<GuiaAgencyLoginCubit, GuiaAgencyLoginState>(
      'Debe emitir [Loading, Authenticated] si la combinación teléfono+folio es correcta',
      build: () {
        when(
          () => mockVerifyAgencyPhoneUseCase(any()),
        ).thenAnswer((_) async => const Right(tGuiaUser));
        return cubit;
      },
      act: (cubit) => cubit.submitPhone(tFolio, tPhone),
      expect:
          () => [isA<GuiaAgencyLoginLoading>(), isA<GuiaAgencyAuthenticated>()],
      verify: (_) {
        verify(
          () => mockVerifyAgencyPhoneUseCase(
            const VerifyAgencyPhoneGuiaParams(folio: tFolio, phone: tPhone),
          ),
        ).called(1);
      },
    );

    blocTest<GuiaAgencyLoginCubit, GuiaAgencyLoginState>(
      'Debe emitir [Loading, Failure] si teléfono no machea en BD',
      build: () {
        when(() => mockVerifyAgencyPhoneUseCase(any())).thenAnswer(
          (_) async =>
              const Left(ServerFailure('Match de teléfono inconsistente')),
        );
        return cubit;
      },
      act: (cubit) => cubit.submitPhone(tFolio, tPhone),
      expect:
          () => [isA<GuiaAgencyLoginLoading>(), isA<GuiaAgencyLoginFailure>()],
    );
  });
}
