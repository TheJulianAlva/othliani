import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/guia/auth/domain/entities/guia_user.dart';
import 'package:frontend/features/guia/auth/domain/usecases/login_guia_usecase.dart';
import 'package:frontend/features/guia/auth/presentation/cubit/guia_login_cubit.dart';

// Necesitamos registrar un valor por defecto ("Fallback") para parámetros complejos en Mocktail
class FakeLoginParams extends Fake implements LoginGuiaParams {}

class MockLoginGuiaUseCase extends Mock implements LoginGuiaUseCase {}

void main() {
  late GuiaLoginCubit cubit;
  late MockLoginGuiaUseCase mockLoginUseCase;

  setUpAll(() {
    // Registramos el fake para que Mocktail pueda manejar `any()` con objetos personalizados
    registerFallbackValue(FakeLoginParams());
  });

  setUp(() {
    mockLoginUseCase = MockLoginGuiaUseCase();
    cubit = GuiaLoginCubit(loginUseCase: mockLoginUseCase);
  });

  tearDown(() {
    cubit.close();
  });

  const tEmail = 'test@guia.com';
  const tPassword = 'Password123!';
  const tGuiaUser = GuiaUser(
    id: '456',
    name: 'Guía B2C',
    email: tEmail,
    phone: '9876543210',
    permissionLevel: 1,
    authStatus: AuthStatus.active,
  );

  group('GuiaLoginCubit', () {
    blocTest<GuiaLoginCubit, GuiaLoginState>(
      'Debe emitir [Loading, Success] con credenciales válidas',
      build: () {
        when(
          () => mockLoginUseCase(any()),
        ).thenAnswer((_) async => const Right(tGuiaUser));
        return cubit;
      },
      act: (cubit) => cubit.login(tEmail, tPassword),
      expect: () => [isA<GuiaLoginLoading>(), isA<GuiaLoginSuccess>()],
      verify: (_) {
        verify(
          () => mockLoginUseCase(
            const LoginGuiaParams(email: tEmail, password: tPassword),
          ),
        ).called(1);
      },
    );

    blocTest<GuiaLoginCubit, GuiaLoginState>(
      'Debe emitir [Loading, Failure] si la API rechaza las credenciales',
      build: () {
        when(() => mockLoginUseCase(any())).thenAnswer(
          (_) async => const Left(ServerFailure('Contraseña incorrecta')),
        );
        return cubit;
      },
      act: (cubit) => cubit.login(tEmail, tPassword),
      expect: () => [isA<GuiaLoginLoading>(), isA<GuiaLoginFailure>()],
    );
  });
}
