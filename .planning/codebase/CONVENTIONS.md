# Coding Conventions

**Analysis Date:** 2026-08-22

## Naming Patterns

### Files

**Flutter (Dart) - snake_case:**
- `login_screen.dart` for screens
- `auth_repository.dart` for repositories
- `auth_bloc.dart` for Bloc classes
- `auth_state.dart` for state definitions
- `auth_event.dart` for event definitions
- `user_model.dart` for models
- `auth_usecase.dart` for use cases

All `.dart` files use lowercase with underscores (snake_case).

**Node.js - camelCase:**
- `server.js` for server entry point
- `socketService.js` for services (if structured)

### Functions

**PascalCase for classes:**
- `class LoginScreen extends StatelessWidget`
- `class AuthBloc extends Bloc<AuthEvent, AuthState>`
- `class LoginUseCase implements UseCase<User, LoginParams>`
- `class UserModel extends User`
- `class AuthState extends Equatable`

**camelCase for variables, methods, and parameters:**
- `final String email;`
- `void login(String email, String password) { }`
- `Future<Either<Failure, User>> call(LoginParams params) async`
- `int distanciaMaxima;` (when naming in Spanish in comments/docs)

**PascalCase for Events and States:**
- `class AuthCheckRequested extends AuthEvent`
- `class AuthState extends Equatable`
- `const AuthState.authenticated(User user)`

### Variables

**Naming conventions:**
- Instance variables: `camelCase` — `final String userId;`
- Private variables: Start with underscore — `final String _apiKey;`
- Constants: `camelCase` — `const int maxAttempts = 3;`
- Test data: Prefix with `t` — `const tUser = User(...)`

### Types

**PascalCase for all types:**
- `class User extends Equatable`
- `class UserModel extends User`
- `abstract class AuthRepository`
- `enum AuthStatus { unknown, authenticated, unauthenticated }`

## Code Style

### Formatting

**Flutter projects:**
- **Linting tool:** `flutter_lints` (includes Flutter's official lint rules)
- **Configuration:** `analysis_options.yaml` — includes `package:flutter_lints/flutter.yaml`
- **Run linting:** `flutter analyze` (enforced before commits)

**Formatting rules applied:**
- Line length: Standard Flutter defaults
- Indentation: 2 spaces (Dart standard)
- Semicolons: Required at statement end
- Trailing commas: **Required** on multi-line structures for auto-formatting activation

### Const by Default

**Always use `const` when possible** — Flutter skips redraws for const widgets:

```dart
// GOOD
return const Center(
  child: Text('Hola'),
);

// AVOID — missing const
return Center(
  child: Text('Hola'),
);
```

IDE highlights missing `const` with blue underlines.

### Trailing Commas

**Mandatory** for multi-line structures — activates auto-formatting in VS Code:

```dart
// GOOD
Column(
  children: [
    Text('Hola'),
    Text('Mundo'), // <-- Trailing comma required
  ], // <-- Trailing comma required
);

// AVOID
Column(
  children: [
    Text('Hola'),
    Text('Mundo')
  ]
);
```

## Import Organization

**Order of imports:**
1. Dart standard library (`dart:...`)
2. Flutter framework (`package:flutter/...`)
3. Third-party packages (alphabetical)
4. Relative project imports (`package:frontend/...`, `package:backend/...`)

**Example:**
```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/turista/auth/domain/entities/user.dart';
```

**Path aliases:**
- Always use `package:frontend/...` or `package:backend/...` (absolute imports, not relative)
- Paths map to the project package name defined in `pubspec.yaml`

## Error Handling

**Pattern: Functional error handling with dartz Either**

All repository and use case methods return `Future<Either<Failure, T>>`:

```dart
// Domain Repository (abstract)
abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, void>> logout();
}

// Domain UseCase
class LoginUseCase implements UseCase<User, LoginParams> {
  @override
  Future<Either<Failure, User>> call(LoginParams params) async {
    return await repository.login(params.email, params.password);
  }
}

// Handling in Bloc
result.fold(
  (failure) => emit(const AuthState.unauthenticated()), // Left = failure
  (user) => emit(AuthState.authenticated(user)), // Right = success
);
```

**Failure hierarchy:**
- `abstract class Failure extends Equatable` — base class
- `class ServerFailure extends Failure` — server/API errors
- `class CacheFailure extends Failure` — local storage errors
- `class NetworkFailure extends Failure` — connectivity errors

All failures include a message: `const ServerFailure('Error message')`.

**Exception to Either conversion happens in Data layer:**
```dart
try {
  final response = await remoteDataSource.login(email, password);
  return Right(response);
} catch (e) {
  return Left(ServerFailure('Exception: ${e.toString()}'));
}
```

## Logging

**Framework:** `console` (dart `print()`, JavaScript `console.log()`)

**Patterns:**
- Use `print()` or `debugPrint()` for debug information
- Prefix with emoji for visual scanning (Socket.IO server uses `[+]`, `[!]`, `[🎙]`, `[-]`)
- Backend example: `console.log('[+] Socket connected')`
- Do not log secrets or sensitive data

## Comments

**Single-line comments (`//`):**
```dart
// Esta es una variable para almacenar la distancia máxima
final int distanciaMaxima = 100;
```

**Documentation comments (`///`):**
```dart
/// Validates the user's email format.
/// Returns true if email is valid, false otherwise.
bool validateEmail(String email) {
  // implementation
}
```

**When to comment:**
- **Explain WHY, not WHAT** — the code explains what it does
- Comment non-obvious business logic or workarounds
- Avoid stating the obvious: ❌ `i += 1; // Increment i`
- DO comment hacks: ✅ `// We delay here to simulate network latency in mocks`

## Function Design

**Size guidelines:**
- Keep functions/methods small and focused
- Single responsibility principle
- Extract complex logic into separate methods

**Parameters:**
- Use named parameters for clarity (especially in constructors)
- Group related parameters
- Use Equatable for parameter objects in use cases

```dart
// GOOD — use params object
class LoginParams extends Equatable {
  final String email;
  final String password;
  const LoginParams({required this.email, required this.password});
  @override
  List<Object> get props => [email, password];
}

class LoginUseCase implements UseCase<User, LoginParams> {
  Future<Either<Failure, User>> call(LoginParams params) async { }
}

// AVOID — too many individual parameters
Future<Either<Failure, User>> login(String email, String password, String code, bool rememberMe);
```

**Return values:**
- Use `Future<T>` for async operations
- Use `Either<Failure, T>` for operations that can fail
- Use `Equatable` for entities to enable value equality

## Module Design

**Exports (Barrel files):**
- **Not currently used** — imports target specific files directly
- Example pattern: `import 'package:frontend/features/turista/auth/domain/entities/user.dart';`

**Clean Architecture layers:**

**Domain layer** (`features/[app]/[feature]/domain/`):
- Business logic, independent of frameworks
- Entities (pure Dart classes)
- Repository abstracts (interfaces)
- Use cases (orchestrate business logic)

**Data layer** (`features/[app]/[feature]/data/`):
- Repository implementations
- Data sources (remote/local)
- Models (extend entities, add serialization)

**Presentation layer** (`features/[app]/[feature]/presentation/`):
- Screens (StatelessWidget with providers)
- Bloc/Cubit (state management)
- Widgets (UI components)

## State Management

**Bloc pattern for complex state:**
```dart
// Event-driven, great for business logic
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required CheckAuthStatusUseCase checkAuthStatusUseCase})
    : super(const AuthState.unknown()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _checkAuthStatusUseCase(NoParams());
    result.fold(
      (_) => emit(const AuthState.unauthenticated()),
      (user) => emit(user != null ? AuthState.authenticated(user) : const AuthState.unauthenticated()),
    );
  }
}
```

**Cubit pattern for simple state:**
```dart
// Direct method calls, simpler than Bloc
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit({required SharedPreferences sharedPreferences})
    : super(const Locale('es'));

  Future<void> setLocale(Locale locale) async {
    emit(locale);
    await sharedPreferences.setString('languageCode', locale.languageCode);
  }
}
```

## Dependency Injection

**Pattern: GetIt service locator**

```dart
// Registration in locator (e.g., turista_locator.dart)
final getIt = GetIt.instance;

void setupLocator() {
  // Repositories
  getIt.registerSingleton<AuthRepository>(AuthRepositoryImpl(...));
  
  // UseCases
  getIt.registerSingleton<LoginUseCase>(LoginUseCase(getIt()));
  
  // Bloc
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(checkAuthStatusUseCase: getIt()),
  );
}

// Usage in widgets
BlocProvider(
  create: (context) => getIt<AuthBloc>(),
  child: const LoginScreen(),
)
```

## Commit Message Convention

Follow **Conventional Commits** (enforced in CONTRIBUTING.md):

**Types:**
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation only
- `style:` Formatting (no code change)
- `refactor:` Code restructuring (no feature change)
- `test:` Test additions/modifications

**Examples:**
- `feat: add phone verification for tourist login`
- `fix: correct email validation regex`
- `test: add LoginUseCase unit tests`
- `refactor: extract error handling to core layer`

**Format:** `{type}: {lowercase description}`

---

*Convention analysis: 2026-08-22*
