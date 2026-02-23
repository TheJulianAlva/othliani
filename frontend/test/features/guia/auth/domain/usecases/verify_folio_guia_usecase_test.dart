import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/guia/auth/domain/repositories/guia_auth_repository.dart';
import 'package:frontend/features/guia/auth/domain/usecases/verify_folio_guia_usecase.dart';

// 1. Creamos un Mock del Repositorio
class MockGuiaAuthRepository extends Mock implements GuiaAuthRepository {}

void main() {
  late VerifyFolioGuiaUseCase usecase;
  late MockGuiaAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockGuiaAuthRepository();
    usecase = VerifyFolioGuiaUseCase(mockRepository);
  });

  const tFolio = 'AG-2024-MX';

  group('VerifyFolioGuiaUseCase', () {
    test(
      'Debe retornar [void] desde el repositorio si el folio es válido',
      () async {
        // Arrange
        when(
          () => mockRepository.verifyAgencyFolio(any()),
        ).thenAnswer((_) async => const Right(null));

        // Act
        final result = await usecase(
          const VerifyFolioGuiaParams(folio: tFolio),
        );

        // Assert
        expect(result, const Right(null));

        // Verificamos que el repositorio se haya llamado exactamente 1 vez
        verify(() => mockRepository.verifyAgencyFolio(tFolio)).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'Debe retornar un [ServerFailure] si el folio es inválido o caducó',
      () async {
        // Arrange
        const tFailure = ServerFailure(
          'El folio ingresado no existe o ha caducado',
        );
        when(
          () => mockRepository.verifyAgencyFolio(any()),
        ).thenAnswer((_) async => const Left(tFailure));

        // Act
        final result = await usecase(
          const VerifyFolioGuiaParams(folio: 'FOLIO-FALSO'),
        );

        // Assert
        expect(result, const Left(tFailure));
        verify(() => mockRepository.verifyAgencyFolio('FOLIO-FALSO')).called(1);
      },
    );
  });
}
