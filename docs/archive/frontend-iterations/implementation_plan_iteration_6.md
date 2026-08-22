# Plan de Implementación - Iteración 6: Auth Verification Cleanup

Esta iteración se enfoca en migrar las pantallas de verificación restantes (`FolioScreen`, `PhoneScreen`, `SmsVerificationScreen`, `EmailVerificationScreen`) a Clean Architecture. Estas pantallas manejan flujos de validación previos o durante el registro.

## Objetivos
1.  Migrar la lógica de validación de Folio, Teléfono y Códigos a la capa de Dominio/Presentación.
2.  Implementar `VerificationCubit` para manejar el estado de estos flujos.
3.  Actualizar las pantallas para consumir el Cubit y eliminar lógica de negocio de la UI.

## Cambios Propuestos

### 1. Feature: Auth (`features/turista/auth`)

**Domain Layer**:
*   **[NEW] UseCases**:
    *   `VerifyFolioUseCase`: Valida si el folio existe/es válido.
    *   `RequestPhoneCodeUseCase`: Solicita envío de código SMS.
    *   `VerifyPhoneCodeUseCase`: Valida el código SMS ingresado.
    *   `ResendEmailVerificationUseCase`: Reenvía correo de verificación.
*   **[MODIFY] `AuthRepository` Interface**: Agregar métodos para estas acciones.

**Data Layer**:
*   **[MODIFY] `AuthRemoteDataSource`**: Agregar métodos simulados (Mock) para validar folio, enviar SMS, validar SMS.
*   **[MODIFY] `AuthRepositoryImpl`**: Implementar los nuevos métodos.

**Presentation Layer**:
*   **[NEW] `VerificationCubit`**:
    *   State: `VerificationInitial`, `VerificationLoading`, `FolioVerified`, `PhoneCodeSent`, `PhoneVerified`, `EmailSent`, `VerificationError`.
    *   Methods: `verifyFolio(String)`, `requestPhoneCode(String)`, `verifyPhoneCode(String)`, `resendEmail()`.
*   **[MIGRATE] `FolioScreen`**: Usar `VerificationCubit` para validar folio antes de navegar.
*   **[MIGRATE] `PhoneScreen`**: Usar `VerificationCubit` para enviar código.
*   **[MIGRATE] `SmsVerificationScreen`**: Usar `VerificationCubit` para validar código.
*   **[MIGRATE] `EmailVerificationScreen`**: Usar `VerificationCubit` (o reutilizar lógica existente si es simple).

### 2. Core & DI
*   **[MODIFY] `service_locator.dart`**: Registrar el nuevo `VerificationCubit` y UseCases.

## Plan de Verificación

### Pruebas Manuales
1.  **Flujo Folio**:
    *   Ingresar Folio válido (simulado). Verificar navegación a Teléfono.
    *   Ingresar Folio inválido. Verificar mensaje de error.
2.  **Flujo Teléfono/SMS**:
    *   Ingresar teléfono. Verificar transición a pantalla SMS.
    *   Ingresar código "123456" (o mock definido). Verificar navegación a Registro.
3.  **Recuperación Contraseña / Email**:
    *   Verificar botón "Reenviar correo" en pantalla de verificación de email.
