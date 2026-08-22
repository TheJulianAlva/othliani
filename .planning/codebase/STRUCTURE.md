# Codebase Structure

**Analysis Date:** 2026-08-22

## Directory Layout

```
othliani/                          # Monorepo root
├── frontend/                       # Flutter frontend (single codebase, three app flavors)
│   ├── lib/
│   │   ├── main_turista.dart      # Entry point: Turista app
│   │   ├── main_guia.dart         # Entry point: Guía app
│   │   ├── main_agencia.dart      # Entry point: Agencia app
│   │   │
│   │   ├── core/                  # Shared infrastructure (all apps)
│   │   │   ├── di/                # Dependency injection (service locator setup)
│   │   │   ├── navigation/        # Go router configuration per app
│   │   │   ├── theme/             # Material Design theme, colors, constants
│   │   │   ├── widgets/           # Shared UI widgets (buttons, modals, app bars)
│   │   │   ├── services/          # Reusable services (location, pexels photos, unsaved changes)
│   │   │   ├── network/           # HTTP client (Dio) configuration
│   │   │   ├── l10n/              # Localization (Spanish/English)
│   │   │   ├── session/           # Auth session management
│   │   │   ├── error/             # Failure/error classes
│   │   │   ├── usecase/           # Base UseCase abstract class
│   │   │   ├── utils/             # Utility functions (e164 phone formatting, etc.)
│   │   │   ├── providers/         # State providers (locale, theme, accessibility)
│   │   │   ├── tools/             # Shared tool features (e.g., currency converter)
│   │   │   └── demo/              # Mock data and demo mode config
│   │   │
│   │   └── features/              # App-specific features (organized by app)
│   │       ├── turista/           # Turista app features
│   │       │   ├── auth/          # Authentication feature
│   │       │   │   ├── domain/    # Business logic (entities, repositories, use cases)
│   │       │   │   ├── data/      # Data fetching (data sources, models, repo implementations)
│   │       │   │   └── presentation/ # UI (screens, widgets, Bloc/Cubit)
│   │       │   ├── home/          # Trip listing and home screen
│   │       │   ├── chat/          # Messaging
│   │       │   ├── profile/       # User profile
│   │       │   └── settings/      # App settings
│   │       │
│   │       ├── guia/              # Guía app features (parallel structure)
│   │       │   ├── auth/
│   │       │   ├── home/
│   │       │   ├── chat/
│   │       │   ├── profile/
│   │       │   ├── trips/         # Trip management (guide-specific)
│   │       │   ├── sos/           # Emergency/SOS feature
│   │       │   ├── shared/        # Shared widgets/screens for Guía app
│   │       │   └── settings/
│   │       │
│   │       └── agencia/           # Agencia app features (parallel structure)
│   │           ├── auth/
│   │           ├── dashboard/     # Agency dashboard
│   │           ├── trips/         # Trip management
│   │           ├── users/         # User management
│   │           ├── audit/         # Audit logging
│   │           └── settings/
│   │
│   ├── test/                       # Integration and widget tests
│   ├── android/                    # Android platform code
│   ├── ios/                        # iOS platform code
│   ├── macos/                      # macOS platform code
│   ├── windows/                    # Windows platform code
│   ├── linux/                      # Linux platform code
│   ├── web/                        # Web platform code
│   ├── pubspec.yaml               # Dependencies
│   └── pubspec.lock               # Locked dependency versions
│
├── backend/                        # Node.js backend
│   └── demo-server/               # WebSocket demo server
│       ├── server.js              # Socket.IO server (real-time events)
│       ├── package.json           # Node dependencies
│       └── package-lock.json      # Locked Node dependencies
│
├── docs/                           # Documentation
│   ├── README.md                  # Documentation index
│   ├── 02-CONFIGURACION_ENTORNO.md    # Development setup
│   ├── 03-ARQUITECTURA_FRONTEND.md    # Frontend architecture (Clean Architecture)
│   ├── 05-ARQUITECTURA_BACKEND.md     # Backend API design (planned, not yet implemented)
│   ├── 06-ESTANDARES_DE_CODIGO.md     # Code standards
│   ├── product_requirements/      # Product requirements and user stories
│   └── archive/                   # Historical docs, aspirational designs (not current)
│
├── .planning/                      # GSD planning artifacts
│   └── codebase/                  # Codebase analysis documents (this directory)
│
├── CLAUDE.md                       # Project instructions for Claude
├── CONTRIBUTING.md                # Git/PR workflow
├── README.md                       # Project overview
└── .gitignore                      # Git ignore rules

```

## Directory Purposes

**frontend/lib/core/**
- Purpose: Centralized infrastructure shared by all three apps
- Contains: Theme configuration, routing, DI setup, network client, localization, reusable widgets
- Key files: `service_locator.dart` (shared DI), `enrutador_app_{app}.dart` (per-app routers), `app_theme.dart` (material design)

**frontend/lib/features/{app}/**
- Purpose: App-specific features organized using Clean Architecture
- Contains: Domain (business logic), Data (persistence/API), Presentation (UI)
- Apps: `turista/`, `guia/`, `agencia/` — each with similar internal structure but different business logic

**frontend/lib/features/{app}/{feature}/domain/**
- Purpose: Pure business logic and contracts
- Contains: Entities (business objects), repositories (abstract interfaces), use cases (business actions)
- Rule: No Flutter imports, no external library dependencies

**frontend/lib/features/{app}/{feature}/data/**
- Purpose: Concrete implementation of how to get/store data
- Contains: Data sources (HTTP, local), models (JSON serialization), repository implementations
- Files follow pattern: `{feature}_*_data_source.dart`, `{feature}_model.dart`, `{feature}_repository_impl.dart`

**frontend/lib/features/{app}/{feature}/presentation/**
- Purpose: UI and state management
- Contains: Screens (full-page widgets), widgets (reusable UI components), Bloc/Cubit (state)
- Files follow pattern: `{feature}_screen.dart`, `{feature}_bloc.dart`, `{feature}_cubit.dart`

**backend/demo-server/**
- Purpose: Real-time event relay server for trip communication
- Contains: Socket.IO server listening on port 3000 (or env PORT)
- Functionality: Relays panic alerts, audio streams, and channel state between connected clients

## Key File Locations

**Entry Points:**
- `frontend/lib/main_turista.dart`: Turista app entry point (app initialization, DI setup, router creation)
- `frontend/lib/main_guia.dart`: Guía app entry point
- `frontend/lib/main_agencia.dart`: Agencia app entry point
- `backend/demo-server/server.js`: Node.js WebSocket server entry point

**Configuration:**
- `frontend/pubspec.yaml`: Flutter dependencies
- `backend/demo-server/package.json`: Node.js dependencies
- `frontend/lib/core/theme/app_theme.dart`: Material Design theme definitions
- `frontend/lib/core/navigation/routes_turista.dart`: Turista app route constants
- `frontend/lib/core/di/service_locator.dart`: Shared DI registration
- `frontend/lib/core/di/turista_locator.dart`: Turista-specific DI registration

**Core Logic:**
- `frontend/lib/core/network/dio_client.dart`: HTTP client setup
- `frontend/lib/core/usecase/usecase.dart`: Base UseCase abstract class
- `frontend/lib/core/error/failures.dart`: Failure hierarchy for error handling
- `frontend/lib/core/services/location_service.dart`: GPS location service
- `frontend/lib/core/demo/demo_socket_service.dart`: Socket.IO client connection

**Testing:**
- `frontend/test/`: Test directory (mirrors lib/ structure)
- `frontend/test/features/turista/auth/` etc.: Feature-specific tests

## Naming Conventions

**Files:**
- Dart files: `snake_case.dart` (e.g., `login_cubit.dart`, `auth_repository_impl.dart`)
- Feature directories: `lowercase` (e.g., `features/turista/auth/`)
- Classes: `PascalCase` (e.g., `LoginCubit`, `AuthRepositoryImpl`)

**Directories:**
- Feature: `lowercase_feature_name/` (e.g., `auth/`, `home/`, `chat/`)
- Layer: `domain/`, `data/`, `presentation/` (exact names)
- Data source/Repository: Suffixed with `_data_source.dart`, `_repository_impl.dart`
- Bloc/Cubit: Suffixed with `_bloc.dart`, `_cubit.dart`
- Screen: Suffixed with `_screen.dart`
- State/Event: Suffixed with `_state.dart`, `_event.dart`

**Variables & Functions:**
- camelCase for local variables and functions
- Types and classes: PascalCase
- Constants: UPPER_SNAKE_CASE or camelCase depending on context

**Localization:**
- Strings: Spanish for UI text, English for code identifiers
- Example: Button label is "Iniciar Sesión" (Spanish), variable is `loginButton` (English)

## Where to Add New Code

**New Feature (Example: "Notifications"):**

1. **Create feature directory structure:**
   - `frontend/lib/features/turista/notifications/domain/`
   - `frontend/lib/features/turista/notifications/data/`
   - `frontend/lib/features/turista/notifications/presentation/`

2. **Implement domain layer first:**
   - Create entity: `frontend/lib/features/turista/notifications/domain/entities/notification.dart`
   - Create repository interface: `frontend/lib/features/turista/notifications/domain/repositories/notification_repository.dart`
   - Create use cases: `frontend/lib/features/turista/notifications/domain/usecases/get_notifications_usecase.dart`

3. **Implement data layer:**
   - Create remote data source: `frontend/lib/features/turista/notifications/data/datasources/notification_remote_data_source.dart`
   - Create model: `frontend/lib/features/turista/notifications/data/models/notification_model.dart`
   - Create repository implementation: `frontend/lib/features/turista/notifications/data/repositories/notification_repository_impl.dart`

4. **Implement presentation layer:**
   - Create Bloc: `frontend/lib/features/turista/notifications/presentation/bloc/notification_bloc.dart`
   - Create state/event: `frontend/lib/features/turista/notifications/presentation/bloc/notification_state.dart`, `notification_event.dart`
   - Create screen: `frontend/lib/features/turista/notifications/presentation/screens/notifications_screen.dart`

5. **Register in DI:**
   - Add data source and repository registration to `frontend/lib/core/di/turista_locator.dart`
   - Add use cases and Bloc registration

6. **Add routing:**
   - Add route constant to `frontend/lib/core/navigation/routes_turista.dart`
   - Add GoRoute to `frontend/lib/core/navigation/enrutador_app_turista.dart`

**New Component/Widget (Shared across apps):**
- Location: `frontend/lib/core/widgets/{component_name}.dart`
- Make it app-agnostic (no app-specific logic)
- Document usage with comments

**Utilities & Helpers:**
- Shared utilities: `frontend/lib/core/utils/{utility_name}.dart`
- Feature-specific utilities: `frontend/lib/features/{app}/{feature}/data/utils/` or `presentation/utils/`

**Tests:**
- Location mirrors source: `frontend/test/features/{app}/{feature}/{layer}/{file_name}_test.dart`
- Example: For `login_cubit.dart`, create `test/features/turista/auth/presentation/cubit/login_cubit_test.dart`
- Use `bloc_test` for Bloc/Cubit testing, `mocktail` for mocking

**Backend Endpoints (Planned):**
- Not yet implemented. Planned location: `backend/src/routes/` for route handlers
- Planned to follow Express.js conventions with middleware and controllers

## Special Directories

**frontend/lib/core/tools/**
- Purpose: Shared tools that aren't core infrastructure but reusable across all apps
- Generated: No
- Committed: Yes
- Example: `currency/` subdirectory has its own domain/data/presentation for currency conversion
- Pattern: Follows Clean Architecture internally; can be used by any app's Bloc via DI

**frontend/lib/core/demo/**
- Purpose: Demo mode configuration and mock data services
- Generated: No
- Committed: Yes
- Files: `demo_config.dart` (global `kDemoMode` flag), `demo_socket_service.dart` (mock Socket.IO client)
- Activated by: Environment variable or build flag; bypasses auth and uses mock data sources

**frontend/lib/l10n/**
- Purpose: Generated localization files
- Generated: Yes (auto-generated by `flutter gen-l10n` from .arb files)
- Committed: Yes (check in generated files, not regenerate in CI)
- Source: `lib/l10n/app_en.arb` and `app_es.arb` (human-editable)
- Usage: `AppLocalizations.of(context)?.labelKey`

**frontend/test/**
- Purpose: Widget and integration tests
- Generated: No
- Committed: Yes
- Structure: Mirrors `lib/` tree for easy navigation (e.g., test for `lib/features/turista/auth/presentation/cubit/login_cubit.dart` goes in `test/features/turista/auth/presentation/cubit/login_cubit_test.dart`)

**docs/archive/**
- Purpose: Historical documentation (completed iterations, aspirational architectures not yet built)
- Generated: No
- Committed: Yes
- Status: **NOT** the source of truth; reference only for historical context
- Examples: NestJS/Mapbox/Isar proposals, old sprint summaries
- Action: Ignore when implementing features (use `docs/` root instead)

---

*Structure analysis: 2026-08-22*
