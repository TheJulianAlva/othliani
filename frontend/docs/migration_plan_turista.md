# Plan de Migración: `presentation_turista` a Clean Architecture

Este documento detalla el mapeo y los pasos para organizar los archivos existentes en `lib/presentation_turista` hacia la nueva estructura basada en features (`lib/features/turista`).

## Objetivo
Mover y refactorizar las pantallas monolíticas (legacy) a módulos de features independientes, estandarizando los nombres a inglés y separando la lógica de negocio (BLoC/Cubit) de la UI.

## Estrategia de Migración
Para cada Feature:
1.  **Crear directorios**: `domain`, `data`, `presentation` dentro de `features/turista/<feature_name>`.
2.  **Mover/Renombrar**: Copiar el archivo de pantalla original a su nueva ubicación `presentation/screens/` con nombre en inglés.
3.  **Refactorizar**:
    - Extraer lógica a Cubit/Bloc.
    - Actualizar imports (rutas, widgets, temas).
    - Reemplazar uso directo de `setState` por `BlocBuilder` cuando aplique gestión de estado compleja.
4.  **Actualizar Router**: Modificar `EnrutadorAppTurista` para apuntar al nuevo archivo.
5.  **Eliminar Legacy**: Borrar el archivo original en `presentation_turista` una vez verificado.

## Mapeo de Archivos

### 1. Feature: Auth (`features/turista/auth`)
*Estado: En Progreso (Login ya migrado)*

| Archivo Legacy (Español/Mix) | Nueva Ubicación (Inglés) | Estado |
| :--- | :--- | :--- |
| `pantalla_inicio_sesion.dart` | `presentation/screens/login_screen.dart` | ✅ Completo |
| `pantalla_registro.dart` | `presentation/screens/register_screen.dart` | Pendiente |
| `pantalla_olvido_contrasena.dart` | `presentation/screens/forgot_password_screen.dart` | Pendiente |
| `pantalla_verificacion_email.dart` | `presentation/screens/email_verification_screen.dart` | Pendiente |
| `pantalla_telefono.dart` | `presentation/screens/phone_verification_screen.dart` | Pendiente |
| `pantalla_verificacion_sms.dart` | `presentation/screens/sms_verification_screen.dart` | Pendiente |

### 2. Feature: Onboarding (`features/turista/onboarding`)

| Archivo Legacy | Nueva Ubicación |
| :--- | :--- |
| `pantalla_introduccion.dart` | `presentation/screens/onboarding_screen.dart` |

### 3. Feature: Home (`features/turista/home`)

| Archivo Legacy | Nueva Ubicación |
| :--- | :--- |
| `pantalla_inicio.dart` | `presentation/screens/home_screen.dart` |
| `pantalla_folio.dart` | `presentation/screens/folio_screen.dart` |

### 4. Feature: Itinerary (`features/turista/itinerary`)

| Archivo Legacy | Nueva Ubicación |
| :--- | :--- |
| `pantalla_itinerario.dart` | `presentation/screens/itinerary_screen.dart` |
| `pantalla_detalle_actividad.dart` | `presentation/screens/activity_detail_screen.dart` |
| `pantalla_inicio_viaje.dart` | `presentation/screens/trip_start_screen.dart` |

### 5. Feature: Map (`features/turista/map`)

| Archivo Legacy | Nueva Ubicación |
| :--- | :--- |
| `pantalla_mapa.dart` | `presentation/screens/map_screen.dart` |

### 6. Feature: Profile (`features/turista/profile`)

| Archivo Legacy | Nueva Ubicación |
| :--- | :--- |
| `pantalla_perfil.dart` | `presentation/screens/profile_screen.dart` |

### 7. Feature: Settings (`features/turista/settings`)

| Archivo Legacy | Nueva Ubicación |
| :--- | :--- |
| `pantalla_configuracion.dart` | `presentation/screens/settings_screen.dart` |
| `pantalla_accesibilidad.dart` | `presentation/screens/accessibility_screen.dart` |

### 8. Feature: Chat (`features/turista/chat`)
| Archivo Legacy | Nueva Ubicación |
| :--- | :--- |
| `pantalla_chat.dart` | `presentation/screens/chat_screen.dart` |

### 9. Feature: Tools (`features/turista/tools`)
| Archivo Legacy | Nueva Ubicación |
| :--- | :--- |
| `pantalla_conversor_divisas.dart` | `presentation/screens/currency_converter_screen.dart` |

---
**Nota**: Algunos archivos en `presentation_turista/screens` parecen estar duplicados en inglés (e.g., `login_screen.dart`, `register_screen.dart`). Se debe priorizar la versión más actualizada o completa (usualmente la que se estaba usando en el Router).
