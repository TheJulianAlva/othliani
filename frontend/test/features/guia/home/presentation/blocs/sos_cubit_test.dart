import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Importa tu SosCubit, UseCase y Entidades
import 'package:frontend/features/guia/home/presentation/blocs/sos/sos_cubit.dart';
import 'package:frontend/features/guia/home/domain/usecases/sucesion_mando_usecase.dart';
import 'package:frontend/features/agencia/trips/domain/entities/viaje.dart';

class MockSucesionMandoUseCase extends Mock implements SucesionMandoUseCase {}

class ViajeMock extends Mock implements Viaje {}

void main() {
  group('SosCubit', () {
    late SosCubit sosCubit;
    // Omitimos el mock del UseCase de Sucesión para simplificar el ejemplo visual

    setUp(() {
      // Inicializas el cubit (inyectando mocks si los tiene)
      sosCubit = SosCubit(
        sucesionMandoUseCase: MockSucesionMandoUseCase(),
        viajeActivo: ViajeMock(),
      );
    });

    tearDown(() {
      sosCubit.close();
    });

    test('El estado inicial debe ser SosIdle', () {
      expect(sosCubit.state, isA<SosIdle>());
    });

    blocTest<SosCubit, SosState>(
      'triggerWarning emite SosWarning(30) inmediatamente',
      build: () => sosCubit,
      act: (cubit) => cubit.triggerWarning(),
      expect: () => [const SosWarning(30)],
    );

    blocTest<SosCubit, SosState>(
      'cancelSos detiene la emergencia y vuelve a SosIdle',
      build: () => sosCubit,
      act: (cubit) {
        cubit.triggerWarning(); // Iniciamos
        cubit.cancelSos(); // Cancelamos de golpe
      },
      // Esperamos que inicie en 30, pero al cancelar vuelva a Idle
      expect: () => [const SosWarning(30), isA<SosIdle>()],
    );
  });
}
