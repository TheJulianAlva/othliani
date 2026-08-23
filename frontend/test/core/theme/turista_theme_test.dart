import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/core/theme/turista_colors.dart';
import 'package:frontend/core/theme/turista_theme.dart';
import 'package:frontend/core/theme/veltur_tokens.dart';
import 'package:frontend/core/widgets/empty_state_widget.dart';
import 'package:frontend/features/turista/chat/presentation/widgets/chat_bubble.dart';

const tEmptyStateIcon = Icons.info_outline;
const tEmptyStateMessage = 'No hay eventos planificados.';
const tLongChatMessage =
    'Este es un mensaje deliberadamente largo para verificar que la burbuja '
    'de chat lo envuelve dentro del ancho máximo permitido sin recortarlo '
    'ni truncarlo con puntos suspensivos, incluso cuando ocupa varias líneas '
    'de texto dentro de la interfaz de usuario de la app Turista.';

const _kSentBubbleKey = Key('sentBubble');
const _kReceivedBubbleKey = Key('receivedBubble');

void main() {
  group('Cadena token -> tema -> widget renderizado (tracer)', () {
    Widget createWidgetUnderTest() {
      return MaterialApp(
        theme: TuristaTheme.lightTheme,
        home: const Scaffold(
          body: Column(
            children: [
              EmptyStateWidget(
                icon: tEmptyStateIcon,
                message: tEmptyStateMessage,
              ),
              ChatBubble(
                key: _kSentBubbleKey,
                message: tLongChatMessage,
                isSent: true,
              ),
              ChatBubble(
                key: _kReceivedBubbleKey,
                message: 'Hola, ¿cómo vas?',
                isSent: false,
              ),
            ],
          ),
        ),
      );
    }

    testWidgets(
      'TuristaTheme.lightTheme expone el token de color primario terracota y el fondo cálido',
      (WidgetTester tester) async {
        // Arrange / Act
        final theme = TuristaTheme.lightTheme;

        // Assert
        expect(theme.colorScheme.primary.toARGB32(), 0xFFE8623D);
        expect(theme.scaffoldBackgroundColor.toARGB32(), 0xFFFFF8F0);
        expect(theme.extension<VelturTokens>(), isNotNull);
      },
    );

    testWidgets(
      'EmptyStateWidget renderiza su ícono con el token teal de VelturTokens',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest());

        // Act
        final icon = tester.widget<Icon>(find.byIcon(tEmptyStateIcon));

        // Assert
        expect(icon.color, TuristaColors.accentTeal);
      },
    );

    testWidgets(
      'ChatBubble enviada usa el token terracota-soft y la recibida el token teal-soft',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest());

        // Act
        final sentContainer = tester.widget<Container>(
          find.descendant(
            of: find.byKey(_kSentBubbleKey),
            matching: find.byType(Container),
          ),
        );
        final receivedContainer = tester.widget<Container>(
          find.descendant(
            of: find.byKey(_kReceivedBubbleKey),
            matching: find.byType(Container),
          ),
        );
        final sentDecoration = sentContainer.decoration as BoxDecoration;
        final receivedDecoration =
            receivedContainer.decoration as BoxDecoration;

        // Assert
        expect(sentDecoration.color, TuristaColors.primarySoft);
        expect(receivedDecoration.color, TuristaColors.accentTealSoft);

        final sentRadius =
            (sentDecoration.borderRadius as BorderRadius).topLeft.x;
        final receivedRadius =
            (receivedDecoration.borderRadius as BorderRadius).topLeft.x;
        expect(sentRadius, 16.0);
        expect(receivedRadius, 16.0);
      },
    );

    testWidgets(
      'Un mensaje largo en ChatBubble se envuelve completo sin recortarse ni truncarse',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createWidgetUnderTest());

        // Act
        final textWidget = tester.widget<Text>(
          find.descendant(
            of: find.byKey(_kSentBubbleKey),
            matching: find.byType(Text),
          ),
        );

        // Assert
        expect(find.text(tLongChatMessage), findsOneWidget);
        expect(textWidget.overflow, isNot(TextOverflow.ellipsis));
        expect(textWidget.maxLines, isNull);
      },
    );

    test(
      'Los componentes del tema usan los radios D-05: botón 24, card 16, input 10',
      () {
        // Arrange
        final theme = TuristaTheme.lightTheme;

        // Act
        final buttonShape =
            theme.elevatedButtonTheme.style?.shape?.resolve(
                  <WidgetState>{},
                )
                as RoundedRectangleBorder;
        final cardShape = theme.cardTheme.shape as RoundedRectangleBorder;
        final inputBorder =
            theme.inputDecorationTheme.border as OutlineInputBorder;

        // Assert
        expect((buttonShape.borderRadius as BorderRadius).topLeft.x, 24.0);
        expect((cardShape.borderRadius as BorderRadius).topLeft.x, 16.0);
        expect(inputBorder.borderRadius.topLeft.x, 10.0);
      },
    );

    test(
      'El textTheme sigue la escala UI-SPEC (bodyLarge/labelLarge/titleLarge/displaySmall) con exactamente dos pesos',
      () {
        // Arrange
        final textTheme = TuristaTheme.lightTheme.textTheme;

        // Act / Assert
        expect(textTheme.bodyLarge?.fontSize, 16);
        expect(textTheme.bodyLarge?.fontWeight, FontWeight.w400);
        expect(textTheme.labelLarge?.fontSize, 14);
        expect(textTheme.labelLarge?.fontWeight, FontWeight.w600);
        expect(textTheme.titleLarge?.fontSize, 20);
        expect(textTheme.titleLarge?.fontWeight, FontWeight.w600);
        expect(textTheme.displaySmall?.fontSize, 32);
        expect(textTheme.displaySmall?.fontWeight, FontWeight.w600);

        final weightsUsed = <FontWeight?>{
          textTheme.bodyLarge?.fontWeight,
          textTheme.labelLarge?.fontWeight,
          textTheme.titleLarge?.fontWeight,
          textTheme.displaySmall?.fontWeight,
        };
        expect(weightsUsed.length, 2);
      },
    );

    test(
      'Cada token de sombra está teñido con el tono cálido (o el acento del glow correspondiente), nunca con negro neutro',
      () {
        // Arrange
        final tokens = TuristaTheme.tokens;

        int channelByte(double component) => (component * 255).round();

        void expectTint(List<BoxShadow> shadows, Color tint) {
          for (final shadow in shadows) {
            expect(channelByte(shadow.color.r), channelByte(tint.r));
            expect(channelByte(shadow.color.g), channelByte(tint.g));
            expect(channelByte(shadow.color.b), channelByte(tint.b));
            expect(shadow.color, isNot(equals(Colors.black)));
          }
        }

        // Act / Assert
        expectTint(tokens.shadowSm, TuristaColors.shadowTint);
        expectTint(tokens.shadowMd, TuristaColors.shadowTint);
        expectTint(tokens.shadowLg, TuristaColors.shadowTint);
        expectTint(tokens.shadowGlowPrimary, TuristaColors.primary);
        expectTint(tokens.shadowGlowDanger, TuristaColors.danger);
      },
    );
  });
}
