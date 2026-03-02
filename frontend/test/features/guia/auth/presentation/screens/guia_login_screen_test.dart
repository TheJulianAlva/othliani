import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import 'package:frontend/features/guia/auth/presentation/cubit/guia_login_cubit.dart';
import 'package:frontend/features/guia/auth/presentation/screens/guia_login_screen.dart';

class MockGuiaLoginCubit extends MockCubit<GuiaLoginState>
    implements GuiaLoginCubit {}

final sl = GetIt.instance;

void main() {
  late MockGuiaLoginCubit mockCubit;

  setUp(() async {
    await sl.reset();
    mockCubit = MockGuiaLoginCubit();
    sl.registerFactory<GuiaLoginCubit>(() => mockCubit);
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(home: GuiaLoginScreen());
  }

  group('GuiaLoginScreen (Widget Test)', () {
    testWidgets(
      'Debe tener dos campos de texto (Email y Contraseña) y un botón de Ingresar',
      (WidgetTester tester) async {
        when(() => mockCubit.state).thenReturn(GuiaLoginInitial());

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.byType(TextField), findsNWidgets(2));
        expect(find.widgetWithText(ElevatedButton, 'Ingresar'), findsOneWidget);
      },
    );

    testWidgets(
      'Llama a login(email, password) al presionar el botón Ingresar',
      (WidgetTester tester) async {
        when(() => mockCubit.state).thenReturn(GuiaLoginInitial());
        when(() => mockCubit.login(any(), any())).thenAnswer((_) async {});

        await tester.pumpWidget(createWidgetUnderTest());

        // Obtenemos los campos de texto
        final textFields =
            tester.widgetList<TextField>(find.byType(TextField)).toList();
        expect(textFields.length, 2);

        // El índice 0 es el email, el 1 es el password
        await tester.enterText(find.byWidget(textFields[0]), 'guia@test.com');
        await tester.enterText(find.byWidget(textFields[1]), '123456');
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(ElevatedButton, 'Ingresar'));
        await tester.pump();

        verify(() => mockCubit.login('guia@test.com', '123456')).called(1);
      },
    );

    testWidgets(
      'Muestra un CircularProgressIndicator cuando el estado es Loading',
      (WidgetTester tester) async {
        when(() => mockCubit.state).thenReturn(GuiaLoginLoading());

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets('Muestra un SnackBar si el estado cambia a Failure', (
      WidgetTester tester,
    ) async {
      whenListen(
        mockCubit,
        Stream.fromIterable([const GuiaLoginFailure('Error de prueba')]),
        initialState: GuiaLoginInitial(),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Error de prueba'), findsOneWidget);
    });
  });
}
