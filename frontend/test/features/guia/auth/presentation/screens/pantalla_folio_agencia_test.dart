import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:frontend/features/guia/auth/presentation/cubit/guia_agency_login_cubit.dart';
import 'package:frontend/features/guia/auth/presentation/screens/pantalla_folio_agencia.dart';

class MockGuiaAgencyLoginCubit extends MockCubit<GuiaAgencyLoginState>
    implements GuiaAgencyLoginCubit {}

void main() {
  late MockGuiaAgencyLoginCubit mockCubit;

  setUp(() {
    mockCubit = MockGuiaAgencyLoginCubit();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<GuiaAgencyLoginCubit>.value(
        value: mockCubit,
        child: const PantallaFolioAgencia(),
      ),
    );
  }

  group('PantallaFolioAgencia (Widget Test)', () {
    testWidgets(
      'Debe mostrar el campo de texto y el botón de ingreso inicialmente',
      (WidgetTester tester) async {
        when(() => mockCubit.state).thenReturn(GuiaAgencyLoginInitial());

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.byType(TextField), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
        expect(find.text('Ingresar'), findsOneWidget);
      },
    );

    testWidgets(
      'Debe mostrar un CircularProgressIndicator cuando el estado es Loading',
      (WidgetTester tester) async {
        when(() => mockCubit.state).thenReturn(GuiaAgencyLoginLoading());

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'Debe llamar al método submitFolio cuando se presiona el botón de Ingresar',
      (WidgetTester tester) async {
        when(() => mockCubit.state).thenReturn(GuiaAgencyLoginInitial());
        when(() => mockCubit.submitFolio(any())).thenAnswer((_) async {});

        await tester.pumpWidget(createWidgetUnderTest());

        await tester.enterText(find.byType(TextField), 'AG-2024');
        await tester.pumpAndSettle();

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        verify(() => mockCubit.submitFolio('AG-2024')).called(1);
      },
    );

    testWidgets('Muestra un SnackBar si el estado cambia a Failure', (
      WidgetTester tester,
    ) async {
      whenListen(
        mockCubit,
        Stream.fromIterable([const GuiaAgencyLoginFailure('Folio inválido')]),
        initialState: GuiaAgencyLoginInitial(),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Folio inválido'), findsOneWidget);
    });
  });
}
