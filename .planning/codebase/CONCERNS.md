# Codebase Concerns

**Analysis Date:** 2026-08-22

## Architectural Violations

### Clean Architecture Breakdown in Presentation Layer

**Issue:** Presentation layer makes direct HTTP calls to Nominatim OpenStreetMap API.

**Files:**
- `frontend/lib/features/agencia/trips/presentation/screens/trip_creation_screen.dart` (lines 1746, 1808)

**Impact:**
- Violates Clean Architecture separation of concerns
- Business logic (geocoding) is mixed with UI code
- Makes the presentation layer untestable and tightly coupled to external services
- Changes to geolocation logic require UI layer modifications

**Fix approach:**
- Extract geocoding logic into `data/datasources/` layer
- Create a `LocationGeocodingRepository` that abstracts Nominatim API
- Expose through a UseCase (`ReverseGeocodeLocationUseCase`)
- Call from Cubit state management instead of Widget callbacks

### Incomplete Clean Architecture Integration

**Issue:** Clean Architecture not fully implemented in all features.

**Files:**
- `frontend/lib/features/guia/home/presentation/screens/home_wrapper_screen.dart` (line 18-20)
  - Contains explicit TODO comment: "[TODO: Arquitectura Clean]"
  - GuiaSessionCubit injection commented out because it's not globally registered
  - Mixing manual dependency injection with service locator

**Impact:**
- Session management not properly abstracted
- Inconsistent DI patterns across the app
- Makes refactoring and testing harder
- Reduces maintainability

**Fix approach:**
- Complete the global GuiaSessionCubit registration in service_locator
- Use consistent dependency injection pattern throughout
- Remove manual SharedPreferences calls from non-data layers

## Monolithic Screen Components

### Oversized Presentation Files

**Issue:** Large screen files violate single responsibility principle and are difficult to test/maintain.

**Files:**
- `frontend/lib/features/agencia/trips/presentation/screens/trip_creation_screen.dart` (2159 lines)
  - Contains step-by-step wizard UI, validation logic, and HTTP geocoding calls
  - Handles form state, navigation, and external API interactions
  - Multiple nested modal dialogs with complex state management

- `frontend/lib/features/agencia/trips/presentation/screens/itinerary_builder_screen.dart` (1985 lines)
  - Complex multi-day itinerary editing with nested widgets
  - Handles activity creation, deletion, and reordering

- `frontend/lib/features/agencia/shared/data/datasources/mock_agencia_datasource.dart` (1885 lines)
  - Massive hardcoded mock data for the entire agency feature
  - Makes hot reload slow and difficult to navigate

- `frontend/lib/features/agencia/trips/presentation/widgets/itinerary_builder/activity_edit_dialog.dart` (1330 lines)
  - Single modal with too many responsibilities

**Impact:**
- Extremely difficult to navigate and maintain
- Hard to extract reusable components
- Makes testing nearly impossible (no test files found in codebase)
- Slows down IDE performance
- Increases cognitive load for developers

**Fix approach:**
- Extract modals into separate, smaller files
- Break large screens into composable sub-screens (Step 1 Screen, Step 2 Screen, etc.)
- Create custom widget hierarchies for complex sections
- Migrate mock data to external JSON fixtures or stub servers
- Target max 300-400 lines per screen file

## Backend Not Yet Implemented

### Minimal Backend Implementation

**Issue:** Backend architecture documented but not implemented; only demo Socket.IO server exists.

**Files:**
- `backend/demo-server/server.js` (56 lines)
  - Bare-bones Socket.IO server with no authentication, validation, or business logic
  - No actual trip management, geolocation queries, or data persistence

**Missing:**
- Planned Express.js REST API (`docs/05-ARQUITECTURA_BACKEND.md` describes it, not implemented)
- PostgreSQL database integration
- PostGIS geospatial queries for distance calculations
- Authentication middleware
- API route handlers for trip CRUD, user management, alert handling
- Database migrations system
- Proper error handling and logging

**Impact:**
- Frontend depends on mock data sources that won't work in production
- No persistence layer for trips, users, or other domain entities
- Demo mode hardcoded in frontend (can't switch to real backend)
- Security features (authentication, authorization) not implemented
- Geospatial features requiring PostGIS cannot be tested against real backend

**Fix approach:**
1. Implement Express.js REST API following documented architecture
2. Set up PostgreSQL + PostGIS database locally
3. Create database migrations for schema
4. Implement auth middleware and routes
5. Implement trip management endpoints
6. Implement alert/SOS handling endpoints
7. Replace frontend mock datasources with real API clients
8. Remove hardcoded demo mode flag from frontend

## Test Coverage Gaps

### No Automated Tests

**Issue:** No test files found in the entire codebase.

**Files:**
- No `.test.dart` or `.spec.dart` files in `frontend/`
- No test directory structure
- `pubspec.yaml` has test dependencies listed (bloc_test, mocktail) but never used

**Impact:**
- Risk of regressions when modifying code
- No validation that business logic works as intended
- Refactoring becomes dangerous without test safety net
- Complex features like trip creation wizard have untested edge cases
- State management (Bloc/Cubit) changes have no validation

**Untested Critical Areas:**
- Trip creation workflow (Step 1 → Step 2 → Step 3 validation)
- Itinerary building with dynamic activities
- Auto-save/draft recovery mechanism
- Geolocation and distance calculations
- Error handling for API failures
- Form validation for sensitive fields (phone, payment info)

**Fix approach:**
- Set up test infrastructure: test files in `features/*/presentation/bloc_test/` and `features/*/data/test/`
- Create unit tests for all Cubit/Bloc logic (trip_creation_cubit, itinerary_builder_cubit)
- Create widget tests for critical screens
- Create integration tests for user flows
- Target 70%+ coverage for business logic
- Add pre-commit hooks to enforce test presence for new code

## Demo Mode Hardcoded to Production

### Demo Mode Always Enabled

**Issue:** Demo mode flag hardcoded to `true` in production code.

**Files:**
- `frontend/lib/core/demo/demo_config.dart` (line 3): `const bool kDemoMode = true;`

**Impact:**
- App always uses fake Socket.IO simulation instead of real backend
- Users cannot switch to production backend
- Confusing for testing: demo data appears instead of real state
- Cannot validate real backend integration
- Deployment would require code modification, bypassing version control

**Fix approach:**
- Move `kDemoMode` to `.env` file (environment-based configuration)
- Create runtime configuration system using BuildConfig or similar
- Implement feature flags (Firebase Remote Config or custom API)
- Set to `false` in production builds
- Document the demo/production switch in README

## Security & Sensitive Data

### Potential Secret Exposure in Comments

**Issue:** Code comments reference API endpoints and configuration.

**Files:**
- `frontend/lib/features/guia/home/data/services/sucesion_mando_local_service.dart` (line 67)
  - Comment: "En producción → dio.post('/api/agencia/alertas/sos', data: payload)"

**Impact:**
- API structure exposed in source code
- Production endpoint paths visible in repository history
- May aid attackers in reconnaissance

**Fix approach:**
- Remove endpoint URLs from comments
- Document API structure in separate ARCHITECTURE.md (not exposed in code comments)
- Use configuration for all endpoints

### SharedPreferences Used for Sensitive Data

**Issue:** SharedPreferences stores user session and preference data without encryption.

**Files:**
- `frontend/lib/main_guia.dart` (line 29)
- `frontend/lib/features/guia/auth/presentation/cubit/guia_session_cubit.dart` (line 41)
- `frontend/lib/features/guia/profile/data/eco_stats_service.dart`
- Multiple presentation files using SharedPreferences directly

**Impact:**
- User session data stored in plaintext on device
- Compromised device can be used to access user account
- Personal preferences and statistics exposed
- Not compliant with security best practices for mobile

**Fix approach:**
- Use flutter_secure_storage for authentication tokens
- Use flutter_secure_storage for any PII or sensitive preferences
- Keep non-sensitive preferences in SharedPreferences (theme, language)
- Document which data should use which storage mechanism

### Direct HTTP Calls to Third-party APIs

**Issue:** API keys and endpoints embedded in code.

**Files:**
- `frontend/lib/core/services/pexels_service.dart` (line 8)
  - Accesses PEXELS_API_KEY from dotenv
  - Direct HTTP calls to external service

**Impact:**
- API key exposure if .env file leaked
- Tightly couples app to Pexels API
- No rate limiting or circuit breaking
- No caching strategy

**Fix approach:**
- Route all third-party API calls through backend
- Backend stores and manages API keys
- Frontend calls backend endpoints instead
- Backend implements rate limiting and circuit breaking

## Missing Error Handling

### Incomplete Error Recovery

**Issue:** Large presentation files make HTTP calls without comprehensive error handling.

**Files:**
- `frontend/lib/features/agencia/trips/presentation/screens/trip_creation_screen.dart`
  - Nominatim geocoding calls have minimal error handling (silent fail with return [])
  - No user-facing error messages for network failures
  - No retry logic for transient failures

**Impact:**
- Silent failures confuse users
- No indication when geocoding fails
- Network errors not reported to user
- Crashes may occur without stack traces

**Fix approach:**
- Implement comprehensive error handling for all network calls
- Show user-friendly error messages for all failure scenarios
- Implement exponential backoff retry for transient errors
- Log errors for debugging (Sentry integration recommended)
- Test error paths thoroughly (currently untested)

## Dependency Management Concerns

### Large Dependency List with Mixed Concerns

**Issue:** `pubspec.yaml` has 37 dependencies with overlapping functionality and unclear purpose.

**Files:**
- `frontend/pubspec.yaml`

**Examples:**
- Both `provider` and `flutter_bloc` for state management
- Multiple audio packages: `flutter_sound`, `record`, `speech_to_text`, `flutter_tts`
- GPS/location: `geolocator`, `google_maps_flutter`
- OCR: `google_mlkit_text_recognition` (listed but unclear where used)

**Impact:**
- Larger app size
- More potential security vulnerabilities
- Maintenance burden from multiple package updates
- Conflicting patterns in state management (Provider vs Bloc)
- Unclear which package is actually used for each feature

**Fix approach:**
- Audit all dependencies; remove unused ones
- Standardize on single state management solution (Flutter Bloc already chosen, remove Provider)
- Document purpose of each multi-package feature (audio, location)
- Create clear dependency ownership (who maintains usage of each package)

## Data Layer Issues

### Mock Data Still in Production Code

**Issue:** Entire mock datasources exist in production code and are used as primary data source.

**Files:**
- `frontend/lib/features/agencia/shared/data/datasources/mock_agencia_datasource.dart`
- `frontend/lib/features/agencia/trips/data/datasources/mock_categorias_datasource.dart`
- `frontend/lib/features/guia/home/data/datasources/guia_home_mock_datasource.dart`
- `frontend/lib/features/guia/trips/data/datasources/caja_negra_local_datasource.dart`

**Impact:**
- App doesn't test against real backend
- Users see test data that doesn't match business reality
- Difficult to validate real API contracts
- Production build contains test code (potential security risk)

**Fix approach:**
- Once backend is implemented, migrate to real datasources
- Keep mock datasources only in test/ directory for testing
- Create factory pattern to switch between real and mock implementations based on environment
- Add validation that production builds use real datasources only

## Performance Bottlenecks

### Large Mock Datasource Initialization

**Issue:** MockAgenciaDataSource with 1885 lines creates 100+ test objects in memory on every app start.

**Files:**
- `frontend/lib/features/agencia/shared/data/datasources/mock_agencia_datasource.dart`

**Impact:**
- Slows down app startup
- Allocates unnecessary memory for data that's recreated every session
- Makes hot reload slower during development

**Fix approach:**
- Move to lazy singleton pattern (initialized on first use only)
- Migrate to json fixture files loaded as needed
- Replace with stub backend when real backend implemented

### No Caching or State Reuse

**Issue:** Each screen rebuild potentially triggers new data fetches.

**Files:**
- Multiple presentation screens that don't cache data
- No global state for shared entities (users, trips)

**Impact:**
- Excessive API calls (once backend is implemented)
- Poor user experience with loading states
- Higher resource usage

**Fix approach:**
- Implement proper caching strategy (cache repository pattern)
- Use global state for shared domain entities
- Add time-based cache invalidation

## Code Quality Issues

### Inconsistent Error Type Usage

**Issue:** Mix of Failures (from dartz), exceptions, and silent fails.

**Files:**
- Various datasources and repositories

**Impact:**
- Inconsistent error handling across features
- Unclear what errors each function can throw
- Harder to write comprehensive error handling

**Fix approach:**
- Standardize on Either<Failure, T> from dartz throughout
- Define AppFailure hierarchy for all error scenarios
- Document failure types in each repository contract

### Navigation Pattern Inconsistency

**Issue:** Multiple router files with duplicated route definitions.

**Files:**
- `frontend/lib/core/navigation/routes_agencia.dart`
- `frontend/lib/core/navigation/routes_turista.dart`
- `frontend/lib/core/navigation/routes_guia.dart`
- `frontend/lib/core/navigation/app_router_agencia.dart`
- Plus: `enrutador_app_guia.dart`, `enrutador_app_turista.dart`

**Impact:**
- Duplicated routing logic
- Hard to keep routes synchronized
- Unclear which router is authoritative
- Risk of inconsistent navigation across apps

**Fix approach:**
- Create single unified routing configuration shared across apps
- Use route constants defined centrally
- Generate router configs per app using shared base routes

## Scaling Limits

### Three Separate Apps, Shared Code

**Issue:** While frontend, turista, guia, and agencia use shared Domain/Data layers, there's still duplication in presentation.

**Files:**
- `frontend/lib/features/turista/`
- `frontend/lib/features/guia/`
- `frontend/lib/features/agencia/`

**Impact:**
- Presentation layer for each app can't share widgets (duplicate code)
- Changes to shared features require updates in 3 places
- Testing same business logic 3 times
- Increases app bundle size

**Fix approach:**
- Extract shared UI components into `frontend/lib/core/widgets/`
- Create feature-specific presentation packages but reuse components
- Document what's shared vs app-specific

### No Backend Capacity Planning

**Issue:** Backend architecture documents theoretical design but no implementation.

**Files:**
- `docs/05-ARQUITECTURA_BACKEND.md`

**Missing:**
- Database schema
- Query performance consideration for PostGIS
- Connection pooling strategy
- Caching layer architecture
- Load testing results
- Scaling strategy for concurrent trips

**Impact:**
- Cannot validate backend will handle production load
- No performance baselines
- Risk of degradation under load
- No documented scaling limits

**Fix approach:**
- Once backend implemented, run load testing
- Document performance profiles (queries/sec, response times)
- Implement caching layer (Redis) for frequently accessed data
- Add database connection pooling
- Document scaling approach (horizontal, caching, query optimization)

---

*Concerns audit: 2026-08-22*
