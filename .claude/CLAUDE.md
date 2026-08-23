<!-- GSD:project-start source:PROJECT.md -->

## Project

**Veltur**

Veltur es un ecosistema de tres apps Flutter (Turista, Guía, Agencia) que acompaña digitalmente a turistas en viajes grupales: comunicación privada (walkie-talkie), alertas de alejamiento sobre mapa, itinerario offline-first y herramientas como conversor de divisas. Este milestone no construye el backend de producción (NestJS/Redis/PostGIS descrito en las historias de usuario sigue siendo aspiracional) — el foco inmediato es rediseñar Turista y Guía hacia un look cálido y consistente, en preparación para un video de pitch de 3 minutos para un concurso de prototipos ("Reto Prototipo"). El guion del video aún se está ajustando, así que la grabación y el ensamblaje del video quedan para después de este milestone de diseño.

**Core Value:** El rediseño cálido y consistente de Turista y Guía debe verse cuidado y creíble en toda la app (no solo en 3 pantallas aisladas), para que cuando llegue el momento de grabar el video de pitch, la demo se sienta como un producto real.

### Constraints

- **Timeline**: Video de pitch listo en 2 semanas en total; este milestone (rediseño de Turista/Guía) es la primera parte de esa ventana, antes de que grabación/ensamblaje empiecen
- **Tech stack**: Flutter/Dart para frontend, sin introducir backend nuevo en este milestone
- **Idioma**: identificadores de código en inglés, UI y documentación en español (convención del proyecto, ver CLAUDE.md)

<!-- GSD:project-end -->

<!-- GSD:stack-start source:codebase/STACK.md -->

## Technology Stack

## Languages

- Dart 3.7+ - Flutter frontend (three mobile apps: Turista, Guía, Agencia)
- JavaScript (Node.js) - Backend server
- Bash/Shell - Development scripts
- SQL - Planned database migrations (PostgreSQL/PostGIS)

## Runtime

- Flutter SDK 3.38.1 (includes Dart 3.7+)
- Node.js 18+ (via NVM on development machines)
- Dart Pub - Frontend dependency management
- npm - Backend dependency management

## Frameworks

- Flutter - Cross-platform mobile UI framework
- Socket.IO 4.8.0 - Real-time communication (currently only demo-server implemented)
- Express.js - Planned for REST API (not yet implemented, documented in architecture)
- `flutter_test` - Flutter's built-in testing framework
- `bloc_test` 10.0.0 - BLoC testing utilities
- `mocktail` 1.0.4 - Mocking library for tests
- `flutter_gen` 5.12.0 - Code generation for assets and localization
- `flutter_launcher_icons` 0.14.4 - App icon generation

## Key Dependencies

- `dartz` 0.10.1 - Functional error handling (Either type for usecases)
- `equatable` 2.0.8 - Object equality comparison (for BLoC state comparison)
- `get_it` 9.2.0 - Service locator for dependency injection
- `dio` 5.9.1 - HTTP client with interceptors, timeouts, logging
- `http` 1.1.0 - Standard HTTP client (used for Pexels API calls)
- `socket_io_client` 2.0.3 - Socket.IO client for real-time features (Walkie Talkie)
- `geolocator` 10.1.0 - Device GPS location services
- `google_mlkit_text_recognition` 0.11.0 - OCR via Google ML Kit
- `latlong2` 0.9.1 - Latitude/longitude handling for maps
- `connectivity_plus` 6.1.0 - Network connectivity detection
- `flutter_localizations` - Multi-language support (localized strings)
- `dropdown_search` 5.0.6 - Searchable dropdown widget
- `animated_bottom_navigation_bar` 1.3.3 - Custom navigation bar
- `emoji_picker_flutter` 3.1.0 - Emoji picker for chat/messages
- `country_picker` 2.0.26 - Country selection widget
- `mask_text_input_formatter` 2.9.0 - Input masking for phone numbers
- `shared_preferences` 2.5.3 - Key-value local storage (theme, session state)
- `flutter_dotenv` 6.0.0 - Environment variable loading from .env file
- `camera` 0.10.5+5 - Camera access for photos
- `image_picker` 1.0.4 - Image/photo selection
- `file_picker` 8.0.0 - File selection from device
- `pdf` 3.11.3 - PDF generation
- `printing` 5.14.2 - Print document handling
- `path_provider` 2.1.5 - Device file system paths
- `record` 6.2.0 - Audio recording
- `flutter_sound` 9.2.13 - Audio playback and recording
- `speech_to_text` 7.3.0 - Speech recognition (Walkie Talkie)
- `flutter_tts` 4.2.5 - Text-to-speech output
- `csv` 6.0.0 - CSV parsing and generation (trip itinerary import/export)
- `intl` 0.20.2 - Internationalization and number/date formatting
- `uuid` 4.5.2 - UUID generation
- `translator` 1.0.4+1 - Text translation support
- `rxdart` 0.28.0 - Reactive extensions for Dart (event streams)
- `permission_handler` 11.0.1 - Cross-platform permissions (camera, location, microphone)
- `window_manager` 0.5.1 - Window management (desktop support)
- `socket.io` 4.8.0 - Real-time event emitter (Node.js)

## Configuration

- `.env` file for secrets (loaded via `flutter_dotenv`)
- Required env vars:
- Configurable settings:
- `flutter pub get` - Install frontend dependencies
- `flutter pub upgrade` - Update frontend dependencies
- `npm install` - Install backend dependencies
- `flutter doctor` - Verify development environment setup

## Platform Requirements

- Windows, macOS, or Linux
- 8GB+ RAM recommended
- Git version control
- VS Code with Flutter/Dart extensions
- Android Studio (for Android SDK and emulator)
- Docker Desktop (planned for local PostgreSQL/PostGIS)
- iOS (via Flutter)
- Android (via Flutter)
- Backend: Node.js 18+ on Railway (production)

## Database (Planned - Not Yet Implemented)

- PostgreSQL with PostGIS extension (planned for backend)
- Stored locally via Docker during development
- Not currently active; demo server uses in-memory Socket.IO only

<!-- GSD:stack-end -->

<!-- GSD:conventions-start source:CONVENTIONS.md -->

## Conventions

## Naming Patterns

### Files

- `login_screen.dart` for screens
- `auth_repository.dart` for repositories
- `auth_bloc.dart` for Bloc classes
- `auth_state.dart` for state definitions
- `auth_event.dart` for event definitions
- `user_model.dart` for models
- `auth_usecase.dart` for use cases
- `server.js` for server entry point
- `socketService.js` for services (if structured)

### Functions

- `class LoginScreen extends StatelessWidget`
- `class AuthBloc extends Bloc<AuthEvent, AuthState>`
- `class LoginUseCase implements UseCase<User, LoginParams>`
- `class UserModel extends User`
- `class AuthState extends Equatable`
- `final String email;`
- `void login(String email, String password) { }`
- `Future<Either<Failure, User>> call(LoginParams params) async`
- `int distanciaMaxima;` (when naming in Spanish in comments/docs)
- `class AuthCheckRequested extends AuthEvent`
- `class AuthState extends Equatable`
- `const AuthState.authenticated(User user)`

### Variables

- Instance variables: `camelCase` — `final String userId;`
- Private variables: Start with underscore — `final String _apiKey;`
- Constants: `camelCase` — `const int maxAttempts = 3;`
- Test data: Prefix with `t` — `const tUser = User(...)`

### Types

- `class User extends Equatable`
- `class UserModel extends User`
- `abstract class AuthRepository`
- `enum AuthStatus { unknown, authenticated, unauthenticated }`

## Code Style

### Formatting

- **Linting tool:** `flutter_lints` (includes Flutter's official lint rules)
- **Configuration:** `analysis_options.yaml` — includes `package:flutter_lints/flutter.yaml`
- **Run linting:** `flutter analyze` (enforced before commits)
- Line length: Standard Flutter defaults
- Indentation: 2 spaces (Dart standard)
- Semicolons: Required at statement end
- Trailing commas: **Required** on multi-line structures for auto-formatting activation

### Const by Default

### Trailing Commas

## Import Organization

- Always use `package:frontend/...` or `package:backend/...` (absolute imports, not relative)
- Paths map to the project package name defined in `pubspec.yaml`

## Error Handling

- `abstract class Failure extends Equatable` — base class
- `class ServerFailure extends Failure` — server/API errors
- `class CacheFailure extends Failure` — local storage errors
- `class NetworkFailure extends Failure` — connectivity errors

## Logging

- Use `print()` or `debugPrint()` for debug information
- Prefix with emoji for visual scanning (Socket.IO server uses `[+]`, `[!]`, `[🎙]`, `[-]`)
- Backend example: `console.log('[+] Socket connected')`
- Do not log secrets or sensitive data

## Comments

- **Explain WHY, not WHAT** — the code explains what it does
- Comment non-obvious business logic or workarounds
- Avoid stating the obvious: ❌ `i += 1; // Increment i`
- DO comment hacks: ✅ `// We delay here to simulate network latency in mocks`

## Function Design

- Keep functions/methods small and focused
- Single responsibility principle
- Extract complex logic into separate methods
- Use named parameters for clarity (especially in constructors)
- Group related parameters
- Use Equatable for parameter objects in use cases
- Use `Future<T>` for async operations
- Use `Either<Failure, T>` for operations that can fail
- Use `Equatable` for entities to enable value equality

## Module Design

- **Not currently used** — imports target specific files directly
- Example pattern: `import 'package:frontend/features/turista/auth/domain/entities/user.dart';`
- Business logic, independent of frameworks
- Entities (pure Dart classes)
- Repository abstracts (interfaces)
- Use cases (orchestrate business logic)
- Repository implementations
- Data sources (remote/local)
- Models (extend entities, add serialization)
- Screens (StatelessWidget with providers)
- Bloc/Cubit (state management)
- Widgets (UI components)

## State Management

## Dependency Injection

## Commit Message Convention

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation only
- `style:` Formatting (no code change)
- `refactor:` Code restructuring (no feature change)
- `test:` Test additions/modifications
- `feat: add phone verification for tourist login`
- `fix: correct email validation regex`
- `test: add LoginUseCase unit tests`
- `refactor: extract error handling to core layer`

<!-- GSD:conventions-end -->

<!-- GSD:architecture-start source:ARCHITECTURE.md -->

## Architecture

## System Overview

```text

```

## Component Responsibilities

| Component | Responsibility | File |
|-----------|----------------|------|
| **Presentation (UI)** | Render screens, capture user input, display state | `frontend/lib/features/{app}/{feature}/presentation/` |
| **Domain (Business Logic)** | Define business rules, use cases, entities | `frontend/lib/features/{app}/{feature}/domain/` |
| **Data (Persistence/API)** | Fetch/store data, implement repositories | `frontend/lib/features/{app}/{feature}/data/` |
| **Core Services** | Theme, navigation, DI, network, localization | `frontend/lib/core/` |
| **Backend Demo Server** | Real-time event relay via Socket.IO | `backend/demo-server/server.js` |

## Pattern Overview

- **Separation of Concerns:** Each layer has a single, clear responsibility
- **Testability:** Domain layer is pure Dart (no external dependencies); data layer can be mocked
- **Scalability:** Feature-based organization; three apps share common core but have distinct business logic
- **Dependency Injection:** GetIt service locator with app-specific and shared registrations
- **State Management:** flutter_bloc (Cubit for simple state, Bloc for complex events)
- **Routing:** go_router with auth guard redirects and deep linking support
- **Error Handling:** Functional approach using `dartz` Either type for Result pattern

## Layers

- Purpose: Display UI, capture user interactions, delegate to state management (Cubit/Bloc)
- Location: `frontend/lib/features/{app}/{feature}/presentation/`
- Contains: Screens, widgets, Cubits/Blocs (state management)
- Depends on: Domain layer (use cases), core theme/navigation
- Used by: Flutter app (main entry point)
- Rules: Only layer that imports Flutter and Material; all async work delegated to Bloc/Cubit
- Purpose: Pure business logic and rules; independent of UI and data implementation
- Location: `frontend/lib/features/{app}/{feature}/domain/`
- Contains: Entities (business objects), repositories (abstract interfaces), use cases (business actions)
- Depends on: Nothing (pure Dart; no Flutter, no external libraries except for error handling)
- Used by: Presentation layer (via Bloc/Cubit), data layer (implements repos)
- Rules: Dart purity; no imports of Flutter, dio, or other external packages
- Purpose: Concrete implementation of how to fetch/store data (APIs, local cache, databases)
- Location: `frontend/lib/features/{app}/{feature}/data/`
- Contains: Data sources (remote HTTP, local storage), models (JSON serialization), repository implementations
- Depends on: Domain layer (repository interfaces), external libraries (dio for HTTP, shared_preferences for local)
- Used by: DI container (injected into repositories) and domain repositories
- Rules: Translates DTOs to/from domain entities; handles network errors and caching logic
- Purpose: Shared facilities used by all apps and features
- Location: `frontend/lib/core/`
- Contains:

## Data Flow

### Primary Auth & Redirect Flow (Example: Turista)

### Real-Time Communication (Socket.IO)

- Global: `AuthBloc` (authentication status), `ThemeCubit`, `LocaleCubit`, `AccessibilityCubit`
- Per-Feature: `TripBloc`, `ChatBloc`, `ProfileBloc`, `ItineraryBloc`, etc.
- All provided via `MultiBlocProvider` in app root

## Key Abstractions

- Purpose: Encapsulate a single business action with a consistent interface
- Base: `UseCase<ResultType, ParamsType>` (`frontend/lib/core/usecase/usecase.dart`)
- Pattern: `Future<Either<Failure, ResultType>> call(ParamsType params)`
- Example: `LoginUseCase` → `Either<Failure, User>`
- Purpose: Represent success or failure without exceptions
- From package `dartz`
- Pattern: `result.fold((failure) => handleError, (data) => handleSuccess)`
- Used consistently for error handling throughout domain and data layers
- **Entity**: Domain object (pure business data, no JSON methods). Example: `User` in domain/
- **Model**: Data object with JSON serialization (`fromJson`, `toJson`). Example: `UserModel` in data/
- Models extend entities or are separately defined and converted in repository
- **Domain Repository (Abstract)**: Interface defining what data the feature needs
- **Data Repository (Concrete)**: Implementation that fetches from one or more data sources
- Allows mocking data sources for testing and demo mode

## Entry Points

- Location: `frontend/lib/main_turista.dart`
- Triggers: `flutter run -t lib/main_turista.dart` or auto-select for Turista flavor
- Responsibilities: 
- Location: `frontend/lib/main_guia.dart`
- Responsibilities: Same as Turista, but with guia-specific DI and router
- Location: `frontend/lib/main_agencia.dart`
- Responsibilities: Same as Turista, but with agencia-specific DI and router
- Location: `backend/demo-server/server.js`
- Triggers: `npm start` or `node server.js`
- Responsibilities: 

## Architectural Constraints

- **Dependency Direction:** Presentation → Domain ← Data (data and presentation never import each other directly)
- **Threading:** Single-threaded event loop (Flutter/Dart async-await). Backend is single-threaded Node.js with event-driven Socket.IO
- **Global State:** 
- **Demo Mode:** When `kDemoMode` is true (checked globally), all remote data sources return mock data; auth guards are bypassed; Socket.IO client connects to demo server
- **Circular Imports:** Prevented by strict layering; domain has no external dependencies

## Anti-Patterns

### Presentation Layer Importing Data Layer Directly

### Mixing Business Logic in Widgets

### Domain Layer Importing Flutter or External Packages

### Skipping Models in Data Layer

## Error Handling

## Cross-Cutting Concerns

- Backend: Console logging in `server.js` (connection events, panic alerts, channel requests)
- Frontend: Print statements in data sources and Blocs; debug banner disabled in production
- Domain layer: Use case params validated (e.g., email format in `LoginParams`)
- Presentation layer: Form validation before passing to Bloc (e.g., phone number formatting in `phone_screen.dart`)
- Central: `AuthBloc` in `frontend/lib/features/{app}/auth/presentation/bloc/auth_bloc.dart`
- Routing guard: `EnrutadorAppTurista.createRouter()` checks `AuthBloc.state` before allowing navigation
- Persistence: Token/session stored in `SharedPreferences` via `AuthLocalDataSource`
- Provider: `LocaleCubit` reads from `SharedPreferences` and provides `Locale` to MaterialApp
- Strings: Auto-generated from `lib/l10n/app_en.arb` and `app_es.arb` via `flutter gen-l10n`
- Used: `AppLocalizations.of(context)?.loginButton` in widgets

<!-- GSD:architecture-end -->

<!-- GSD:skills-start source:skills/ -->

## Project Skills

| Skill | Description | Path |
|-------|-------------|------|
| remotion-best-practices | Router for all Remotion skills | `.agents/skills/remotion-best-practices/SKILL.md` |
| remotion-captions | Transcribing, displaying and animating captions | `.agents/skills/remotion-captions/SKILL.md` |
| remotion-create | Create a new Remotion video | `.agents/skills/remotion-create/SKILL.md` |
| remotion-docs | Search Remotion documentation | `.agents/skills/remotion-docs/SKILL.md` |
| remotion-maps | Remotion Map animation knowledge | `.agents/skills/remotion-maps/SKILL.md` |
| remotion-render | Export a Remotion video | `.agents/skills/remotion-render/SKILL.md` |
| remotion-studio | Preview a Remotion video | `.agents/skills/remotion-studio/SKILL.md` |
<!-- GSD:skills-end -->

<!-- GSD:workflow-start source:GSD defaults -->

## GSD Workflow Enforcement

Before using Edit, Write, or other file-changing tools, start work through a GSD command so planning artifacts and execution context stay in sync.

Use these entry points:

- `/gsd-quick` for small fixes, doc updates, and ad-hoc tasks
- `/gsd-debug` for investigation and bug fixing
- `/gsd-execute-phase` for planned phase work

Do not make direct repo edits outside a GSD workflow unless the user explicitly asks to bypass it.
<!-- GSD:workflow-end -->

<!-- GSD:profile-start -->

## Developer Profile

> Profile not yet configured. Run `/gsd-profile-user` to generate your developer profile.
> This section is managed by `generate-claude-profile` -- do not edit manually.
<!-- GSD:profile-end -->
