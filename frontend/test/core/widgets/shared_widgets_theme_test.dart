import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/core/theme/turista_colors.dart';
import 'package:frontend/core/theme/turista_theme.dart';
import 'package:frontend/core/widgets/info_modal.dart';
import 'package:frontend/core/widgets/phone_number_field.dart';
import 'package:frontend/core/widgets/saving_overlay.dart';

const tMensaje = 'Guardando progreso...';
const tTitle = 'Aviso de Privacidad';
const tContent = 'Contenido de prueba para el modal informativo.';

/// Tema "Guía"-shaped de prueba: mismo esqueleto de `TuristaTheme.lightTheme`
/// pero con un `VelturTokens.copyWith` que cambia el color de `border` (usado
/// por el indicador de arrastre de InfoModal), siguiendo el mismo patrón de
/// `empty_state_widget_test.dart` para probar la portabilidad D-02.
final _guiaStandInTokens = TuristaTheme.tokens.copyWith(
  border: const Color(0xFF6C4CE0), // púrpura, deliberadamente distinto
);

Widget _pumpSavingOverlay(ThemeData theme) {
  return MaterialApp(
    theme: theme,
    home: const Scaffold(body: SavingOverlay(mensaje: tMensaje)),
  );
}

Widget _pumpSavingOverlayTrigger() {
  return MaterialApp(
    theme: TuristaTheme.lightTheme,
    home: Scaffold(
      body: Builder(
        builder: (context) {
          return ElevatedButton(
            onPressed: () => SavingOverlay.show(context, mensaje: tMensaje),
            child: const Text('abrir'),
          );
        },
      ),
    ),
  );
}

Widget _pumpInfoModalTrigger(ThemeData theme) {
  return MaterialApp(
    theme: theme,
    home: Scaffold(
      body: Builder(
        builder: (context) {
          return ElevatedButton(
            onPressed: () => InfoModal.show(
              context: context,
              title: tTitle,
              content: tContent,
            ),
            child: const Text('abrir'),
          );
        },
      ),
    ),
  );
}

Widget _pumpPhoneField(ThemeData theme) {
  return MaterialApp(
    theme: theme,
    home: Scaffold(body: PhoneNumberField(onChanged: (_) {})),
  );
}

void main() {
  group('SavingOverlay (tokens de tema)', () {
    testWidgets(
      'El CircularProgressIndicator usa el color primario terracota del tema',
      (WidgetTester tester) async {
        // Arrange
        // No usamos pumpAndSettle: el CircularProgressIndicator es una
        // animación indeterminada e infinita que nunca "asienta".
        await tester.pumpWidget(_pumpSavingOverlay(TuristaTheme.lightTheme));
        await tester.pump(kThemeAnimationDuration);

        // Act
        final spinner = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );

        // Assert
        expect(spinner.color, TuristaColors.primary);
      },
    );

    testWidgets(
      'La sombra del círculo del spinner usa el tinte cálido, no uno neutro',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(_pumpSavingOverlay(TuristaTheme.lightTheme));
        await tester.pump(kThemeAnimationDuration);

        // Act
        final container = tester.widget<Container>(
          find.byKey(const Key('savingOverlaySpinnerCircle')),
        );
        final decoration = container.decoration! as BoxDecoration;
        final shadow = decoration.boxShadow!.first;

        // Assert
        expect(shadow.color, isNot(Colors.black.withValues(alpha: 0.18)));
        expect(shadow.color, TuristaTheme.tokens.shadowMd.first.color);
      },
    );

    testWidgets(
      'SavingOverlay.show abre una barrera no descartable y bloquea el back-pop',
      (WidgetTester tester) async {
        // Arrange
        // No usamos pumpAndSettle: SavingOverlay contiene un
        // CircularProgressIndicator con animación indeterminada infinita.
        await tester.pumpWidget(_pumpSavingOverlayTrigger());
        await tester.tap(find.text('abrir'));
        await tester.pump(); // abre el showDialog
        await tester.pump(const Duration(milliseconds: 200)); // transición
        expect(find.byType(SavingOverlay), findsOneWidget);

        // Act: intenta cerrar tocando fuera del diálogo (barrera)
        await tester.tapAt(const Offset(5, 5));
        await tester.pump();

        // Assert: sigue presente porque barrierDismissible es false
        expect(find.byType(SavingOverlay), findsOneWidget);

        // Act: intenta el back-pop del sistema (PopScope canPop: false)
        final navigator = tester.state<NavigatorState>(find.byType(Navigator));
        await navigator.maybePop();
        await tester.pump();

        // Assert: el overlay sigue en pantalla, el pop fue bloqueado
        expect(find.byType(SavingOverlay), findsOneWidget);
      },
    );
  });

  group('InfoModal (tokens de tema)', () {
    testWidgets(
      'La hoja usa BorderRadius superior de 24 y el color de superficie del tema',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(_pumpInfoModalTrigger(TuristaTheme.lightTheme));
        await tester.tap(find.text('abrir'));
        await tester.pumpAndSettle();

        // Act
        final container = tester.widget<Container>(
          find.byKey(const Key('infoModalSheet')),
        );
        final decoration = container.decoration! as BoxDecoration;

        // Assert
        expect(
          decoration.borderRadius,
          BorderRadius.vertical(
            top: Radius.circular(TuristaTheme.tokens.radiusLg),
          ),
        );
        expect(decoration.color, TuristaColors.surface);
      },
    );

    testWidgets(
      'Pumped bajo un segundo VelturTokens, el indicador de arrastre cambia de color',
      (WidgetTester tester) async {
        // Arrange: tema Turista real
        await tester.pumpWidget(_pumpInfoModalTrigger(TuristaTheme.lightTheme));
        await tester.tap(find.text('abrir'));
        await tester.pumpAndSettle();
        final firstHandle = tester.widget<Container>(
          find.byKey(const Key('infoModalDragHandle')),
        );
        final firstColor = (firstHandle.decoration! as BoxDecoration).color;

        // Act: cierra y reabre bajo un segundo tema con VelturTokens distinto
        await tester.tap(find.text('Cerrar'));
        await tester.pumpAndSettle();

        final secondTheme = TuristaTheme.lightTheme.copyWith(
          extensions: <ThemeExtension<dynamic>>[_guiaStandInTokens],
        );
        await tester.pumpWidget(_pumpInfoModalTrigger(secondTheme));
        await tester.tap(find.text('abrir'));
        await tester.pumpAndSettle();
        final secondHandle = tester.widget<Container>(
          find.byKey(const Key('infoModalDragHandle')),
        );
        final secondColor = (secondHandle.decoration! as BoxDecoration).color;

        // Assert
        expect(firstColor, TuristaColors.border);
        expect(secondColor, _guiaStandInTokens.border);
        expect(secondColor, isNot(firstColor));
      },
    );
  });

  group('PhoneNumberField (hereda el tema)', () {
    testWidgets(
      'El borde resuelto del TextFormField tiene radio 10, heredado del tema',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(_pumpPhoneField(TuristaTheme.lightTheme));
        await tester.pumpAndSettle();

        // Act
        final field = tester.widget<TextField>(find.byType(TextField));
        final decoration = field.decoration!;

        // Assert: sin `border` local, el campo hereda el radio 10 del tema
        expect(decoration.border, isNull);
        final themeBorder =
            TuristaTheme.lightTheme.inputDecorationTheme.border!
                as OutlineInputBorder;
        expect(themeBorder.borderRadius, BorderRadius.circular(10));
      },
    );

    testWidgets(
      'Al enfocar, el borde del tema se vuelve terracota (focusedBorder)',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(_pumpPhoneField(TuristaTheme.lightTheme));
        await tester.pumpAndSettle();

        // Act
        await tester.tap(find.byType(TextFormField));
        await tester.pumpAndSettle();

        // Assert: el theme's focusedBorder (no un override local) es terracota
        final focusedBorder =
            TuristaTheme.lightTheme.inputDecorationTheme.focusedBorder!
                as OutlineInputBorder;
        expect(focusedBorder.borderSide.color, TuristaColors.primary);
      },
    );

    testWidgets(
      'onChanged sigue emitiendo el par de valores enmascarado/sin máscara',
      (WidgetTester tester) async {
        // Arrange
        PhoneNumberValue? emitted;
        await tester.pumpWidget(
          MaterialApp(
            theme: TuristaTheme.lightTheme,
            home: Scaffold(
              body: PhoneNumberField(
                onChanged: (value) => emitted = value,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Act
        await tester.enterText(find.byType(TextFormField), '7225698563');
        await tester.pumpAndSettle();

        // Assert
        expect(emitted, isNotNull);
        expect(emitted!.localDigits, '7225698563');
        expect(emitted!.localMasked, '722-569-8563');
        expect(emitted!.countryCode, 'MX');
        expect(emitted!.dialCode, '+52');
      },
    );
  });
}
