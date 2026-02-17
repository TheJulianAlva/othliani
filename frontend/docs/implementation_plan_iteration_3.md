# Plan de Implementación - Iteración 3: Gestión de Sesión y Datos Locales

Esta iteración se enfoca en persistir la sesión del usuario para que no tenga que loguearse cada vez que abre la app, y en controlar el flujo de entrada (Onboarding -> Login/Folio -> Home).

## Objetivos
1.  Implementar `AuthLocalDataSource` usando `shared_preferences`.
2.  Actualizar `AuthRepository` para manejar `checkAuthStatus` y `logout`.
3.  Crear un `AuthBloc` global para manejar el estado de autenticación de toda la app.
4.  Migrar `OnboardingScreen` a Clean Architecture.
5.  Actualizar `GoRouter` para redirigir basado en el estado del `AuthBloc`.

## Cambios Propuestos

### 1. Data Layer (`features/turista/auth/data`)
*   **Nueva Dependencia**: Agregar `shared_preferences` (ya está en pubspec, verificar).
*   **[NEW] `AuthLocalDataSource`**: Interfaz e implementación.
    *   Métodos: `cacheToken(String token)`, `getToken()`, `clearToken()`, `cacheOnboardingStatus()`, `getOnboardingStatus()`.
*   **[MODIFY] `AuthRepositoryImpl`**:
    *   Inyectar `AuthLocalDataSource`.
    *   En `login` y `register`, guardar el token/usuario en local.
    *   Implementar `logout` (borrar token).
    *   Implementar `checkAuthStatus` (leer token).

### 2. Domain Layer (`features/turista/auth/domain`)
*   **[MODIFY] `AuthRepository`**: Agregar métodos `logout()` y `checkAuthStatus()`.
*   **[NEW] `CheckAuthStatusUseCase`**: Para verificar sesión al inicio.
*   **[NEW] `LogoutUseCase`**: Para cerrar sesión.

### 3. Presentation Layer (`features/turista/auth/presentation`)
*   **[NEW] `AuthBloc`**:
    *   Eventos: `AppStarted`, `LoggedIn`, `LoggedOut`.
    *   Estados: `AuthUninitialized`, `Authenticated`, `Unauthenticated`.
*   **[NEW] `features/turista/onboarding/presentation/cubit/onboarding_cubit.dart`**: Manejar lógica de onboarding completado.
*   **[NEW] `features/turista/onboarding/presentation/screens/onboarding_screen.dart`**: Migración de la pantalla actual.

### 4. Core & App Initialization
*   **[MODIFY] `service_locator.dart`**: Registrar nuevas dependencias.
*   **[MODIFY] `main_turista.dart`**: Inicializar `AuthBloc`.
*   **[MODIFY] `enrutador_app_turista.dart`**:
    *   Escuchar cambios en `AuthBloc`.
    *   Implementar lógica de redirección (`redirect` en GoRouter).

## Plan de Verificación

### Pruebas Manuales
1.  **Fresh Install**:
    *   Abrir app -> Debe mostrar `OnboardingScreen`.
    *   Completar Onboarding -> Debe ir a `LoginScreen` (o Folio/Opciones).
2.  **Login**:
    *   Ingresar credenciales -> Debe ir a `HomeScreen`.
    *   Cerrar app y volver a abrir -> Debe ir directo a `HomeScreen` (Persistencia).
3.  **Logout**:
    *   Desde Perfil (si existe botón) o simulado -> Debe volver a `LoginScreen`.
    *   Cerrar app y volver a abrir -> Debe pedir Login.
