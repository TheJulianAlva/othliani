# Plan de Implementación: Entorno Demo Veltur

**Objetivo:** Preparar un entorno de demostración en vivo para jueces no técnicos, usando dos dispositivos físicos, minimizando el riesgo de falla.

**Fecha de redacción:** Mayo 2026

---

## Contexto del Producto

**Veltur** es un ecosistema digital de seguridad, logística y comunicación para agencias de viajes. Tiene tres aplicaciones construidas en Flutter (Clean Architecture + BLoC):

- **App Turista** — móvil: itinerario, mapa de seguridad, botón de pánico, walkie-talkie, herramientas de viaje
- **App Guía** — móvil: gestión del grupo, mapa táctico, alertas, walkie-talkie broadcast
- **Portal Agencia** — web/desktop: dashboard de monitoreo (*no incluido en la demo*)

**Estado al inicio:** Frontend ~95% completo con datos simulados. Backend vacío. Walkie-talkie con UI y lógica Socket.IO pero sin servidor.

---

## Flujo de Demo (Tres Actos)

**Dispositivos:**
- 📱 **Dispositivo A** — App Turista (presentador principal, frente a los jueces)
- 📱 **Dispositivo B** — App Guía (integrante del equipo al fondo o fuera del salón)

**Premisa narrativa:**
> "Imaginen un grupo turístico en Tulum. La guía está con la mayoría. Ana, una turista, se alejó del grupo. Veamos qué pasa."

| Acto | Duración | Descripción |
|---|---|---|
| **Acto 1** | 3–4 min | Turista recorre itinerario, herramientas y mapa de seguridad |
| **Acto 2** | 2 min | Turista presiona botón de pánico → guía recibe alerta automática |
| **Acto 3** | 2–3 min | Guía activa walkie-talkie → audio real llega al teléfono de la turista |
| Intro + cierre | 2 min | Estadística del 72% + frase de cierre |
| **Total** | **~10–12 min** | |

---

## Arquitectura de la Solución

```
┌─────────────────────┐         INTERNET          ┌─────────────────────┐
│  Dispositivo A      │  ←──────────────────────→ │  Dispositivo B      │
│  App Turista        │              │             │  App Guía           │
│  (presentador)      │              │             │  (integrante lejano)│
└─────────────────────┘              ▼             └─────────────────────┘
    Cualquier red            ┌──────────────┐          Cualquier red
    WiFi / 4G                │  Railway.app │          WiFi / 4G
                             │  Node.js +   │
                             │  Socket.IO   │
                             │  (gratuito)  │
                             └──────────────┘
                          URL fija permanente
```

Ambos dispositivos usan su propia red. No hay dependencia de red compartida. Un servidor en la nube (Railway.app, plan gratuito) actúa de intermediario.

**Por qué Railway y no servidor local:** Si el servidor corre en la laptop por WiFi, el turista que "se aleja" en la demo perdería la conexión. Railway resuelve esto — ambos dispositivos se conectan a internet independientemente.

---

## Resumen de Cambios

### Archivos creados
| Archivo | Propósito |
|---|---|
| `frontend/lib/core/demo/demo_config.dart` | Flag `kDemoMode`, URL de Railway, constantes del viaje demo |
| `frontend/lib/core/demo/demo_socket_service.dart` | Singleton Socket.IO: conecta, emite pánico, expone stream de eventos |
| `frontend/lib/features/turista/home/presentation/screens/pantalla_emergencia_turista.dart` | Pantalla roja de emergencia post-pánico *(Fase 3)* |
| `frontend/lib/features/guia/home/presentation/widgets/demo_panic_trigger.dart` | Botón oculto de respaldo en la App Guía *(Fase 3)* |
| `backend/demo-server/server.js` | Mini servidor Node.js + Socket.IO |
| `backend/demo-server/package.json` | Dependencias del servidor |
| `docs/DEMO_VELTUR.md` | Guión, checklist y contingencias para el día del evento |

### Archivos modificados
| Archivo | Cambio |
|---|---|
| `frontend/lib/core/di/guia_locator.dart` | Usa `GuiaAuthMockDataSource` y `GuiaHomeMockDataSource` |
| `frontend/lib/main_guia.dart` | Pre-puebla sesión demo + conecta `DemoSocketService` |
| `frontend/lib/main_turista.dart` | Pre-puebla sesión demo + conecta `DemoSocketService` |
| `frontend/lib/core/navigation/enrutador_app_turista.dart` | Bypass completo del guard de auth en modo demo |
| `frontend/lib/features/turista/home/data/datasources/itinerary_remote_data_source.dart` | Actividades reales de Tulum (Zona Arqueológica, Playa Paraíso, etc.) |
| `frontend/lib/features/turista/home/presentation/widgets/walkie_talkie_button.dart` | URL del servidor desde `kDemoServerUrl` |
| `frontend/lib/features/turista/home/presentation/screens/comunicacion_seguridad_screen.dart` | Botón pánico navega a pantalla roja + emite evento Socket *(Fase 3)* |
| `frontend/lib/features/guia/home/presentation/screens/home_wrapper_screen.dart` | Listener de pánico → navega a `PantallaAlertasGuia` automáticamente |
| `frontend/lib/features/guia/chat/presentation/screens/guia_chat_screen.dart` | Agrega `WalkieTalkieButton` junto al botón de anuncio |

---

## Fase 1 — Base y Auth Bypass ✅ Completada

**Objetivo:** Ambas apps abren directamente en su pantalla principal sin login ni folio.

**Tiempo estimado:** ~3 horas | **Estado:** Implementada y verificada sin errores de análisis.

### 1.1 — `demo_config.dart` *(nuevo)*

Punto único de verdad. Cambiar `kDemoMode = false` para restaurar el comportamiento normal.

```dart
// frontend/lib/core/demo/demo_config.dart
const bool kDemoMode = true;
const String kDemoServerUrl = 'https://veltur-demo.up.railway.app'; // actualizar post-deploy
const String kDemoTripId = 'demo-trip-cancun-2026';
const String kDemoTuristaNombre = 'Ana Martínez';
```

### 1.2 — Auth bypass App Guía

- **`guia_locator.dart`** — `GuiaAuthRemoteDataSourceImpl` → `GuiaAuthMockDataSource`; `GuiaHomeRemoteDataSourceImpl` → `GuiaHomeMockDataSource`
- **`main_guia.dart`** — Si `kDemoMode`, escribe en `SharedPreferences` antes de calcular la ruta inicial:
  - `GUIA_ONBOARDING_DONE = true`
  - `CACHED_GUIA_USER = { id, email, name: 'Carlos Mendoza', permissionLevel: 2, authStatus: 'authenticated' }`
- Resultado: la app abre directamente en `/home` con el perfil de guía de agencia precargado.

### 1.3 — Auth bypass App Turista

- **`enrutador_app_turista.dart`** — En `redirect()`, retorna `null` inmediatamente si `kDemoMode` (sin redirigir a folio/login)
- **`main_turista.dart`** — Si `kDemoMode`, escribe `TURISTA_HAS_ACCOUNT = true` en `SharedPreferences`. El router usa `RoutesTurista.home` como `initialLocation`.
- Resultado: la app abre directamente en `/home` con el itinerario visible.

### 1.4 — Datos mock del itinerario

**`itinerary_remote_data_source.dart`** — 5 actividades reales de Tulum con horarios del día:

| Hora | Actividad | Lugar |
|---|---|---|
| 08:00 | Desayuno de bienvenida | Hotel Akumal Bay, Tulum |
| 10:00 | Zona Arqueológica de Tulum | Zona Arqueológica de Tulum, Q.R. |
| 13:00 | Almuerzo en cenote | Restaurante La Selva, Tulum |
| 15:00 | Tiempo libre en Playa Paraíso | Playa Paraíso, Tulum |
| 20:00 | Cena de cierre y brindis | El Camello Jr., Tulum |

### Verificación de Fase 1
```bash
flutter run -t lib/main_turista.dart   # debe abrir en home directamente
flutter run -t lib/main_guia.dart      # debe abrir en home directamente
```
El itinerario debe mostrar las actividades de Tulum, no "Evento del itinerario X".

---

## Fase 2 — Servidor Railway + Socket.IO ✅ Completada

**Objetivo:** Servidor activo en Railway. Ambas apps conectadas desde cualquier red.

**Tiempo estimado:** ~3 horas | **Estado:** Implementada y verificada sin errores de análisis.

### 2.1 — `backend/demo-server/server.js` *(nuevo)*

Mini servidor Node.js (~50 líneas) que maneja exactamente los 5 eventos necesarios para la demo:

| Evento recibido | Acción | Acto de demo |
|---|---|---|
| `joinTrip` | Agrega socket al room del viaje | Setup |
| `turista_panico` | Reenvía a todos en el room | Acto 2 |
| `solicitarCanal` | Concede canal de audio al guía | Acto 3 |
| `audioStream` | Reenvía chunks PCM a los turistas | Acto 3 |
| `liberarCanal` | Libera el canal y notifica | Acto 3 |

### 2.2 — Deploy en Railway

Pasos completos en [`docs/DEMO_VELTUR.md`](DEMO_VELTUR.md#instrucciones-para-crear-el-entorno-en-railway-fase-2).

Resumen:
1. railway.app → New Project → Deploy from GitHub Repo
2. Root Directory: `backend/demo-server`
3. Settings → Networking → Generate Domain
4. Copiar URL en `demo_config.dart` → `kDemoServerUrl`

### 2.3 — `demo_socket_service.dart` *(nuevo)*

Singleton compartido por ambas apps:
- `connect()` — conecta a Railway y hace join al room `kDemoTripId`
- `emitPanic()` — emite evento de pánico (usado en Fase 3 desde App Turista)
- `onPanic` — stream que emite cuando llega un evento de pánico (escuchado en App Guía)

### 2.4 — Listener de pánico en App Guía

**`home_wrapper_screen.dart`** — en `initState()`, si `kDemoMode`, suscribe al stream `onPanic`. Cuando llega el evento, navega automáticamente a `PantallaAlertasGuia` con una turista mock preconfigurada:

```
Nombre: Ana Martínez | Estado: SOS | Distancia: 285m
Motivo: Botón de pánico activado
Contacto de emergencia: Roberto Martínez (Esposo) +52 998 234 5678
```

### 2.5 — Walkie-talkie apunta a Railway

**`walkie_talkie_button.dart`** — URL del servidor viene de `kDemoServerUrl` cuando `kDemoMode = true`.

### 2.6 — WalkieTalkieButton en chat del guía

**`guia_chat_screen.dart`** — el botón de walkie-talkie aparece junto al botón de "Anuncio general" solo cuando `kDemoMode = true`. Instanciado con `tripId: kDemoTripId`.

### Verificación de Fase 2
1. Abrir `https://[url-railway].up.railway.app` en el navegador — debe responder con "Veltur Demo Server OK"
2. Ejecutar ambas apps → los logs de Railway deben mostrar dos conexiones entrantes
3. La App Guía debe estar suscrita y lista para recibir eventos de pánico

---

## Fase 3 — Flujos del Acto 2 y Acto 3 ⏳ Pendiente

**Objetivo:** El botón de pánico muestra una pantalla de emergencia real y emite el evento Socket. El walkie-talkie funciona de extremo a extremo.

**Tiempo estimado:** ~3.5 horas

### 3.1 — `pantalla_emergencia_turista.dart` *(nuevo)*

Pantalla completa que reemplaza al SnackBar actual. Se muestra en la App Turista tras presionar el botón de pánico.

**Elementos visuales:**
- Fondo rojo oscuro (`Color(0xFFB71C1C)`)
- Ícono de alerta grande con animación de pulso (`ScaleTransition`)
- Texto principal: **"Señal enviada al guía"** — blanco, negrita, 24px
- Subtexto: *"Quédate donde estás. El guía fue notificado."*
- Indicador animado: tres puntos parpadeantes ("Esperando respuesta...")
- `WalkieTalkieButton(tripId: kDemoTripId)` visible en la parte inferior para recibir el audio del guía

**Ruta a registrar:** `RoutesTurista.emergencia = '/emergencia'`

Archivos a modificar para registrar la ruta:
- `frontend/lib/core/navigation/routes_turista.dart` — agregar `static const String emergencia = '/emergencia'`
- `frontend/lib/core/navigation/enrutador_app_turista.dart` — agregar `GoRoute` para `/emergencia`

### 3.2 — Conectar botón de pánico

**`comunicacion_seguridad_screen.dart`** — reemplazar el `SnackBar` en el `onLongPress` del botón SOS:

```dart
onLongPress: () {
  if (kDemoMode) DemoSocketService.instance.emitPanic();
  context.push(RoutesTurista.emergencia);
},
```

El botón ya tiene el gesto de long-press (3 segundos) implementado. Solo se cambia la acción.

### 3.3 — `demo_panic_trigger.dart` *(nuevo)* — Respaldo sin internet

Widget invisible para la App Guía. Un `GestureDetector` con `onDoubleTap` posicionado en la esquina superior derecha de `AgenciaMainLayout`. Al activarse, navega directamente a `PantallaAlertasGuia` con la turista mock sin necesitar conexión al servidor.

Solo se renderiza cuando `kDemoMode = true`.

```dart
// Uso en agencia_main_layout.dart:
if (kDemoMode)
  Positioned(
    top: 0, right: 0,
    child: DemoPanicTrigger(),
  ),
```

### Verificación de Fase 3 (flujo completo)

Ejecutar ambas apps simultáneamente y recorrer:

1. ✅ App Turista abre en home directo (sin login)
2. ✅ Acto 1: itinerario con actividades de Tulum → herramientas → mapa con geocerca
3. ✅ Acto 2: presionar pánico (long-press) → pantalla roja en Turista → alerta automática en Guía
4. ✅ Acto 3: Guía presiona walkie-talkie en chat → habla → audio llega a App Turista
5. ✅ Guía desliza "Emergencia Resuelta" → pantalla vuelve a estado normal

---

## Fase 4 — Documentación y Ensayos ⏳ Pendiente

**Objetivo:** Equipo preparado con guión, señales de coordinación y plan de contingencia.

**Tiempo estimado:** ~1.5 horas

### 4.1 — Completar `docs/DEMO_VELTUR.md`

El archivo ya existe con guión, instrucciones de Railway y checklist base. Completar con:
- Señales de coordinación entre el presentador y el integrante lejano (qué frase es el cue para activar la alerta)
- Instrucciones exactas de instalación de las apps en los dispositivos del evento
- Audio pregrabado de respaldo para el walkie-talkie (grabarlo previamente: "Ana, quédate donde estás, en dos minutos estoy contigo")

### 4.2 — Ensayos

| Ensayo | Cuándo | Enfoque |
|---|---|---|
| 1er ensayo (técnico) | Tras completar Fase 3 | Verificar que el flujo completo funciona sin interrupciones |
| 2do ensayo (general) | 2 días antes del evento | Con los dispositivos físicos que se usarán el día del evento |
| 3er ensayo (in situ) | En el lugar del evento | Con la red WiFi/4G del lugar real; probar el hotspot de respaldo |

---

## Resumen de Tiempos y Estado

| Fase | Descripción | Tiempo | Estado |
|---|---|---|---|
| **1** | demo_config · auth bypass · datos mock Tulum | ~3 h | ✅ Completada |
| **2** | Servidor Railway · DemoSocketService · walkie-talkie · listener pánico guía | ~3 h | ✅ Completada |
| **3** | Pantalla emergencia turista · botón pánico conectado · trigger respaldo | ~3.5 h | ⏳ Pendiente |
| **4** | Documentación · ensayos coordinados | ~1.5 h | ⏳ Pendiente |
| **Total** | | **~11 h** | **6 h completadas** |

---

## Plan de Contingencia

| Fallo posible | Respaldo inmediato |
|---|---|
| Servidor Railway no responde | Doble-tap oculto en App Guía (`DemoPanicTrigger`) activa Acto 2 sin internet |
| Walkie-talkie no transmite audio | El integrante reproduce audio pregrabado localmente en su teléfono |
| App Turista no compila | Mostrar capturas de pantalla del Acto 1 en slides |
| App Guía no compila | El integrante muestra capturas en su propio teléfono en el momento del cue |
| Internet inestable en el evento | Activar hotspot 4G personal en ambos dispositivos (independiente del WiFi del lugar) |
| App se cierra en plena demo | Tener la app abierta en segundo plano — swipe para recuperarla inmediatamente |

---

## Cómo desactivar el modo demo

Para restaurar el comportamiento normal de producción, cambiar una sola constante:

```dart
// frontend/lib/core/demo/demo_config.dart
const bool kDemoMode = false;
```

Esto desactiva:
- El bypass de autenticación en ambas apps
- La pre-población de `SharedPreferences`
- El `WalkieTalkieButton` en el chat del guía
- El `DemoPanicTrigger`
- La conexión automática a Railway
- La ruta `/emergencia` queda registrada pero inaccesible (sin el botón que la invoca)

Los datasources del guía permanecen en mock. Para producción, revertir también `guia_locator.dart` a las implementaciones reales.
