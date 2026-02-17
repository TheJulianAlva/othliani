# Plan de Implementación - Iteración 7: Funcionalidades Restantes (Itinerario y Divisas)

Esta iteración tiene como objetivo migrar las últimas pantallas funcionales (`ItineraryScreen`, `CurrencyConverterScreen`) a Clean Architecture y pulir la navegación principal.

## Objetivos
1.  Migrar el Itinerario a una arquitectura reactiva con Bloc.
2.  Migrar el Conversor de Divisas a lógica de negocio separada (Cubit/Repository).
3.  Corregir la navegación en `MainShellScreen`.

## Cambios Propuestos

### 1. Feature: Home/Itinerary (`features/turista/home`)
*   **Domain**:
    *   **[NEW] Entity**: `ItineraryItem` (time, title, description).
    *   **[NEW] Repository**: `ItineraryRepository` (getItinerary).
    *   **[NEW] UseCase**: `GetItineraryUseCase`.
*   **Data**:
    *   **[NEW] DataSource**: `ItineraryRemoteDataSource` (Mock por ahora).
    *   **[NEW] RepositoryImpl**: `ItineraryRepositoryImpl`.
*   **Presentation**:
    *   **[NEW] Bloc**: `ItineraryBloc` (LoadItinerary event).
    *   **[MIGRATE] Screen**: `PantallaItinerario` para usar `BlocBuilder`.

### 2. Feature: Tools/Currency (`features/turista/tools` o `currency`)
*   **Domain**:
    *   **[NEW] Repository**: `CurrencyRepository` (getExchangeRates, convert).
    *   **[NEW] UseCase**: `GetExchangeRatesUseCase`, `ConvertCurrencyUseCase`.
*   **Data**:
    *   **[NEW] DataSource**: `CurrencyRemoteDataSource` (Mock con tasas fijas).
    *   **[NEW] RepositoryImpl**: `CurrencyRepositoryImpl`.
*   **Presentation**:
    *   **[NEW] Cubit**: `CurrencyCubit` (métodos: `loadRates`, `convert`).
    *   **[MIGRATE] Screen**: `PantallaConversorDivisas` para eliminar lógica de cálculo y OCR directa (mover OCR a DataSource si es posible, o mantener como utilitario llamado por el Cubit/Screen). *Nota: Mantendremos OCR en UI/Utils por ser dependiente de plugins de UI, pero el cálculo será en el Cubit.*

### 3. Core & Navigation
*   **[MODIFY] `MainShellScreen`**:
    *   Actualizar navegación al Perfil usando `context.push(RoutesTurista.profile)`.
    *   Asegurar que todas las pestañas mantengan su estado (ya lo hace `IndexedStack`).
*   **[MODIFY] `service_locator.dart`**: Registrar nuevos Blocs y Repositorios.

## Plan de Verificación

### Pruebas Manuales
1.  **Itinerario**:
    *   Abrir pestaña Itinerario.
    *   Verificar que cargue la lista de eventos (mock).
2.  **Conversor de Divisas**:
    *   Seleccionar monedas (USD -> MXN).
    *   Ingresar monto. Verificar cálculo correcto.
    *   Probar botón de invertir monedas.
    *   (Opcional) Probar OCR si el emulador lo permite (cámara/galería).
3.  **Navegación**:
    *   Desde cualquier pestaña, ir al Perfil (icono de usuario).
    *   Verificar animación y transición correcta.
    *   Regresar y verificar que se mantiene la pestaña activa.
