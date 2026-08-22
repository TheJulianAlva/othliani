# 📡 Documentación de Conectividad y Estado de Red (Sync Strategy)

**Fecha de actualización:** 10 de Febrero de 2026  
**Módulo:** `SyncBloc` / `AgencyHeader`  
**Paquete utilizado:** `connectivity_plus`

---

## 1. Estado Actual (Demo / MVP)

Actualmente, la aplicación implementa una detección de estado de conexión basada en la **Interfaz de Red del Dispositivo**.

### 🛠️ Comportamiento Implementado

El sistema escucha activamente los cambios en el hardware de red del dispositivo (WiFi, Datos Móviles, Ethernet) utilizando el paquete `connectivity_plus`.

* **🟢 ONLINE:** Se activa cuando el dispositivo tiene una conexión establecida a una red (ej. WiFi conectado, Datos Móviles activos).
* **🔴 OFFLINE:** Se activa cuando no hay ninguna interfaz de red disponible (ej. Modo Avión, WiFi apagado).

### ⚠️ Limitación Técnica (Alcance Actual)

La implementación actual verifica la **conexión a la red local**, no la **salida a Internet**.

> **Ejemplo:** Si el dispositivo está conectado a un Router WiFi, pero ese Router no tiene servicio de internet (cable desconectado), la aplicación marcará el estado como **ONLINE** (porque la interfaz WiFi está activa), aunque no pueda comunicarse con la API de Veltur.

---

## 2. Implementación Futura (Roadmap a Producción)

Para garantizar la sincronización de datos crítica en entornos reales (Agencias y Guías en campo), se debe evolucionar la estrategia de conectividad para incluir una verificación de **"Internet Reachability"**.

### 🚀 Mejora Requerida: "Ping Check" o "Health Check"

En la siguiente fase de desarrollo, el `SyncBloc` deberá implementar una doble verificación:

1. **Nivel 1 (Hardware):** Verificar si hay red (lo que ya hace `connectivity_plus`).
2. **Nivel 2 (Servicio):** Si hay red, realizar una petición ligera (Ping/Head Request) a un servidor confiable o al propio Backend de Veltur.

### 📝 Propuesta de Implementación Técnica

Se recomienda utilizar el paquete `internet_connection_checker` o implementar una función personalizada de `Socket` en Dart:

```dart
// Pseudo-código para futura implementación
bool hasInternet = await InternetConnectionChecker().hasConnection;

if (hasNetworkInterface && hasInternet) {
  emit(SyncStatus.online); // Realmente tenemos internet
} else if (hasNetworkInterface && !hasInternet) {
  emit(SyncStatus.limited); // Conectado al WiFi pero sin salida
} else {
  emit(SyncStatus.offline); // Sin red
}
