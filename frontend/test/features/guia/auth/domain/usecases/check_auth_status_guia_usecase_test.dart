import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:frontend/core/error/failures.dart';
import 'package:frontend/core/usecase/usecase.dart';
import 'package:frontend/features/guia/auth/domain/entities/guia_user.dart';
import 'package:frontend/features/guia/auth/domain/repositories/guia_auth_repository.dart';
import 'package:frontend/features/guia/auth/domain/usecases/check_auth_status_guia_usecase.dart';

class MockGuiaAuthRepository extends Mock implements GuiaAuthRepository {}

void main() {
  late CheckAuthStatusGuiaUseCase usecase;
  late MockGuiaAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockGuiaAuthRepository();
    usecase = CheckAuthStatusGuiaUseCase(mockRepository);
  });

  const tGuiaUser = GuiaUser(
    id: '1',
    name: 'Guía Logueado',
    email: 'logueado@test.com',
    phone: '123',
    permissionLevel: 1,
    authStatus: AuthStatus.active,
  );

  group('CheckAuthStatusGuiaUseCase', () {
    test('Debe retornar el usuario actual si hay una sesión activa', () async {
      // Arrange
      when(
        () => mockRepository.checkAuthStatus(),
      ).thenAnswer((_) async => const Right(tGuiaUser));

      // Act
      final result = await usecase(NoParams());

      // Assert
      expect(result, const Right(tGuiaUser));
      verify(() => mockRepository.checkAuthStatus()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test(
      'Debe retornar null envuelto en Right si la verificación devuelve que no hay sesión, o CacheFailure',
      () async {
        // Arrange
        when(
          () => mockRepository.checkAuthStatus(),
        ).thenAnswer((_) async => const Left(CacheFailure('No session found')));

        // Act
        final result = await usecase(NoParams());

        // Assert
        expect(result, const Left(CacheFailure('No session found')));
        verify(() => mockRepository.checkAuthStatus()).called(1);
      },
    );
  });
}
