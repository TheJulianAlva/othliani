import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// Importa tu widget y entidad Turista
import 'package:frontend/features/guia/shared/widgets/critical_medical_card.dart';
import 'package:frontend/features/agencia/users/domain/entities/turista.dart';

void main() {
  group('CriticalMedicalCard Widget Test', () {
    testWidgets(
      'Muestra alerta médica si el turista es vulnerable y tiene notas',
      (WidgetTester tester) async {
        // 1. Arrange (Preparamos los datos)
        const ninoRiesgo = Turista(
          id: '1',
          nombre: 'Pedrito',
          viajeId: 'v1',
          status: 'OK',
          bateria: 1.0,
          enCampo: true,
          vulnerabilidad: NivelVulnerabilidad.critica,
          condicionesMedicas: 'Asmático severo',
        );

        // 2. Act (Construimos el widget en el entorno de prueba)
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: CriticalMedicalCard(turista: ninoRiesgo)),
          ),
        );

        // 3. Assert (Verificamos que los textos existan en pantalla)
        expect(find.text('¡ALERTA MÉDICA VITAL!'), findsOneWidget);
        expect(find.text('⚠️ Asmático severo'), findsOneWidget);
      },
    );

    testWidgets('NO muestra la caja si el turista es un adulto estándar', (
      WidgetTester tester,
    ) async {
      // 1. Arrange
      const adultoSano = Turista(
        id: '2',
        nombre: 'Carlos',
        viajeId: 'v1',
        status: 'OK',
        bateria: 1.0,
        enCampo: true,
        vulnerabilidad: NivelVulnerabilidad.estandar,
        // Sin notas médicas
      );

      // 2. Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CriticalMedicalCard(turista: adultoSano)),
        ),
      );

      // 3. Assert (Verificamos que el widget desaparezca / no se renderice)
      expect(find.text('¡ALERTA MÉDICA VITAL!'), findsNothing);
      expect(
        find.byType(Container),
        findsNothing,
      ); // Porque devuelve un SizedBox.shrink()
    });
  });
}
