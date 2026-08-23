import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/core/theme/turista_theme.dart';
import 'package:frontend/features/turista/home/presentation/widgets/walkie_talkie_button.dart';

void main() {
  final tokens = TuristaTheme.tokens;
  const scheme = ColorScheme.light(
    primary: Color(0xFFE8623D),
    secondary: Color(0xFF1FADA0),
    surface: Colors.white,
    error: Color(0xFFE5484D),
  );

  group('WalkieTalkieButton.decorationFor (contrato de tres estados)', () {
    test(
      'Canal libre y sin grabar: relleno terracota primario y sombra cálida en reposo',
      () {
        // Arrange & Act
        final decoration = WalkieTalkieButton.decorationFor(
          isRecording: false,
          isChannelBusy: false,
          tokens: tokens,
          scheme: scheme,
        );

        // Assert
        expect(decoration.color, scheme.primary);
        expect(decoration.boxShadow, tokens.shadowMd);
      },
    );

    test(
      'Grabando: relleno del token danger y halo shadowGlowDanger juntos',
      () {
        // Arrange & Act
        final decoration = WalkieTalkieButton.decorationFor(
          isRecording: true,
          isChannelBusy: false,
          tokens: tokens,
          scheme: scheme,
        );

        // Assert: ambas señales (relleno y halo) cambian a la vez — ninguna
        // por sí sola carga el significado de "micrófono en vivo".
        expect(decoration.color, tokens.danger);
        expect(decoration.boxShadow, tokens.shadowGlowDanger);
      },
    );

    test('Canal ocupado: relleno del token warn, no primario', () {
      // Arrange & Act
      final decoration = WalkieTalkieButton.decorationFor(
        isRecording: false,
        isChannelBusy: true,
        tokens: tokens,
        scheme: scheme,
      );

      // Assert
      expect(decoration.color, tokens.warn);
      expect(decoration.color, isNot(scheme.primary));
    });

    test(
      'Los tres rellenos de estado son distintos entre sí (guardia de privacidad)',
      () {
        // Arrange
        final idle = WalkieTalkieButton.decorationFor(
          isRecording: false,
          isChannelBusy: false,
          tokens: tokens,
          scheme: scheme,
        );
        final recording = WalkieTalkieButton.decorationFor(
          isRecording: true,
          isChannelBusy: false,
          tokens: tokens,
          scheme: scheme,
        );
        final busy = WalkieTalkieButton.decorationFor(
          isRecording: false,
          isChannelBusy: true,
          tokens: tokens,
          scheme: scheme,
        );

        // Assert: si dos de los tres fueran iguales, un usuario no podría
        // distinguir a simple vista si su voz se está transmitiendo.
        expect(idle.color, isNot(recording.color));
        expect(idle.color, isNot(busy.color));
        expect(recording.color, isNot(busy.color));
      },
    );
  });

  group('WalkieTalkieButton (accesibilidad)', () {
    testWidgets(
      'Expone un nodo Semantics con la etiqueta "Mantén presionado para hablar"',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            theme: TuristaTheme.lightTheme,
            home: const Scaffold(
              body: WalkieTalkieButton(tripId: 'demo-trip'),
            ),
          ),
        );
        await tester.pump(kThemeAnimationDuration);

        // Assert
        expect(
          find.bySemanticsLabel('Mantén presionado para hablar'),
          findsOneWidget,
        );
      },
    );
  });
}
