import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/core/theme/turista_colors.dart';
import 'package:frontend/core/theme/turista_theme.dart';
import 'package:frontend/core/theme/veltur_tokens.dart';
import 'package:frontend/core/widgets/empty_state_widget.dart';

const tIcon = Icons.info_outline;
const tMessage = 'No hay eventos planificados.';

/// Tema "Guía"-shaped de prueba: reutiliza la misma [TuristaTheme.lightTheme]
/// pero registra una segunda instancia de [VelturTokens] con un accentTeal
/// claramente distinto, para probar que EmptyStateWidget es portable entre
/// temas (D-02) y no importa TuristaColors directamente.
final _guiaStandInTokens = TuristaTheme.tokens.copyWith(
  accentTeal: const Color(0xFF6C4CE0), // púrpura, deliberadamente distinto
);

Widget _pumpWithTheme(ThemeData theme) {
  return MaterialApp(
    theme: theme,
    home: const Scaffold(
      body: EmptyStateWidget(icon: tIcon, message: tMessage),
    ),
  );
}

void main() {
  group('EmptyStateWidget (contrato de portabilidad D-02)', () {
    testWidgets(
      'Renderiza el ícono con el token teal de Turista bajo TuristaTheme.lightTheme',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(_pumpWithTheme(TuristaTheme.lightTheme));

        // Act
        final icon = tester.widget<Icon>(find.byIcon(tIcon));

        // Assert
        expect(icon.color, TuristaColors.accentTeal);
      },
    );

    testWidgets(
      'La MISMA instancia de EmptyStateWidget renderiza un color DISTINTO bajo un segundo VelturTokens registrado',
      (WidgetTester tester) async {
        // Arrange: primer tema (Turista real)
        await tester.pumpWidget(_pumpWithTheme(TuristaTheme.lightTheme));
        await tester.pumpAndSettle();
        final firstIcon = tester.widget<Icon>(find.byIcon(tIcon)).color;

        // Act: segundo tema, mismo esqueleto pero con VelturTokens.copyWith
        // (accentTeal distinto) — simula el registro que haría Guía.
        // MaterialApp envuelve `theme` en AnimatedTheme, así que hace falta
        // pumpAndSettle() para que la transición termine antes de leer el
        // color renderizado.
        final secondTheme = TuristaTheme.lightTheme.copyWith(
          extensions: <ThemeExtension<dynamic>>[_guiaStandInTokens],
        );
        await tester.pumpWidget(_pumpWithTheme(secondTheme));
        await tester.pumpAndSettle();
        final secondIcon = tester.widget<Icon>(find.byIcon(tIcon)).color;

        // Assert: no puede pasar con ambos "mal" — el primero debe ser
        // exactamente el token de Turista, y el segundo debe ser distinto.
        expect(firstIcon, TuristaColors.accentTeal);
        expect(secondIcon, _guiaStandInTokens.accentTeal);
        expect(secondIcon, isNot(firstIcon));
      },
    );

    testWidgets(
      'VelturTokens.of(context) bajo un MaterialApp sin extensión registrada devuelve VelturTokens.fallback sin lanzar',
      (WidgetTester tester) async {
        // Arrange
        late VelturTokens resolvedTokens;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                resolvedTokens = VelturTokens.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        // Assert
        expect(resolvedTokens, VelturTokens.fallback);
      },
    );
  });
}
