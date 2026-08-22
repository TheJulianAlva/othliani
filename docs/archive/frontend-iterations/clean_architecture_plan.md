# Implementación de Clean Architecture - App Turista

Este documento detalla la estructura y los pasos necesarios para migrar la aplicación actual de Turista a una arquitectura limpia (Clean Architecture), separando las responsabilidades en capas de Data, Domain y Presentation.

## 1. Análisis del Estado Actual

Actualmente, la aplicación se encuentra en una etapa de prototipo funcional enfocada en la UI (`presentation_turista`).
- **Presentation**: Existen pantallas y widgets (`lib/presentation_turista/screens`).
- **Data/Logic**: La lógica de negocio y los datos están simulados mediante archivos estáticos (e.g., `MockAuthData`) o incrustados directamente en la UI.
- **Networking**: No existe configuración de cliente HTTP (Dio/Http) ni llamadas a servicios remotos.
- **Domain**: No existen entidades de negocio ni definición de casos de uso.

## 2. Arquitectura Propuesta

Se adoptará una estructura de 3 capas concéntricas, donde la dependencia fluye hacia adentro (hacia el Dominio).

### Capa de Dominio (Domain Layer)
*El núcleo de la aplicación. No tiene dependencias externas (ni de Flutter, ni de librerías de terceros complejas).*
- **Entities**: Objetos puros de negocio (e.g., `User`, `Itinerary`, `Activity`).
- **Repositories (Interfaces)**: Contratos que definen qué operaciones se pueden realizar, sin implementar el cómo (e.g., `AuthRepository`).
- **Use Cases**: Encapsulan reglas de negocio específicas y orquestan el flujo de datos (e.g., `LoginUseCase`, `GetItineraryUseCase`).

### Capa de Datos (Data Layer)
*Responsable de recuperar y persistir datos. Conoce los detalles de implementación.*
- **Models**: DTOs (Data Transfer Objects) que extienden las Entities y manejan la serialización JSON.
- **Data Sources**:
    - **Remote**: Define la interfaz para obtener datos externos.
        - *Fase 1*: **Mock** (Retorna datos estáticos simulados con retardo).
        - *Fase 2*: **API** (Implementación real con Dio/Http).
    - **Local**: Persistencia local (SharedPreferences, Hive, SQLite).

- **Repositories (Implementations)**: Implementan las interfaces del dominio, coordinando las fuentes de datos y manejando excepciones.

### Capa de Presentación (Presentation Layer)
*Responsable de mostrar la UI y manejar la interacción del usuario.*
- **State Management**: Se utilizará **flutter_bloc** (ya instalado) para separar la lógica de negocio de la UI.
- **Routing**: Se utilizará **go_router** (ya instalado) para la navegación.
- **Screens/Widgets**: Consumen los Cubits/Blocs.


## 3. Plan de Implementación (Iteraciones)

Para realizar esta implementación con Gemini de manera eficiente, se sugiere dividir el trabajo en las siguientes iteraciones.

### Iteración 1: Fundamentos y Configuración Core
**Objetivo**: Configurar las herramientas ya instaladas para sustentar la arquitectura.
1.  **Dependency Injection**: Configurar **GetIt** (`service_locator.dart`) para la inyección de dependencias.
2.  **Network Client**: Configurar **Dio** (ya instalado) creando una clase wrapper (`DioClient`) con interceptores y manejo de Timeouts.
3.  **Error Handling**: Crear clase `Failure` y definir el uso de **Either** (de `dartz`) en los repositorios.
4.  **Use Case Base**: Definir clase abstracta `UseCase<Type, Params>`.


### Iteración 2: Vertical Slice - Autenticación (Login)
**Objetivo**: Implementar el flujo completo de una funcionalidad crítica para validar la arquitectura.
1.  **Domain**:
    - Crear entity `User`.
    - Crear interface `AuthRepository` (método `login`).
    - Crear use case `LoginUseCase`.
2.  **Data**:
    - Crear model `UserModel` (fromJson/toJson).
    - Crear interface `AuthRemoteDataSource`.
    - Implementar `AuthMockDataSource` (simulando respuestas).
    - Implementar `AuthRepositoryImpl` (que inyecta el DataSource).

3.  **Presentation**:
    - Refactorizar `LoginScreen` para escuchar el estado.
    - Crear `LoginCubit` (usando `flutter_bloc`) que consuma `LoginUseCase`.
    - Inyectar el Cubit usando `GoRouter` o `BlocProvider` en la vista.


### Iteración 3: Gestión de Sesión y Datos Locales
**Objetivo**: Persistir la sesión del usuario.
1.  **Local Data Source**: Implementar almacenamiento seguro (e.g., `FlutterSecureStorage`) para guardar tokens.
2.  **Domain/Data**: Métodos para recuperar usuario y verificar sesión al inicio.

### Iteración 4: Módulos Principales (Itinerario/Home)
**Objetivo**: Escalar la arquitectura a las funcionalidades principales del turista.
1.  Repetir patrón (Domain -> Data -> Presentation) para el manejo de Itinerarios o Actividades.
2.  Implementar `RemoteDataSource` para obtener listas de lugares.
3.  Mapear respuestas JSON a Entities complejas.

### Estructura de Carpetas Sugerida (dentro de `lib`)

Para mantener la separación clara entre roles (Turista vs Guía vs Agencia), agruparemos todo lo relacionado con el Turista bajo su propio directorio o prefijo en `features`.

```
lib/
├── core/                       # Utilidades compartidas (Network, Errors, Theme)
├── features/
│   ├── turista/                # <--- AQUI vive la Clean Architecture de Turista
│   │   ├── auth/
│   │   │   ├── data/           # Repositorios, Modelos, DataSources
│   │   │   ├── domain/         # Entidades, Casos de Uso
│   │   │   └── presentation/   # BLoCs, Screens (Refactorizado de presentation_turista)
│   │   ├── home/
│   │   └── ...
│   │
│   ├── guia/                   # Futura migración (o mantener presentation_guia actual)
│   └── agencia/                # Futura migración (o mantener presentation_agencia actual)
│
├── presentation_guia/          # (Estructura legada - se mantiene igual por ahora)
└── presentation_agencia/       # (Estructura legada - se mantiene igual por ahora)
```

**Nota**: Poco a poco moveremos lo que hay en `presentation_turista` hacia `features/turista/.../presentation`.

