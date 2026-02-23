import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/features/guia/auth/data/datasources/guia_auth_local_data_source.dart';
import 'package:frontend/features/guia/auth/data/models/guia_user_model.dart';

// Creamos el Mock de SharedPreferences
class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late GuiaAuthLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = GuiaAuthLocalDataSourceImpl(
      sharedPreferences: mockSharedPreferences,
    );
  });

  const tUserModel = GuiaUserModel(
    id: '1',
    name: 'Test',
    email: 'test@test.com',
    phone: '123',
    permissionLevel: 1,
  );
  final tExpectedJsonString = jsonEncode(tUserModel.toJson());

  group('cacheGuiaUser', () {
    test(
      'Debe llamar a SharedPreferences para cachear el usuario (escribir en disco)',
      () async {
        // Arrange
        when(
          () => mockSharedPreferences.setString(any(), any()),
        ).thenAnswer((_) async => true);

        // Act
        await dataSource.cacheGuiaUser(tUserModel);

        // Assert
        verify(
          () => mockSharedPreferences.setString(
            'CACHED_GUIA_USER',
            tExpectedJsonString,
          ),
        ).called(1);
      },
    );
  });

  group('getLastGuiaUser', () {
    test('Debe retornar el GuiaUserModel si hay uno en caché', () async {
      // Arrange
      when(
        () => mockSharedPreferences.getString(any()),
      ).thenReturn(tExpectedJsonString);

      // Act
      final result = await dataSource.getLastGuiaUser();

      // Assert
      verify(
        () => mockSharedPreferences.getString('CACHED_GUIA_USER'),
      ).called(1);
      expect(result, equals(tUserModel));
    });

    test('Debe retornar null si no hay datos en caché', () async {
      // Arrange
      when(() => mockSharedPreferences.getString(any())).thenReturn(null);

      // Act
      final result = await dataSource.getLastGuiaUser();

      // Assert
      expect(result, isNull);
    });
  });
}
