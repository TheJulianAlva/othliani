# Plan de Implementación - Iteración 5: Perfil y Configuraciones

Esta iteración se enfoca en migrar las pantallas de Perfil, Configuración y Accesibilidad a Clean Architecture, eliminando la dependencia directa de `SharedPreferences` en la UI y reemplazando los `ChangeNotifier` por `Cubits`.

## Objetivos
1.  Implementar la gestión de Perfil de Usuario con Clean Architecture.
2.  Migrar la gestión de Configuración (Tema, Idioma, Accesibilidad) a Cubits.
3.  Actualizar las pantallas `ProfileScreen`, `ConfigScreen` y `AccessibilityScreen`.

## Cambios Propuestos

### 1. Feature: Profile (`features/turista/profile`)
**Domain Layer**:
*   **[NEW] `UserProfile` Entity**: `name`, `email`, `avatarUrl` (optional).
*   **[NEW] `ProfileRepository` Interface**:
    *   `Future<Either<Failure, UserProfile>> getProfile();`
    *   `Future<Either<Failure, UserProfile>> updateProfile(UserProfile profile);`
*   **[NEW] UseCases**: `GetProfileUseCase`, `UpdateProfileUseCase`.

**Data Layer**:
*   **[NEW] `UserProfileModel`**: `fromJson`/`toJson`.
*   **[NEW] `ProfileLocalDataSource`**: Wrapper sobre `SharedPreferences` para persistir datos del perfil.
*   **[NEW] `ProfileRepositoryImpl`**.

**Presentation Layer**:
*   **[NEW] `ProfileBloc`**: Maneja estados `Loading`, `Loaded` (con `UserProfile`), `Error`.
*   **[MIGRATE] `ProfileScreen`**: Usa `BlocBuilder<ProfileBloc, ProfileState>`.

### 2. Feature: Settings (`features/turista/settings`)
**Presentation Layer (Cubits)**:
*   **[NEW] `ThemeCubit`**: Reemplaza `ThemeProvider`. Persiste preferencia en `SharedPreferences`.
*   **[NEW] `LocaleCubit`**: Reemplaza `LocaleProvider`. Persiste preferencia.
*   **[NEW] `AccessibilityCubit`**: Reemplaza `AccessibilityProvider`. Estado: `AccessibilityState` (immutable class).

**Screens**:
*   **[MIGRATE] `ConfigScreen`** (Settings): Usa `BlocBuilder` para Theme/Locale.
*   **[MIGRATE] `AccessibilityScreen`**: Usa `BlocBuilder` para Accessibility options.

### 3. Feature: Chat (`features/turista/chat`)
**Domain Layer**:
*   **[NEW] `Message` Entity**: `id`, `text`, `senderId`, `timestamp`, `isMe`.
*   **[NEW] `ChatRepository` Interface**: `Stream<List<Message>> getMessages()`, `Future<void> sendMessage(String text)`.

**Data Layer**:
*   **[NEW] `ChatRemoteDataSource`**: Mock implementation returning a stream of messages.
*   **[NEW] `ChatRepositoryImpl`**.

**Presentation Layer**:
*   **[NEW] `ChatBloc`**: Events `ChatStarted`, `MessageSent`. State `ChatLoaded`.
*   **[MIGRATE] `ChatScreen`**.

### 4. Feature: Map (`features/turista/map`)
**Presentation Layer**:
*   **[NEW] `MapBloc`**: Manage Map state (loading, loaded with POIs).
*   **[MIGRATE] `MapScreen`**.

### 5. Core & DI
*   **[MODIFY] `service_locator.dart`**: Registrar nuevos Repositories, DataSources y Cubits/Blocs.
*   **[MODIFY] `main_turista.dart`**: Inyectar los nuevos Cubits globales (`ThemeCubit`, `LocaleCubit`, `AccessibilityCubit`) en el `MultiBlocProvider` raíz (reemplazando `MultiProvider` si es posible, o conviviendo).

## Plan de Verificación

### Pruebas Manuales
1.  **Perfil**:
    *   Verificar carga inicial de datos (Nombre/Email).
    *   Editar nombre en el diálogo y guardar. Verificar que se actualiza en pantalla y persiste tras reiniciar.
2.  **Configuración**:
    *   Cambiar Tema (Light/Dark). Verificar cambio inmediato y persistencia.
    *   Cambiar Idioma (ES/EN). Verificar cambio de traducciones.
3.  **Accesibilidad**:
    *   Cambiar tamaño de fuente, contraste, etc. Verificar que los valores se mantienen al navegar.
4.  **Chat**:
    *   Enviar mensaje y ver que aparece en la lista.
5.  **Mapa**:
    *   Verificar que el mapa cargue correctamente.

