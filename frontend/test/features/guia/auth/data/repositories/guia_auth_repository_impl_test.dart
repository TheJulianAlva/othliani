import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/guia/auth/data/datasources/guia_auth_local_data_source.dart';
import 'package:frontend/features/guia/auth/data/datasources/guia_auth_remote_data_source.dart';
import 'package:frontend/features/guia/auth/data/datasources/guia_subscription_remote_data_source.dart';
import 'package:frontend/features/guia/auth/data/models/guia_user_model.dart';
import 'package:frontend/features/guia/auth/data/repositories/guia_auth_repository_impl.dart';

// Mocks
class MockRemoteDataSource extends Mock implements GuiaAuthRemoteDataSource {}

class MockLocalDataSource extends Mock implements GuiaAuthLocalDataSource {}

class MockSubscriptionDataSource extends Mock
    implements GuiaSubscriptionRemoteDataSource {}

class FakeGuiaUserModel extends Fake implements GuiaUserModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeGuiaUserModel());
  });

  late GuiaAuthRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockSubscriptionDataSource mockSubscriptionDataSource;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockSubscriptionDataSource = MockSubscriptionDataSource();

    repository = GuiaAuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      subscriptionDataSource: mockSubscriptionDataSource,
    );
  });

  const tFolio = "AG-2024";

  group('verifyAgencyFolio (Login B2B)', () {
    test(
      'Debe retornar un status Right(null) cuando la API responde con éxito',
      () async {
        // Arrange
        when(
          () => mockRemoteDataSource.verifyFolio(any()),
        ).thenAnswer((_) async => Future.value());

        // Act
        final result = await repository.verifyAgencyFolio(tFolio);

        // Assert
        expect(result, equals(const Right(null)));

        // Verificamos que llamó a la API
        verify(() => mockRemoteDataSource.verifyFolio(tFolio)).called(1);
      },
    );

    test(
      'Debe retornar ServerFailure cuando la llamada a la API falla',
      () async {
        // Arrange
        // Hacemos que el mock de la API lance una excepción
        when(
          () => mockRemoteDataSource.verifyFolio(any()),
        ).thenThrow(Exception('Error en el servidor'));

        // Act
        final result = await repository.verifyAgencyFolio(tFolio);

        // Assert
        // Debería capturar la Exception y devolver un ServerFailure (Left)
        expect(
          result,
          equals(const Left(ServerFailure('Exception: Error en el servidor'))),
        );
        verify(() => mockRemoteDataSource.verifyFolio(tFolio)).called(1);
      },
    );
  });

  group('login (Guia Auth)', () {
    const tEmail = 'test@test.com';
    const tPassword = 'password123';
    const tUserModel = GuiaUserModel(
      id: '1',
      name: 'Guía',
      email: 'g@test.com',
      phone: '123',
      permissionLevel: 1,
    );

    test(
      'Debe retornar un usuario y guardarlo en caché cuando la API responde con éxito',
      () async {
        // Arrange
        when(
          () => mockRemoteDataSource.login(any(), any()),
        ).thenAnswer((_) async => tUserModel);
        when(
          () => mockLocalDataSource.cacheGuiaUser(any()),
        ).thenAnswer((_) async => Future.value());

        // Act
        final result = await repository.login(tEmail, tPassword);

        // Assert
        expect(result, equals(const Right(tUserModel)));
        verify(() => mockRemoteDataSource.login(tEmail, tPassword)).called(1);
        verify(() => mockLocalDataSource.cacheGuiaUser(tUserModel)).called(1);
      },
    );

    test('Debe devolver ServerFailure si login falla', () async {
      // Arrange
      when(
        () => mockRemoteDataSource.login(any(), any()),
      ).thenThrow(Exception('Login Invalido'));

      // Act
      final result = await repository.login(tEmail, tPassword);

      // Assert
      expect(
        result,
        equals(const Left(ServerFailure('Exception: Login Invalido'))),
      );
      verify(() => mockRemoteDataSource.login(tEmail, tPassword)).called(1);
      verifyZeroInteractions(mockLocalDataSource);
    });
  });
}
