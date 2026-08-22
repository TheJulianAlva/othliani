# Testing Patterns

**Analysis Date:** 2026-08-22

## Test Framework

### Runner

**Flutter (Dart):**
- **Framework:** `flutter_test` (built into Flutter SDK)
- **Config:** No separate config file — runs via `flutter test`
- **Version:** Included with Flutter 3.7.0+

**Additional testing packages:**
- `bloc_test: ^10.0.0` — for Bloc/Cubit state transition testing
- `mocktail: ^1.0.4` — for mocking (pure Dart, no reflection)

### Assertion Library

**Framework:** `flutter_test` provides `expect()` assertions

```dart
import 'package:flutter_test/flutter_test.dart';

expect(actual, matcher); // expect(value, isA<Type>())
expect(actual, equals(expected)); // value equality
expect(actual, isNot(equals(other))); // negation
```

### Run Commands

```bash
# Run all tests
flutter test

# Watch mode (re-run on file changes)
flutter test --watch

# Run specific test file
flutter test test/features/guia/auth/domain/entities/guia_user_test.dart

# Run with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Test File Organization

### Location

**Co-located with source (mirrors source structure):**
- Source: `frontend/lib/features/guia/auth/domain/entities/guia_user.dart`
- Test: `frontend/test/features/guia/auth/domain/entities/guia_user_test.dart`

Directory structure mirrors the `lib/` hierarchy exactly.

### Naming

**Pattern:** `{source_file}_test.dart`
- `guia_user_test.dart` for `guia_user.dart`
- `guia_auth_repository_impl_test.dart` for `guia_auth_repository_impl.dart`
- `guia_login_screen_test.dart` for `guia_login_screen.dart`

### Structure

```
frontend/
├── lib/
│   └── features/
│       └── guia/
│           └── auth/
│               ├── domain/
│               │   ├── entities/
│               │   │   └── guia_user.dart
│               │   ├── repositories/
│               │   │   └── auth_repository.dart
│               │   └── usecases/
│               │       └── verify_folio_usecase.dart
│               ├── data/
│               │   ├── datasources/
│               │   ├── models/
│               │   └── repositories/
│               └── presentation/
│                   ├── blocs/
│                   ├── cubits/
│                   └── screens/
└── test/
    └── features/
        └── guia/
            └── auth/
                ├── domain/
                │   ├── entities/
                │   │   └── guia_user_test.dart
                │   ├── repositories/
                │   ├── usecases/
                │   │   └── verify_folio_usecase_test.dart
                │   └── ...
                ├── data/
                │   ├── datasources/
                │   │   ├── guia_auth_local_data_source_test.dart
                │   │   └── guia_auth_remote_data_source_test.dart
                │   ├── models/
                │   │   └── guia_user_model_test.dart
                │   └── repositories/
                │       └── guia_auth_repository_impl_test.dart
                └── presentation/
                    ├── blocs/
                    ├── cubits/
                    │   └── guia_login_cubit_test.dart
                    └── screens/
                        └── guia_login_screen_test.dart
```

## Test Structure

### AAA Pattern (Arrange-Act-Assert)

All tests follow the **Arrange-Act-Assert** pattern with explicit comments:

```dart
void main() {
  group('GuiaUser Entity', () {
    // 1. Arrange: Preparamos los datos de prueba
    const tGuiaUser1 = GuiaUser(
      id: '123',
      name: 'Roberto Sánchez',
      email: 'roberto@agencia.com',
      phone: '5551234567',
      permissionLevel: 1,
    );

    const tGuiaUser2 = GuiaUser(
      id: '123',
      name: 'Roberto Sánchez',
      email: 'roberto@agencia.com',
      phone: '5551234567',
      permissionLevel: 1,
    );

    test('Debe ser una subclase de Equatable', () {
      // 2. Act: (implicit in this case — no action needed)
      // 3. Assert
      expect(tGuiaUser1, equals(tGuiaUser2));
      expect(tGuiaUser1 == tGuiaUser2, isTrue);
    });
  });
}
```

### Test Organization

```dart
void main() {
  // Global test data (Arrange phase, reused across tests)
  const tEmail = 'test@test.com';
  const tPassword = 'password123';
  const tUserModel = GuiaUserModel(
    id: '1',
    name: 'Guía',
    email: 'g@test.com',
    phone: '123',
    permissionLevel: 1,
  );

  // Grouped test suites
  group('LoginUseCase', () {
    late MockAuthRepository mockRepository;

    setUp(() {
      // Initialize mocks and dependencies
      mockRepository = MockAuthRepository();
    });

    test('should return User when login succeeds', () async {
      // Test implementation
    });

    test('should return ServerFailure when login fails', () async {
      // Test implementation
    });
  });

  group('Another feature', () {
    // More tests
  });
}
```

## Mocking

### Framework

**Library:** `mocktail` (pure Dart mocking, no reflection required)

```dart
import 'package:mocktail/mocktail.dart';

// Create mock class
class MockAuthRepository extends Mock implements AuthRepository {}

// Or for use in bloc tests
class MockCubit extends MockCubit<GuiaLoginState> implements GuiaLoginCubit {}
```

### Mock Definition Pattern

```dart
// Mock data source
class MockRemoteDataSource extends Mock implements GuiaAuthRemoteDataSource {}

// Mock repository
class MockAuthRepository extends Mock implements AuthRepository {}

// Fake for fallback values
class FakeGuiaUserModel extends Fake implements GuiaUserModel {}

void main() {
  setUpAll(() {
    // Register fallback values for complex types
    registerFallbackValue(FakeGuiaUserModel());
  });

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockRepository = MockAuthRepository();
  });
}
```

### Stubbing (when/then)

**Pattern:** `when(() => method(args)).thenAnswer(...)` or `thenThrow(...)`

```dart
// Success path
when(
  () => mockRemoteDataSource.login(any(), any()),
).thenAnswer((_) async => tUserModel);

// Failure path
when(
  () => mockRemoteDataSource.login(any(), any()),
).thenThrow(Exception('Login failed'));

// Void method
when(
  () => mockLocalDataSource.cacheGuiaUser(any()),
).thenAnswer((_) async => Future.value());
```

### Verification (verify)

```dart
// Verify method was called with specific arguments
verify(() => mockRemoteDataSource.login(tEmail, tPassword)).called(1);

// Verify method was NOT called
verifyZeroInteractions(mockLocalDataSource);

// Verify call count
verify(() => mockDataSource.someMethod()).called(2);
```

### Matchers

**Common matchers for mocking:**
- `any()` — matches any value of that type
- `any<String>()` — match any String
- `captureAny()` — capture and inspect the actual value

```dart
when(() => mockRepo.login(any<String>(), any<String>()))
  .thenAnswer((_) async => tUser);
```

## Fixtures and Factories

### Test Data

**Convention: `t` prefix for test constants**

```dart
// In test file
const tFolio = "AG-2024";
const tEmail = 'test@test.com';
const tPassword = 'password123';
const tUserModel = GuiaUserModel(
  id: '1',
  name: 'Guía',
  email: 'g@test.com',
  phone: '123',
  permissionLevel: 1,
);
```

### Location

**Test data lives in test file itself** — no separate fixtures directory. Keep data close to where it's used.

## Coverage

### Requirements

**Coverage targets:** Not explicitly enforced in CI, but encouraged

**View coverage:**
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Test Types

### Unit Tests

**Scope:** Test individual functions, methods, classes in isolation

**Example: Entity test**
```dart
test('GuiaUser should be equal by value', () {
  const user1 = GuiaUser(
    id: '123',
    name: 'Test',
    email: 'test@test.com',
    phone: '555-1234',
    permissionLevel: 1,
  );
  const user2 = GuiaUser(
    id: '123',
    name: 'Test',
    email: 'test@test.com',
    phone: '555-1234',
    permissionLevel: 1,
  );
  
  expect(user1, equals(user2));
});
```

**Example: UseCase test**
```dart
test('should return User when repository login succeeds', () async {
  // Arrange
  when(() => mockRepository.login(any(), any()))
    .thenAnswer((_) async => Right(tUser));
  
  // Act
  final result = await useCase(LoginParams(email: tEmail, password: tPassword));
  
  // Assert
  expect(result, equals(const Right(tUser)));
  verify(() => mockRepository.login(tEmail, tPassword)).called(1);
});
```

**Example: Repository test**
```dart
test('should return Right(user) when remote data source succeeds', () async {
  // Arrange
  when(() => mockRemoteDataSource.login(any(), any()))
    .thenAnswer((_) async => tUserModel);
  when(() => mockLocalDataSource.cacheGuiaUser(any()))
    .thenAnswer((_) async => Future.value());
  
  // Act
  final result = await repository.login(tEmail, tPassword);
  
  // Assert
  expect(result, equals(const Right(tUserModel)));
  verify(() => mockRemoteDataSource.login(tEmail, tPassword)).called(1);
  verify(() => mockLocalDataSource.cacheGuiaUser(tUserModel)).called(1);
});
```

### Bloc/Cubit Tests

**Framework:** `bloc_test` for state transition testing

```dart
import 'package:bloc_test/bloc_test.dart';

void main() {
  group('SosCubit', () {
    late SosCubit sosCubit;

    setUp(() {
      sosCubit = SosCubit(
        sucesionMandoUseCase: MockSucesionMandoUseCase(),
        viajeActivo: ViajeMock(),
      );
    });

    tearDown(() {
      sosCubit.close();
    });

    // Simple state test
    test('El estado inicial debe ser SosIdle', () {
      expect(sosCubit.state, isA<SosIdle>());
    });

    // State transition test
    blocTest<SosCubit, SosState>(
      'triggerWarning emite SosWarning(30) inmediatamente',
      build: () => sosCubit,
      act: (cubit) => cubit.triggerWarning(),
      expect: () => [const SosWarning(30)],
    );

    // Multi-step action test
    blocTest<SosCubit, SosState>(
      'cancelSos detiene la emergencia y vuelve a SosIdle',
      build: () => sosCubit,
      act: (cubit) {
        cubit.triggerWarning(); // Iniciamos
        cubit.cancelSos(); // Cancelamos de golpe
      },
      expect: () => [const SosWarning(30), isA<SosIdle>()],
    );
  });
}
```

**Key bloc_test functions:**
- `build()` — set up the bloc/cubit to test
- `act()` — trigger actions (method calls)
- `expect()` — list expected state transitions in order
- `skip()` — skip N initial states (if needed)
- `seed()` — set initial state instead of constructor default

### Widget Tests

**Framework:** `flutter_test` with `testWidgets`

**Pattern:**

```dart
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

        // Enter text into fields
        final textFields = tester.widgetList<TextField>(find.byType(TextField)).toList();
        await tester.enterText(find.byWidget(textFields[0]), 'guia@test.com');
        await tester.enterText(find.byWidget(textFields[1]), '123456');
        await tester.pumpAndSettle();

        // Tap button
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
  });
}
```

**Common widget test functions:**
- `tester.pumpWidget(widget)` — render widget tree
- `tester.pumpAndSettle()` — pump until no animations pending
- `tester.pump()` — trigger one frame
- `tester.enterText(find, text)` — type into input
- `tester.tap(find)` — tap a widget
- `find.byType(Type)` — find by widget type
- `find.byWidget(widget)` — find specific widget instance
- `find.widgetWithText(Type, text)` — find widget with text
- `find.byKey(key)` — find by Key identifier
- `findsOneWidget`, `findsWidgets(n)`, `findsNothing` — count matchers

**Dependency Injection in widget tests:**
```dart
setUp(() async {
  await sl.reset(); // Clear GetIt service locator
  mockCubit = MockGuiaLoginCubit();
  sl.registerFactory<GuiaLoginCubit>(() => mockCubit); // Register mock
});
```

## Common Patterns

### Async Testing

**Using `async/await` with `expect`:**

```dart
test('should return Either.Right when login succeeds', () async {
  // Arrange
  when(() => mockRepo.login(any(), any()))
    .thenAnswer((_) async => Right(tUser));

  // Act
  final result = await useCase(LoginParams(email: tEmail, password: tPassword));

  // Assert
  expect(result, isA<Right>());
  expect(result.fold((l) => l, (r) => r), equals(tUser));
});
```

### Error Testing

**Testing error paths with Either.Left:**

```dart
test('should return Left(ServerFailure) when API fails', () async {
  // Arrange
  when(() => mockRemoteDataSource.login(any(), any()))
    .thenThrow(Exception('Server error'));

  // Act
  final result = await repository.login(tEmail, tPassword);

  // Assert
  expect(
    result,
    equals(const Left(ServerFailure('Exception: Server error'))),
  );
  verify(() => mockRemoteDataSource.login(tEmail, tPassword)).called(1);
  verifyZeroInteractions(mockLocalDataSource); // Local cache not called on failure
});
```

### Capturing Arguments

```dart
test('should cache user after successful login', () async {
  // Arrange
  when(() => mockRemoteDataSource.login(any(), any()))
    .thenAnswer((_) async => tUserModel);
  final captured = ArgumentCaptor<GuiaUserModel>();
  when(() => mockLocalDataSource.cacheGuiaUser(captured.any()))
    .thenAnswer((_) async => Future.value());

  // Act
  await repository.login(tEmail, tPassword);

  // Assert
  expect(captured.value, equals(tUserModel));
});
```

## Test Lifecycle

### Setup and Teardown

```dart
void main() {
  group('Feature', () {
    late SomeClass someClass;

    // One-time setup before all tests in group
    setUpAll(() async {
      // Register fallback values, global mocks
      registerFallbackValue(FakeObject());
    });

    // Setup before each test
    setUp(() {
      someClass = SomeClass();
      // Initialize mocks, reset state
    });

    // Cleanup after each test
    tearDown(() {
      someClass.dispose();
      // Close streams, bloc, etc.
    });

    test('should do something', () {
      // test
    });
  });
}
```

**For Bloc/Cubit tests:**
```dart
setUp(() {
  bloc = MyBloc(...);
});

tearDown(() {
  bloc.close(); // Must close bloc to release resources
});
```

---

*Testing analysis: 2026-08-22*
