# 03. Arquitectura del Frontend (Flutter)

Este es el documento más importante para el equipo de frontend. Define *cómo* estructuramos nuestro código para que sea mantenible, escalable y testeable.

## El Patrón: Arquitectura Limpia (Clean Architecture)

Usamos un patrón estándar de la industria: **Arquitectura Limpia**.

<p align="center">
  <img src="https://substackcdn.com/image/fetch/$s_!0bn3!,f_auto,q_auto:good,fl_progressive:steep/https%3A%2F%2Fsubstack-post-media.s3.amazonaws.com%2Fpublic%2Fimages%2F163415ba-cbed-4f04-8539-3bc1c3a6fef3_1938x1246.png" alt="Diagrama Clean Architecture Flow" width="640">
</p>

El objetivo es la **Separación de Responsabilidades (Separation of Concerns)**. Dividimos la aplicación en capas, y cada capa tiene una sola responsabilidad.

### 1. Capa de Dominio (Domain)

* **Responsabilidad:** El *corazón* de la aplicación. Contiene la lógica y reglas de negocio puras (Ej. "Qué es un `Participante`", "Qué es una `Alerta`").
* **Regla Clave:** Esta capa es Dart puro. **No debe importar NADA de Flutter** (`dart:ui`) ni de paquetes de terceros (como `http` o `dio`).
* **Contiene:**
    * `entities/`: Clases puras que definen nuestros objetos de negocio (`Participante`, `Viaje`, etc.).
    * `usecases/`: Clases que definen una acción de negocio (Ej. `LoginConFolioUseCase`).
    * `repositories/`: Interfaces (contratos abstractos) que definen *qué* datos necesita el dominio (Ej. `AuthRepository`), pero no *cómo* obtenerlos.

### 2. Capa de Datos (Data)

* **Responsabilidad:** Obtener y almacenar datos. Es la *implementación* de los contratos del Dominio.
* **Regla Clave:** Habla con el mundo exterior (la API de Node.js, la base de datos local del teléfono).
* **Contiene:**
    * `datasources/`: Clases que hacen las llamadas HTTP (usando `dio`).
    * `models/`: Clases que saben cómo convertirse de/hacia JSON (con `fromJson` / `toJson`).
    * `repositories/`: La implementación *real* de las interfaces del Dominio (Ej. `AuthRepositoryImpl`).

### 3. Capa de Presentación (Presentation)

* **Responsabilidad:** Mostrar la UI al usuario y capturar sus interacciones.
* **Regla Clave:** Es la única capa que puede importar Flutter y widgets. Su trabajo es llamar a los `usecases` del Dominio y reaccionar a los resultados.
* **Contiene:**
    * `screens/` o `pages/`: Los widgets que representan una pantalla completa.
    * `widgets/`: Widgets reutilizables (botones, campos de texto, etc.).
    * `blocs/`: (O `cubits`/`providers`) La lógica de gestión de estado (usando `flutter_bloc`).

---
> [!TIP]  
> **Ejemplo de Proyecto aplicando *Clean Architecture* y algunas dependencias:**  
><p align="left">
>  <a href="https://youtu.be/AKoRKAISNLE">
>    <img src="https://img.youtube.com/vi/AKoRKAISNLE/maxresdefault.jpg" alt="Clean architecture en Flutter" width="640">
>  </a>
></p>

> [!TIP]  
> **Otro ejemplo de Proyecto aplicando *Clean Architecture* y BloC:**  
><p align="left">
>  <a href="https://youtu.be/brDKUf1yV6c">
>    <img src="https://img.youtube.com/vi/brDKUf1yV6c/maxresdefault.jpg" alt="Clean architecture en Flutter" width="640">
>  </a>
></p>

---

## Nuestra Estructura Multi-Aplicación

Dado que estamos construyendo **TRES** aplicaciones (Turista, Guía, Agencia) desde **UNA** base de código, nuestra estructura `lib/` está diseñada para una máxima reutilización del código.

Compartimos toda la lógica de `Data` y `Domain` y solo separamos la `Presentación` (UI).

```
/frontend/lib/
│
├── core/               <-- 100% COMPARTIDO (Temas, Navegación, Widgets comunes)
│   ├── theme/
│   ├── navigation/
│   └── widgets/        (Ej. LogoOhtliAni, BotonPrimario)
│
├── data/               <-- 100% COMPARTIDO (Toda la lógica de API y Modelos)
│   ├── datasources/
│   ├── models/
│   └── repositories/
│
├── domain/             <-- 100% COMPARTIDO (Toda la lógica de negocio)
│   ├── entities/
│   ├── repositories/
│   └── usecases/
│
│
├── presentation_turista/     <-- CAPA DE UI #1
│   ├── screens/
│   ├── blocs/
│   └── widgets/
│
├── presentation_guia/        <-- CAPA DE UI #2
│   ├── screens/
│   ├── blocs/
│   └── widgets/
│
├── presentation_agencia/     <-- CAPA DE UI #3
│   ├── screens/
│   ├── blocs/
│   └── widgets/
│
│
├── main_turista.dart     <-- PUNTO DE ENTRADA #1 (Llama a la UI de Turista)
├── main_guia.dart        <-- PUNTO DE ENTRADA #2 (Llama a la UI de Guía)
└── main_agencia.dart     <-- PUNTO DE ENTRADA #3 (Llama a la UI de Agencia)
```
