import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/core/theme/turista_theme.dart';
import 'package:frontend/features/turista/home/presentation/widgets/itinerary_event_card.dart';

const tTime = '09:30';
const tTitle = 'Visita al museo';
const tShortDescription = 'Recorrido guiado por la exposición principal.';

Widget _pumpCard({
  String time = tTime,
  String title = tTitle,
  String description = tShortDescription,
}) {
  return MaterialApp(
    theme: TuristaTheme.lightTheme,
    home: Scaffold(
      body: SingleChildScrollView(
        child: ItineraryEventCard(
          time: time,
          title: title,
          description: description,
        ),
      ),
    ),
  );
}

void main() {
  group('ItineraryEventCard', () {
    testWidgets(
      'renderiza el pill de hora sobre el token primarySoft con radio completo '
      'y su etiqueta con el rol tipográfico Label',
      (WidgetTester tester) async {
        // Arrange + Act
        await tester.pumpWidget(_pumpCard());
        await tester.pumpAndSettle();

        // Assert: pill container (BoxShape.circle == radio completo)
        final pillContainer = tester.widget<Container>(
          find
              .ancestor(
                of: find.text(tTime),
                matching: find.byType(Container),
              )
              .first,
        );
        final decoration = pillContainer.decoration as BoxDecoration;
        expect(decoration.shape, BoxShape.circle);
        expect(decoration.color, TuristaTheme.tokens.primarySoft);

        // Assert: la etiqueta de hora usa el rol Label (14/600)
        final timeText = tester.widget<Text>(find.text(tTime));
        expect(timeText.style?.fontSize, 14);
        expect(timeText.style?.fontWeight, FontWeight.w600);
      },
    );

    testWidgets(
      'una descripción de 300 caracteres se renderiza completa sin elipsis '
      'ni maxLines, y la tarjeta crece verticalmente para acomodarla',
      (WidgetTester tester) async {
        final longDescription = List.generate(
          300,
          (i) => 'a',
        ).join();

        // Arrange: altura de referencia con descripción corta
        await tester.pumpWidget(_pumpCard());
        await tester.pumpAndSettle();
        final shortCardHeight =
            tester.getSize(find.byType(ItineraryEventCard)).height;

        // Act: pump con descripción larga
        await tester.pumpWidget(_pumpCard(description: longDescription));
        await tester.pumpAndSettle();

        // Assert: no overflow/exception, texto sin truncar
        expect(tester.takeException(), isNull);
        final descriptionText = tester.widget<Text>(
          find.text(longDescription),
        );
        expect(descriptionText.data, longDescription);
        expect(descriptionText.maxLines, isNull);
        expect(descriptionText.overflow, isNot(TextOverflow.ellipsis));

        final longCardHeight =
            tester.getSize(find.byType(ItineraryEventCard)).height;
        expect(longCardHeight, greaterThan(shortCardHeight));
      },
    );

    testWidgets(
      'cinco tarjetas apiladas no superponen sus límites renderizados '
      '(mitad mecánica del backstop de volumen poblado)',
      (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          MaterialApp(
            theme: TuristaTheme.lightTheme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: List.generate(
                    5,
                    (i) => ItineraryEventCard(
                      time: '0$i:00',
                      title: 'Evento $i',
                      description: 'Descripción del evento número $i.',
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Act
        final cardFinder = find.byType(ItineraryEventCard);
        expect(cardFinder, findsNWidgets(5));

        final rects = List.generate(
          5,
          (i) => tester.getRect(cardFinder.at(i)),
        );

        // Assert: cada tarjeta termina antes de que empiece la siguiente
        for (var i = 0; i < rects.length - 1; i++) {
          expect(
            rects[i].bottom,
            lessThanOrEqualTo(rects[i + 1].top),
            reason: 'La tarjeta $i se superpone con la tarjeta ${i + 1}',
          );
        }
      },
    );
  });
}
