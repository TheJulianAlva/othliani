# Plan de Implementación - Iteración 4: Módulos Principales (Home/Itinerary)

Esta iteración se enfoca en migrar la pantalla principal del viajero (`TripHomeScreen`) a Clean Architecture. Actualmente, utiliza datos `hardcoded` en el widget `StatefulWidget`.

## Objetivos
1.  Modelar las entidades `Trip` y `Activity` en la capa de Dominio.
2.  Crear un `TripRepository` para obtener los datos del viaje actual.
3.  Implementar `TripBloc` para manejar la lógica de negocio (filtrado, cálculo de progreso, actualización de estado).
4.  Refactorizar `TripHomeScreen` modificando `pantalla_inicio_viaje.dart` (o creando uno nuevo en features) para consumir el Bloc.

## Cambios Propuestos

### 1. Domain Layer (`features/turista/home/domain`)
*   **[NEW] `Activity` Entity**:
    *   Properties: `id`, `title`, `description`, `time`, `status` (enum: pending, in_progress, finished), `day`.
*   **[NEW] `Trip` Entity**:
    *   Properties: `id`, `title`, `description`, `activities` (List<Activity>).
    *   Methods: `activitiesByDay`, `progress(day)`, `counts(day)`.
*   **[NEW] `TripRepository` Interface**:
    *   `Future<Either<Failure, Trip>> getCurrentTrip();`
    *   `Future<Either<Failure, void>> updateActivityStatus(String activityId, ActivityStatus status);`
*   **[NEW] `GetCurrentTripUseCase`**.

### 2. Data Layer (`features/turista/home/data`)
*   **[NEW] `ActivityModel` & `TripModel`**: `fromJson` / `toJson`.
*   **[NEW] `TripRemoteDataSource`**:
    *   `TripMockDataSource`: Retornará el JSON equivalente a los datos actuales de `pantalla_inicio_viaje.dart`.
*   **[NEW] `TripRepositoryImpl`**: Implementation.

### 3. Presentation Layer (`features/turista/home/presentation`)
*   **[NEW] `TripBloc`**:
    *   Events: `TripBasicLoad`, `TripFilterChanged`, `TripDayChanged`.
    *   States: `TripLoading`, `TripLoaded` (holds `Trip` entity, `selectedDay`, `selectedFilter`), `TripError`.
*   **[MIGRATE] `TripHomeScreen`**:
    *   Location: `features/turista/home/presentation/screens/trip_home_screen.dart`.
    *   Logic: Remove `_activitiesByDay` variable. Use `BlocBuilder<TripBloc, TripState>`.

### 4. Core
*   **[MODIFY] `service_locator.dart`**: Register Home dependencies.
*   **[MODIFY] `enrutador_app_turista.dart`**: Point `RoutesTurista.folio` (or Home) to the new screen if applicable, or just generic `RoutesTurista.home`. note: `TripHomeScreen` is the first tab of `MainShellScreen`.

## Plan de Verificación

### Pruebas Manuales
1.  **Carga de Datos**: Abrir la app -> Login -> Ver que la lista de actividades aparezca (igual que antes).
2.  **Filtrado**: Probar los chips "Todas", "Terminada", etc. La lista debe cambiar.
3.  **Cambio de Día**: Cambiar pestañas (Día 1, Día 2). La lista y el progreso deben cambiar.
4.  **UI Feedback**: Verificar que el gráfico de progreso y los contadores (Badges) coincidan con los datos.
