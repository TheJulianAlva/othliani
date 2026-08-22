<!-- refreshed: 2026-08-22 -->
# Architecture

**Analysis Date:** 2026-08-22

## System Overview

Veltur is a monorepo with two distinct subsystems: a Flutter frontend (three apps sharing a common architecture) and a minimal Node.js backend (demo server for real-time communication).

```text
┌──────────────────────────────────────────────────────────────────────┐
│                        Frontend Layer (Flutter)                       │
├────────────────────┬──────────────────────┬────────────────────────┤
│   Turista App      │    Guía App          │    Agencia App         │
│ `frontend/lib/`    │  `frontend/lib/`     │  `frontend/lib/`       │
└────────────┬───────┴────────────┬─────────┴────────────┬───────────┘
             │                    │                      │
             ▼                    ▼                      ▼
┌──────────────────────────────────────────────────────────────────────┐
│              Shared Core Infrastructure Layer                        │
│        `frontend/lib/core/` (theme, DI, routing, network)           │
└──────────────────────────────────────┬───────────────────────────────┘
                                       │
                                       ▼
┌──────────────────────────────────────────────────────────────────────┐
│                   Backend Service Layer (Node.js)                    │
│              `backend/demo-server/` (Socket.IO Server)              │
│                   Real-time communication (WebSockets)              │
└──────────────────────────────────────────────────────────────────────┘
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

**Overall:** Clean Architecture with three layers (Presentation, Domain, Data), per-app separation in frontend, shared infrastructure core.

**Key Characteristics:**
- **Separation of Concerns:** Each layer has a single, clear responsibility
- **Testability:** Domain layer is pure Dart (no external dependencies); data layer can be mocked
- **Scalability:** Feature-based organization; three apps share common core but have distinct business logic
- **Dependency Injection:** GetIt service locator with app-specific and shared registrations
- **State Management:** flutter_bloc (Cubit for simple state, Bloc for complex events)
- **Routing:** go_router with auth guard redirects and deep linking support
- **Error Handling:** Functional approach using `dartz` Either type for Result pattern

## Layers

**Presentation Layer:**
- Purpose: Display UI, capture user interactions, delegate to state management (Cubit/Bloc)
- Location: `frontend/lib/features/{app}/{feature}/presentation/`
- Contains: Screens, widgets, Cubits/Blocs (state management)
- Depends on: Domain layer (use cases), core theme/navigation
- Used by: Flutter app (main entry point)
- Rules: Only layer that imports Flutter and Material; all async work delegated to Bloc/Cubit

**Domain Layer:**
- Purpose: Pure business logic and rules; independent of UI and data implementation
- Location: `frontend/lib/features/{app}/{feature}/domain/`
- Contains: Entities (business objects), repositories (abstract interfaces), use cases (business actions)
- Depends on: Nothing (pure Dart; no Flutter, no external libraries except for error handling)
- Used by: Presentation layer (via Bloc/Cubit), data layer (implements repos)
- Rules: Dart purity; no imports of Flutter, dio, or other external packages

**Data Layer:**
- Purpose: Concrete implementation of how to fetch/store data (APIs, local cache, databases)
- Location: `frontend/lib/features/{app}/{feature}/data/`
- Contains: Data sources (remote HTTP, local storage), models (JSON serialization), repository implementations
- Depends on: Domain layer (repository interfaces), external libraries (dio for HTTP, shared_preferences for local)
- Used by: DI container (injected into repositories) and domain repositories
- Rules: Translates DTOs to/from domain entities; handles network errors and caching logic

**Core Infrastructure:**
- Purpose: Shared facilities used by all apps and features
- Location: `frontend/lib/core/`
- Contains:
  - `di/`: Service locator setup for shared and app-specific dependencies
  - `network/`: HTTP client (dio) configuration
  - `navigation/`: go_router setup, route guards, route definitions per app
  - `theme/`: Material Design theme (light/dark), colors, constants
  - `widgets/`: Reusable UI widgets (buttons, modals, etc.)
  - `services/`: Location service, Pexels photo service, unsaved changes tracking
  - `l10n/`: Localization strings (Spanish/English)
  - `session/`: Auth session management
  - `error/`: Failure base class and error types
  - `usecase/`: Base UseCase abstract class
  - `tools/`: Shared feature tools with their own domain/data/presentation (e.g., currency converter)
  - `demo/`: Mock data and demo mode configuration

## Data Flow

### Primary Auth & Redirect Flow (Example: Turista)

1. **App Start** (`frontend/lib/main_turista.dart` lines 21-36)
   - Initialize shared dependencies via `initSharedDependencies()`
   - Initialize app-specific dependencies via `initTuristaDependencies()`
   - Read auth state from `SharedPreferences`
   - Connect demo Socket.IO client (if demo mode enabled)
   
2. **Router Creation** (`frontend/lib/main_turista.dart` lines 76-86)
   - Create `EnrutadorAppTurista` router with initial location based on auth state
   - Set up auth guard redirect based on `AuthBloc` state

3. **Auth Check** (`frontend/lib/features/turista/auth/presentation/bloc/auth_bloc.dart`)
   - On app launch, `AuthBloc.AuthCheckRequested()` event calls `CheckAuthStatusUseCase`
   - Use case calls `AuthRepository.checkAuthStatus()` (domain boundary)
   - Repository calls `AuthRemoteDataSource` (HTTP) or `AuthLocalDataSource` (cache)
   - Result (Either<Failure, User>) returned and emitted as state
   
4. **Route Guard** (`frontend/lib/core/navigation/enrutador_app_turista.dart` lines 45-79)
   - GoRouter listens to `AuthBloc.stream` via `GoRouterRefreshStream`
   - If not authenticated and not on auth screen → redirect to login or folio
   - If authenticated and on auth screen → redirect to home
   - Demo mode bypasses all guards

5. **Feature Request** (Example: Get Trip)
   - Presentation layer calls `TripBloc.add(GetCurrentTripRequested())`
   - Bloc calls `GetCurrentTripUseCase(params)`
   - Use case calls `TripRepository.getCurrentTrip()`
   - Repository delegates to `TripRemoteDataSource` or mock data source
   - Response converted from JSON model to domain entity
   - Result returned as Either<Failure, Trip>
   - Bloc emits state (Loading → Success/Failure)
   - Presentation layer listens and re-renders

### Real-Time Communication (Socket.IO)

1. **Client Connection** (`frontend/lib/core/demo/demo_socket_service.dart`)
   - Frontend initiates Socket.IO connection to demo server
   - Emits `joinTrip` event with trip ID

2. **Event Broadcasting** (`backend/demo-server/server.js` lines 13-50)
   - Server receives `joinTrip`, adds socket to room
   - When client emits `turista_panico` (emergency), server broadcasts to room
   - When guide emits audio stream, server relays to other participants

3. **UI Reaction** (Feature-specific listeners)
   - Frontend listens to Socket.IO events and updates local Bloc/Cubit state
   - UI re-renders based on new state

**State Management:**
- Global: `AuthBloc` (authentication status), `ThemeCubit`, `LocaleCubit`, `AccessibilityCubit`
- Per-Feature: `TripBloc`, `ChatBloc`, `ProfileBloc`, `ItineraryBloc`, etc.
- All provided via `MultiBlocProvider` in app root

## Key Abstractions

**UseCase Pattern:**
- Purpose: Encapsulate a single business action with a consistent interface
- Base: `UseCase<ResultType, ParamsType>` (`frontend/lib/core/usecase/usecase.dart`)
- Pattern: `Future<Either<Failure, ResultType>> call(ParamsType params)`
- Example: `LoginUseCase` → `Either<Failure, User>`

**Either Type (Functional Result):**
- Purpose: Represent success or failure without exceptions
- From package `dartz`
- Pattern: `result.fold((failure) => handleError, (data) => handleSuccess)`
- Used consistently for error handling throughout domain and data layers

**Entity vs Model:**
- **Entity**: Domain object (pure business data, no JSON methods). Example: `User` in domain/
- **Model**: Data object with JSON serialization (`fromJson`, `toJson`). Example: `UserModel` in data/
- Models extend entities or are separately defined and converted in repository

**Repository Pattern:**
- **Domain Repository (Abstract)**: Interface defining what data the feature needs
- **Data Repository (Concrete)**: Implementation that fetches from one or more data sources
- Allows mocking data sources for testing and demo mode

## Entry Points

**Frontend App (Turista):**
- Location: `frontend/lib/main_turista.dart`
- Triggers: `flutter run -t lib/main_turista.dart` or auto-select for Turista flavor
- Responsibilities: 
  - Initialize DI (shared + turista-specific)
  - Set up MultiBlocProvider with core Blocs
  - Create and configure GoRouter
  - Launch MaterialApp.router with theme and localization

**Frontend App (Guía):**
- Location: `frontend/lib/main_guia.dart`
- Responsibilities: Same as Turista, but with guia-specific DI and router

**Frontend App (Agencia):**
- Location: `frontend/lib/main_agencia.dart`
- Responsibilities: Same as Turista, but with agencia-specific DI and router

**Backend Demo Server:**
- Location: `backend/demo-server/server.js`
- Triggers: `npm start` or `node server.js`
- Responsibilities: 
  - Listen for Socket.IO connections on port 3000
  - Accept client joins to trip rooms
  - Relay real-time events (panic alerts, audio streams, channel state)

## Architectural Constraints

- **Dependency Direction:** Presentation → Domain ← Data (data and presentation never import each other directly)
- **Threading:** Single-threaded event loop (Flutter/Dart async-await). Backend is single-threaded Node.js with event-driven Socket.IO
- **Global State:** 
  - `GetIt.instance` singleton service locator (`frontend/lib/core/di/service_locator.dart`)
  - Auth state kept in `AuthBloc` and `SharedPreferences` for persistence
  - Theme/locale preference in `SharedPreferences` (read on startup by Cubits)
- **Demo Mode:** When `kDemoMode` is true (checked globally), all remote data sources return mock data; auth guards are bypassed; Socket.IO client connects to demo server
- **Circular Imports:** Prevented by strict layering; domain has no external dependencies

## Anti-Patterns

### Presentation Layer Importing Data Layer Directly

**What happens:** A Cubit imports and instantiates a repository directly instead of via DI.

**Why it's wrong:** Breaks dependency inversion; makes testing harder; loses mock/real switching via DI.

**Do this instead:** Inject repository via constructor from DI container (`sl<Repository>()`); request from Bloc factory setup in `turista_locator.dart` line 145.

### Mixing Business Logic in Widgets

**What happens:** A Screen widget directly calls API methods or makes database queries.

**Why it's wrong:** Violates separation of concerns; makes the widget untestable; couples UI to implementation details.

**Do this instead:** Delegate all logic to Bloc/Cubit. Widget should only call `context.read<Bloc>().add(Event())` and select state.

### Domain Layer Importing Flutter or External Packages

**What happens:** A use case or entity imports `package:flutter` or `package:dio`.

**Why it's wrong:** Breaks domain layer independence; makes testing domain logic without Flutter setup impossible.

**Do this instead:** Keep domain pure Dart. If external data is needed, define it as an abstract repository interface in domain; let data layer implement it.

### Skipping Models in Data Layer

**What happens:** Mapping JSON directly to domain entities in data source.

**Why it's wrong:** Couples domain entities to API contract; makes API changes break domain logic.

**Do this instead:** Create models (e.g., `UserModel`) with `fromJson`/`toJson`; convert to entities in repository implementation.

## Error Handling

**Strategy:** Functional programming with Either type; no exceptions raised across layer boundaries.

**Patterns:**

1. **Domain Layer:** Use cases return `Future<Either<Failure, Result>>`
   - Example: `LoginUseCase.call(params)` returns `Future<Either<Failure, User>>`

2. **Data Layer:** Data sources catch exceptions and return failures
   - HTTP errors → `ServerFailure`
   - Network errors → `NetworkFailure`
   - Cache errors → `CacheFailure`
   - Example in `auth_remote_data_source.dart`: try-catch wraps HTTP call

3. **Presentation Layer:** Bloc/Cubit handles Either via fold
   ```dart
   result.fold(
     (failure) => emit(LoginFailure(failure.message)),
     (user) => emit(LoginSuccess(user))
   );
   ```

4. **Base Failure Class:** `frontend/lib/core/error/failures.dart` defines hierarchy
   - `ServerFailure`, `NetworkFailure`, `CacheFailure`, custom app failures

## Cross-Cutting Concerns

**Logging:** 
- Backend: Console logging in `server.js` (connection events, panic alerts, channel requests)
- Frontend: Print statements in data sources and Blocs; debug banner disabled in production

**Validation:**
- Domain layer: Use case params validated (e.g., email format in `LoginParams`)
- Presentation layer: Form validation before passing to Bloc (e.g., phone number formatting in `phone_screen.dart`)

**Authentication:**
- Central: `AuthBloc` in `frontend/lib/features/{app}/auth/presentation/bloc/auth_bloc.dart`
- Routing guard: `EnrutadorAppTurista.createRouter()` checks `AuthBloc.state` before allowing navigation
- Persistence: Token/session stored in `SharedPreferences` via `AuthLocalDataSource`

**Localization:**
- Provider: `LocaleCubit` reads from `SharedPreferences` and provides `Locale` to MaterialApp
- Strings: Auto-generated from `lib/l10n/app_en.arb` and `app_es.arb` via `flutter gen-l10n`
- Used: `AppLocalizations.of(context)?.loginButton` in widgets

---

*Architecture analysis: 2026-08-22*
