import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
// Importa tu UseCase y Entidad aquí
import 'package:frontend/features/guia/home/domain/usecases/calculate_risk_usecase.dart';
import 'package:frontend/features/agencia/trips/domain/entities/viaje.dart';

void main() {
  late CalculateRiskUseCase usecase;

  setUp(() {
    usecase = CalculateRiskUseCase();
  });

  group('CalculateRiskUseCase - Sensibilidad por Grupo', () {
    test('Debe asignar 25 metros para Grupo Escolar', () {
      final radio = usecase.obtenerRadioSeguro(TipoGrupo.escolar);
      expect(radio, 25.0);
    });

    test('Debe asignar 150 metros para Grupo Aventura Adultos', () {
      final radio = usecase.obtenerRadioSeguro(TipoGrupo.aventuraAdultos);
      expect(radio, 150.0);
    });
  });

  group('CalculateRiskUseCase - Evaluación de Riesgo', () {
    // Coordenadas simuladas (Separadas por ~40 metros en la vida real)
    const posGuia = LatLng(19.432600, -99.133200);
    const posTurista = LatLng(19.432900, -99.133200);

    test('Lanza ALERTA si es Escolar (Límite 25m) y está a 40m', () {
      // Act
      final enPeligro = usecase.evaluarRiesgo(
        posicionGuia: posGuia,
        posicionTurista: posTurista,
        tipoGrupo: TipoGrupo.escolar,
      );

      // Assert
      expect(
        enPeligro,
        isTrue,
        reason: 'Los niños no deben alejarse más de 25m',
      );
    });

    test('NO lanza alerta si es Familiar (Límite 50m) y está a 40m', () {
      // Act
      final enPeligro = usecase.evaluarRiesgo(
        posicionGuia: posGuia,
        posicionTurista: posTurista,
        tipoGrupo: TipoGrupo.familiar,
      );

      // Assert
      expect(
        enPeligro,
        isFalse,
        reason: '40m es seguro para familias (límite 50m)',
      );
    });
  });
}
