# Documentación de Historias de Usuario: App Turista (Móvil)

## Introducción
Este documento contiene las historias de usuario correspondientes a la **App Turista (Móvil)** del sistema OthliAni. Esta aplicación está diseñada bajo una filosofía logística de "cero fricción", permitiendo a los turistas acceder a su itinerario, comunicarse en emergencias con su guía, recibir instrucciones, y ser monitoreados sin necesidad de crear cuentas complejas ni sacrificar la privacidad de sus datos. 

## Roles
* **Turista / Pasajero:** Usuario final del servicio. Su interacción con la app es principalmente de "solo lectura" para el itinerario, "activa" en las integraciones tipo Calculadora OCR, y "reactiva" para ser encontrado y resguardado en la geocerca de seguridad.

<a name="indice"></a>
## Índice
1. [Matriz de Historias de Usuario](#matriz)
2. [TUR-US01: Onboarding sin Fricción, Ingreso Seguro y Sincronización](#tur-us01)
3. [TUR-US02: Otorgamiento de Permisos de Hardware y Promesa de Privacidad](#tur-us02)
4. [TUR-US03: Guía de Bolsillo](#tur-us03)
5. [TUR-US04: Radar de Seguridad, Botón de Pánico y Fallback a SMS (LKL)](#tur-us04)
6. [TUR-US05: Recepción Pasiva de Comunicaciones](#tur-us05)
7. [TUR-US06: Monitoreo Activo de Hardware](#tur-us06)
8. [TUR-US07: Fin del Viaje, Desconexión Automática y Sistema de Reseñas](#tur-us07)
9. [TUR-US08: Calculadora de Divisas Offline y Tipos de Cambio](#tur-us08)
10. [TUR-US09: Clima Logístico Contextual y Recomendaciones de Vestimenta](#tur-us09)
11. [Glosario de Términos](#glosario)

<a name="matriz"></a>
## Matriz de Historias de Usuario

| ID                    | Resumen                               | Perfil(es) | Prioridad |
| :-------------------- | :------------------------------------ | :--------- | :-------- |
| **[US01](#tur-us01)** | Onboarding de 1 paso y Sync Offline   | Turista    | 🔴 Alta    |
| **[US02](#tur-us02)** | Permisos de Hardware y Privacidad     | Turista    | 🔴 Alta    |
| **[US03](#tur-us03)** | Guía de Bolsillo (Itinerario)         | Turista    | 🔴 Alta    |
| **[US04](#tur-us04)** | Radar, Botón Pánico y SMS Fallback    | Turista    | 🔴 Alta    |
| **[US05](#tur-us05)** | Receptor de Megáfono y Alertas        | Turista    | 🟡 Media   |
| **[US06](#tur-us06)** | Monitoreo Activo de Batería/Señal     | Turista    | 🔴 Alta    |
| **[US07](#tur-us07)** | Fin de Viaje, Auto-Kill GPS y Reseñas | Turista    | 🔴 Alta    |
| **[US08](#tur-us08)** | Calculadora de Divisas y OCR Offline  | Turista    | 🟢 Baja    |
| **[US09](#tur-us09)** | Clima Contextual y Códigos Vestimenta | Turista    | 🟢 Baja    |

[⬆️ Volver al Índice](#indice)

---

<a name="tur-us01"></a>
## TUR-US01: Onboarding sin Fricción, Ingreso Seguro y Sincronización
**ÉPICA: App Turista (Móvil)**

### 1. Valor de Negocio

**Como** Turista / Pasajero  
**Quiero** ingresar a la aplicación utilizando un identificador simple (Folio), y que mi teléfono descargue automáticamente el itinerario y los mapas.  
**Para** no perder tiempo creando cuentas con contraseñas complejas, y garantizar que podré consultar mi plan del día sin gastar mis costosos datos móviles (Roaming) durante el viaje.  

---

### 2. Criterios de Aceptación

#### Escenario A: Reclamo del Folio y Device Binding
* **Dado que** la Agencia me envió mi confirmación de viaje,
* **Cuando** abro la App Turista e ingreso mi "Folio de Viaje" y mi factor de seguridad (Correo electrónico registrado),
* **Entonces** el backend valida la combinación.
* **Y** si es correcta, el sistema me otorga un JWT, vincula este acceso al identificador de hardware de mi teléfono, y marca el Folio como `RECLAMADO` en la base de datos.
* **Y** si otra persona intenta usar ese mismo Folio en otro celular, el sistema rechazará la conexión con una advertencia de seguridad.

#### Escenario B: Captura Rápida de Riesgos Médicos (Fricción Positiva) [Pendiente de Confirmar]
* **Dado que** el sistema validó mi acceso exitosamente,
* **Cuando** es la primera vez que ingreso al viaje,
* **Entonces** la app me muestra una pantalla intermedia obligatoria antes del inicio.
* **Y** la pantalla pregunta: *"Por tu seguridad, ¿tienes alguna condición médica o alergia que tu guía deba conocer?"*.
* **Y** me permite teclear un texto breve (Ej. "Alergia a la penicilina, uso Epipen") o presionar un botón grande de *"Ninguna, estoy sano"*.
* **Y** esta información se encripta y se sincroniza directamente con el dispositivo del Guía Líder para su Pase de Lista ([GUIA-US02](guide_user_stories.md#guia-us02)).

#### Escenario C: Descarga de Caché y "Sala de Espera"
* **Dado que** me he autenticado exitosamente,
* **Cuando** la app accede a la pantalla principal,
* **Entonces** descarga de inmediato el itinerario completo, los horarios, la foto del guía, y los mapas base en la memoria local.
* **Y** la app se coloca en un estado de espera de inicio de viaje.
* **Y** durante este estado, mi micrófono está desactivado en la aplicación, mi botón de pánico está inactivo, y la app **NO** enciende el hardware del GPS ni transmite mi ubicación a nadie.

#### Escenario D: Autorización Física y Encendido de Telemetría
* **Dado que** estoy en la "Sala de Espera" digital y llego físicamente al punto de encuentro,
* **Cuando** el Guía verifica mi identidad en persona y me marca como `A_BORDO` en su propia aplicación ([GUIA-US02](guide_user_stories.md#guia-us02)),
* **Entonces** mi aplicación recibe silenciosamente el evento de autorización vía WebSocket o Push.
* **Y** la interfaz de mi app se desbloquea: el Botón de Pánico se habilita y el radar táctico se enciende.
* **Y** solo a partir de este momento, mi dispositivo comienza a transmitir mi telemetría al motor de seguridad.

#### Escenario E: Rescate por Robo de Folio
* **Dado que** intento ingresar mi Folio pero la app me dice "Folio ya reclamado por otro dispositivo" (posible intercepción),
* **Cuando** me encuentro con el Guía y le informo la situación,
* **Entonces** el Guía genera un QR de Rescate ([GUIA-US07](guide_user_stories.md#guia-us07)) en su pantalla.
* **Y** al escanearlo con mi app, el backend revoca inmediatamente el acceso del dispositivo intruso y me vincula como el dueño legítimo de esa identidad en el viaje.

---

### 3. Diseño y UX

* **"Cero Fricción":** La pantalla de inicio debe tener un diseño limpio y directo.

---

### 4. Notas Técnicas

* **Autenticación y Device Binding:**
  - Endpoint `POST /auth/tourist/claim`.
  - El payload debe incluir un `deviceId` (generado por el paquete `device_info_plus` en Flutter).
  - El backend actualiza la tabla `participantes_viaje` seteando `dispositivo_vinculado = deviceId` y `estado_digital = CLAIMED`. Si alguien intenta el mismo endpoint y el `deviceId` no coincide, retorna `HTTP 403 Forbidden`.
* **Precarga de Mapas (Flutter):**
  - Utilizar el paquete de caché vectorial o de tiles rasterizados. La descarga del mapa debe ser asíncrona pero prioritaria, limitando el tamaño del caché (Ej. Máximo 50 MB) para no llenar el almacenamiento de teléfonos de gama baja.
* **Manejo del Campo Médico (Privacidad):**
  - La información ingresada en el Escenario D se debe advertir: *"Esta información es privada y solo se compartirá con tu guía asignado para casos de emergencia."*


[⬆️ Volver al Índice](#indice)


<a name="tur-us02"></a>
## TUR-US02: Otorgamiento de Permisos de Hardware y Promesa de Privacidad
**ÉPICA: App Turista (Móvil)**

### 1. Valor de Negocio

**Como** Turista preocupado por mi privacidad y batería,  
**Quiero** entender claramente por qué la aplicación necesita acceder a mi ubicación en segundo plano y a mi micrófono, y recibir una garantía visual de que no seré rastreado una vez que el tour termine.  
**Para** sentirme seguro de otorgar los permisos necesarios para mi protección (Radar y Walkie-Talkie), y tener la tranquilidad de que mi privacidad post-vacaciones está protegida.  

---

### 2. Criterios de Aceptación

#### Escenario A: La Pantalla Educativa
* **Dado que** el guía está a punto de iniciar el viaje,
* **Cuando** la app necesita solicitar el acceso al GPS por primera vez,
* **Entonces** NO se lanza inmediatamente el cuadro de diálogo nativo del sistema operativo (iOS/Android).
* **Y** en su lugar, se muestra una pantalla educativa a pantalla completa, amigable y con ilustraciones, explicando: *"Para asegurarnos de que no te quedes atrás, OhtliAni necesita saber dónde estás, incluso si guardas el teléfono en tu bolsillo"*.
* **Y** la pantalla incluye un botón grande que dice: *"Entendido, configurar permisos"*.

#### Escenario B: El Contrato de Privacidad
* **Dado que** estoy leyendo la pantalla de permisos (Escenario A),
* **Cuando** leo las letras pequeñas o la sección de garantías,
* **Entonces** veo un "Contrato de Privacidad" con promesas claras:
  1. *"Solo tu guía asignado puede ver tu ubicación."*
  2. *"Tu ubicación nunca se comparte con fines publicitarios."*
  3. *"El rastreo se autodestruye automáticamente en cuanto el viaje termina."*

#### Escenario C: Gestión del Rechazo (Degradación Elegante)
* **Dado que** el sistema operativo lanza el cuadro de diálogo nativo de permisos (Ej. "Permitir siempre" o "Solo mientras la app está en uso"),
* **Cuando** decido presionar **"Rechazar"** o **"No permitir"**,
* **Entonces** la app NO me expulsa ni me bloquea el acceso al itinerario.
* **Y** me permite entrar a la pantalla principal, pero muestra un banner rojo permanente en la parte superior: *"⚠️ Radar de seguridad inactivo. No podremos avisarte si te alejas del grupo. [Activar en Ajustes]"*.
* **Y** el sistema notifica silenciosamente a la App del Guía que este turista específico tiene el GPS apagado.

#### Escenario D: Permisos de Micrófono (Walkie-Talkie On-Demand)
* **Dado que** he otorgado los permisos de ubicación,
* **Cuando** acepto los permisos anteriores,
* **Entonces** la app me solicita el permiso de Micrófono.
* **Y** si lo rechazo, el sistema hace un "Fallback" y en funciones como Botón de Pánico, envía mi alerta de pánico únicamente como texto/coordenadas, sin el clip de voz.

---

### 3. Diseño y UX

> [!WARNING]  
> **El Peligro del Permiso Restringido:** En las versiones modernas de iOS y Android, pedir la ubicación en segundo plano es aterrador para el usuario promedio. La UI educativa debe ilustrar visualmente que, si eligen "Solo mientras se usa la app", la red de seguridad de la agencia fallará letalmente en el momento en que guarden el teléfono en el bolsillo de su pantalón.

* **Transparencia Activa [Pendiente de Confirmar]:** Mientras el viaje esté activo, si el usuario baja el centro de notificaciones de su teléfono, debe ver una notificación fija (Sticky Notification)*

---

### 4. Notas Técnicas

* **Cumplimiento Estricto de las Tiendas:**
  - La justificación de uso del Escenario A y B debe ser lo suficientemente explícita y enviada junto con el binario de la app.
* **Manejo de Permisos:**
  - Utilizar el paquete `permission_handler`. 
  - Evaluar `Permission.locationAlways.status`. Si el estado es `permanentlyDenied` (el usuario marcó "No volver a preguntar"), el botón del banner rojo (Escenario C) debe usar `openAppSettings()` para llevar al usuario directamente a la configuración del sistema operativo.
* **Apagado Automático:**
  - Cuando la app recibe el evento `TRIP_FINISHED` vía WebSocket, el código **DEBE** invocar el método `.stop()` del plugin de geolocalización en segundo plano e invalidar las notificaciones fijas, cumpliendo la promesa del Escenario B.

[⬆️ Volver al Índice](#indice)


<a name="tur-us03"></a>
## TUR-US03: Guía de Bolsillo
**ÉPICA: App Turista (Móvil)**

### 1. Valor de Negocio

**Como** Turista,  
**Quiero** visualizar mi itinerario del día y todos los datos de mi viaje y mi guía sin necesidad de conectarme a internet.  
**Para** saber exactamente a qué hora sale el autobús, dónde es la hora de la comida, y no perder el control de mis tiempos aunque mantenga mis datos móviles apagados (Modo Avión).  

---

### 2. Criterios de Aceptación

#### Escenario A: Visualización del Timeline
* **Dado que** estoy en la pantalla principal de la app,
* **Cuando** selecciono la pestaña Itinerario,
* **Entonces** veo una línea de tiempo vertical con todas las actividades del día.
* **Y** cada tarjeta de actividad muestra: Título (Ej. "Tiempo Libre en la Plaza"), Hora de inicio, Hora de fin, y la dirección física o nombre del lugar.
* **Y** la actividad actual (marcada como `EN_CURSO` por el guía) está resaltada visualmente en un color corporativo y muestra un cronómetro en cuenta regresiva (Ej. "Faltan 45 min para regresar").

#### Escenario B: Supervivencia "Cero Datos"
* **Dado que** estoy en el "Modo Avión",
* **Cuando** abro la app para revisar a qué hora termina el tiempo libre,
* **Entonces** la app lee instantáneamente la base de datos local (descargada previamente) mostrando mi itinerario intacto.
* **Y** si toco una actividad futura, la app me muestra un mapa estático "cacheado" con un pin en el punto de encuentro, permitiéndome orientarme usando solo el hardware del GPS interno.

#### Escenario C: Recepción Pasiva de Cambios
* **Dado que** estoy conectado a una red Wi-Fi o decidí prender mis datos un momento,
* **Cuando** el Guía o la Agencia modifican el itinerario,
* **Entonces** mi aplicación recibe silenciosamente un parche (Patch) de datos en segundo plano.
* **Y** la línea de tiempo se actualiza automáticamente.
* **Y** la app vibra levemente y muestra un mensaje amigable: *"El guía ha actualizado un horario. Revisa tu itinerario."*

---

### 3. Diseño y UX

* **Gestión de Zonas Horarias (Mentalidad Turista):** Es un error común que el turista viaje a Europa y su teléfono siga con la hora de México. El itinerario debe forzar la visualización de la **Hora Local del Destino**, independientemente de lo que diga el reloj del sistema operativo del celular, añadiendo una pequeña nota (Ej. "Horarios en tiempo de París (CET)").
* **El Cronómetro de Retorno:** En los momentos de "Tiempo Libre", el turista no piensa en "Tengo que estar a las 14:30". Piensa en "Me quedan 45 minutos". El cronómetro visual tipo "Cuenta regresiva" es la herramienta más valiosa de esta pantalla para evitar que se confíen y lleguen tarde.

---

### 4. Notas Técnicas

* **Consistencia de Datos Locales (Isar DB):**
  - Toda la vista de esta pantalla debe estar atada a un `Stream` o `Watcher` de la base de datos local (Isar/Realm). Cuando llega un evento de WebSocket (`ITINERARY_UPDATED`), el backend móvil solo debe guardar el JSON en la base local. La UI reaccionará automáticamente a ese cambio en la base, garantizando la arquitectura *Offline-First*.
* **Manejo de Mapas Locales:**
  - En el Escenario B, si el usuario toca la tarjeta para ver el mapa del punto de encuentro, el mapa debe inicializarse usando los *Tiles* guardados en el almacenamiento del dispositivo por el paquete de caché (ej. `flutter_map_tile_caching`), cargando el archivo `.mbtiles` o el directorio local en lugar de pedir imágenes a Google/Mapbox por red.

[⬆️ Volver al Índice](#indice)


<a name="tur-us04"></a>
## TUR-US04: Radar de Seguridad, Botón de Pánico y Fallback a SMS (LKL)
**ÉPICA: App Turista (Móvil)**

### 1. Valor de Negocio

**Como** Turista que se encuentra en un viaje,  
**Quiero** visualizar en un mapa simple mi ubicación exacta respecto a la de mi guía, y tener un Botón de Pánico accesible que funcione incluso si me quedo sin plan de datos móviles.  
**Para** orientarme rápidamente si me separo del grupo, pedir auxilio inmediato en caso de una emergencia médica o de seguridad, y tener la garantía de que el sistema registrará mi última ubicación si mi teléfono se apaga por falta de batería.  

---

### 2. Criterios de Aceptación

#### Escenario A: El Radar Minimalista
* **Dado que** estoy dentro de un viaje activo y abro la pestaña "Mapa" o "Radar",
* **Cuando** la pantalla carga mi ubicación,
* **Entonces** visualizo un mapa cartográfico limpio (descargado previamente en mi caché).
* **Y** veo dos puntos en el mapa: Mi ubicación y la ubicación en tiempo real de mi Guía Líder.
* **Y** NO veo la ubicación del resto de los turistas del grupo.
* **Y** veo un círculo semitransparente que me indica mi "Zona Segura" (La geocerca dinámica definida por la Agencia).

#### Escenario B: Activación del Botón de Pánico (Con Internet)
* **Dado que** me siento en peligro,
* **Cuando** deslizo o mantengo presionado el botón rojo de "EMERGENCIA" en mi pantalla,
* **Entonces** mi aplicación captura mis coordenadas exactas.
* **Y** emite una alerta crítica (`PANIC_ALERT`) a través de la conexión WebSocket al servidor.
* **Y** mi pantalla cambia a un "Modo de Rescate", desbloqueando automáticamente el micrófono para que pueda enviarle una nota de voz directa al guía ([GUIA-US06](guide_user_stories.md#guia-us06) Unicast de Emergencia).

#### Escenario C: Fallback a SMS Automático [Pendiente de Confirmar]
* **Dado que** intento activar el Botón de Pánico (Escenario B),
* **Cuando** mi teléfono detecta que NO hay conexión a internet (ni Wi-Fi ni Datos Móviles) pero sí tengo señal de red celular tradicional,
* **Entonces** la app me muestra un aviso instantáneo: *"Sin internet. Redirigiendo a SMS de emergencia"*.
* **Y** la app abre automáticamente mi aplicación nativa de mensajes de texto.
* **Y** pre-llena un mensaje con el formato: `[EMERGENCIA OHTLIANI] Soy Carlos. Necesito ayuda. Mi última ubicación: https://maps.google.com/?q=20.684,-88.567`
* **Y** el destinatario ya está pre-configurado con el número telefónico local del Guía Líder, listo para que yo solo presione "Enviar".

#### Escenario D: Last Known Location
* **Dado que** mi teléfono se quedó sin batería o entré a un túnel subterráneo profundo,
* **Cuando** mi dispositivo deja de enviar su "ping" de telemetría por más de 3 minutos,
* **Entonces** el servidor (Backend) detecta la desconexión.
* **Y** el sistema congela mi última coordenada reportada en el Mapa Táctico del Guía, cambiándola a un color gris y agregando una etiqueta de tiempo: *"Carlos - Desconectado. Última vez visto aquí hace 4 minutos"*.

---

### 3. Diseño y UX

> [!IMPORTANT]  
> **Prevención de Falsas Alarmas:** El Botón de Pánico NUNCA debe ser de "un solo toque". Debe requerir un gesto cognitivo deliberado crítico (Ej. Deslizar un switch largo hasta el final -"Slide to SOS"-, o mantener presionado un círculo expansivo por 3 segundos continuos) para evitar llamadas accidentales del 911 logístico.

---

### 4. Notas Técnicas

* **El Fallback a SMS:**
  - Para lograr el Escenario C, el desarrollador debe interceptar el error de red o usar el paquete `connectivity_plus` antes de disparar el WebSocket.
  - Si no hay red, usar el paquete `url_launcher` con el esquema URI: `sms:+525512345678?body=TextoDeEmergencia`. Apple y Google permiten esto porque requiere que el usuario confirme el envío del SMS en la app nativa, por lo que no se considera "spam automatizado".
* **Frecuencia de Telemetría (Battery Saver)[Pendiente de Confirmar]:**
  - El plugin de geolocalización en segundo plano de la app del turista (`flutter_background_geolocation`) debe configurarse para ser pasivo. Enviar la ubicación solo cada 30 segundos, o cuando el turista se desplace más de 10 metros (`distanceFilter`). Si el turista está sentado comiendo, el GPS debe entrar en suspensión (Sleep Mode) para no drenar su batería.
* **El Motor LKL (Redis):**
  - El backend debe usar las llaves de expiración de Redis (TTL). Cada vez que el turista hace "ping", la llave `tourist:{id}:location` se actualiza y se le da un TTL de 3 minutos. Si el TTL expira sin recibir un nuevo ping, Redis dispara un evento de "Llave Expirada" que avisa al servidor Node.js para que notifique al guía la desconexión del turista (Escenario D).

[⬆️ Volver al Índice](#indice)


<a name="tur-us05"></a>
## TUR-US05: Recepción Pasiva de Comunicaciones
**ÉPICA: App Turista (Móvil)**

### 1. Valor de Negocio

**Como** Turista que se encuentra disfrutando de un destino turístico,  
**Quiero** recibir notificaciones claras o mensajes de voz del guía sin tener que mantener la aplicación abierta,  
**Para** no perderme instrucciones importantes, estar informado sobre cambios logísticos en mi itinerario, y disfrutar de mi tiempo libre sin tener que estar revisando la pantalla constantemente.  

---

### 2. Criterios de Aceptación

#### Escenario A: Recepción del Megáfono Masivo (Pantalla Bloqueada)
* **Dado que** estoy tomando fotos y tengo el teléfono bloqueado en mi bolsillo,
* **Cuando** el Guía Líder utiliza su Megáfono Digital (Broadcast PTT - [GUIA-US06](guide_user_stories.md#guia-us06)),
* **Entonces** mi teléfono "despierta" emitiendo una vibración distintiva (Ej. dos pulsos largos) y un sonido de notificación único de la app.
* **Y** recibo una Notificación Push de Alta Prioridad que dice: *"📢 Nueva instrucción de voz de tu Guía"*.
* **Y** si tengo auriculares puestos o la app abierta en primer plano, la música disminuye su volumen (Audio Ducking) y el mensaje de voz del guía se reproduce automáticamente de principio a fin.

#### Escenario B: Recepción del Unicast (Intervención Directa del Guía)
* **Dado que** me estoy rezagando del grupo sin darme cuenta,
* **Cuando** el Guía me envía un mensaje de voz directo y privado,
* **Entonces** mi teléfono vibra agresivamente.
* **Y** la pantalla se enciende mostrando un modal azul: *"Mensaje directo de tu guía"*.
* **Y** al terminar de reproducirse el audio del guía, mi aplicación **desbloquea temporalmente el botón de micrófono**, permitiéndome mantener presionado para responderle directamente (Ej. "Voy corriendo para allá").

#### Escenario C: Alertas Silenciosas (Cambios Logísticos de Agencia)
* **Dado que** la Agencia o el Guía han recorrido el horario de una actividad,
* **Cuando** el sistema envía el parche de itinerario (`ITINERARY_PATCH`),
* **Entonces** mi teléfono emite una vibración corta y muestra una notificación push silenciosa: *"Actualización en tu Itinerario"*.
* **Y** mi "Guía de Bolsillo" (Línea de tiempo) se actualiza en segundo plano para reflejar el nuevo horario.

#### Escenario D: Caducidad de Mensajes (Evitar Confusión Post-Desconexión)
* **Dado que** estuve sin señal durante 30 minutos y el guía envió un audio hace 25 minutos,
* **Cuando** salgo de la cueva y mi teléfono recupera la conexión 4G,
* **Entonces** el sistema evalúa la "Marca de Tiempo" (Timestamp) del mensaje de voz encolado.
* **Y** si el mensaje tiene más de 5 minutos de antigüedad (Time-To-Live superado), el sistema NO lo reproduce.
* **Y** en su lugar, me muestra una notificación: *"Tuviste mensajes de voz mientras estabas sin señal. Revisa el mapa para ubicar al grupo"*.

---

### 3. Diseño y UX

* **Prioridad de Interrupción (Audio Ducking):** Los turistas a menudo escuchan podcasts o música mientras caminan. El diseño UX exige que la app actúe como una app de navegación (Ej. Google Maps/Waze). Cuando entra un mensaje del guía, el volumen del reproductor de música del turista debe atenuarse al 20%, el guía habla al 100%, y luego la música vuelve a la normalidad.
* **El Historial de Avisos:** En la pantalla principal debe existir un pequeño ícono de campana (Historial de Avisos). Si el turista estaba en una llamada telefónica y no pudo escuchar el Megáfono del guía, puede entrar a este historial y presionar "Play" para volver a escuchar las últimas 2 instrucciones del día.

---

### 4. Notas Técnicas

* **Notificaciones Push Críticas (FCM / APNs):**
  - Para lograr el Escenario A en teléfonos bloqueados o en reposo, el backend debe enviar la notificación usando `priority: "high"` (Android) y `apns-priority: 10` con `content-available: 1` (iOS).
* **Gestión de Sesiones de Audio:**
  - Configurar la sesión de audio como con la opción `duckOthers` (Atenuar otros audios). Esto es lo que permite que el Walkie-Talkie reduzca el volumen de Spotify/Apple Music sin detener la canción del turista.
* **TTL (Time-To-Live) en Colas de Mensajes:**
  - En el backend (Redis/Socket.io), los mensajes de broadcast de voz deben tener un parámetro `expires_at`. La app del turista debe comparar este timestamp con la hora actual (`DateTime.now().toUtc()`) antes de decidir si reproduce el audio o lo descarta (Escenario D).

[⬆️ Volver al Índice](#indice)


<a name="tur-us06"></a>
## TUR-US06: Monitoreo Activo de Hardware
**ÉPICA: App Turista (Móvil)**

### 1. Valor de Negocio

**Como** Turista,  
**Quiero** que la aplicación monitoree de forma invisible el nivel de batería y la calidad de conexión de mi dispositivo y notifique al sistema si me encuentro en riesgo de desconexión,  
**Para** que el Guía pueda advertirme físicamente antes de que mi teléfono se apague, y para que el sistema ajuste su consumo de energía automáticamente, extendiendo la vida de mi batería para emergencias reales.  

---

### 2. Criterios de Aceptación

#### Escenario A: Telemetría Enriquecida (El Ping de Salud)
* **Dado que** el viaje está activo y mi teléfono está transmitiendo mi ubicación en segundo plano,
* **Cuando** la app emite su "Ping" de coordenadas cada 30 segundos,
* **Entonces** adjunta silenciosamente a ese paquete de datos dos métricas clave de hardware: el Porcentaje de Batería (Ej. `85%`) y el Tipo de Red (Ej. `WIFI`, `4G`, `LTE`, `NONE`).
* **Y** esta información NO interfiere con mi experiencia en pantalla, pero actualiza mi estado en el Radar Táctico del Guía ([GUIA-US04](guide_user_stories.md#guia-us04)).

#### Escenario B: Alerta Temprana de "Muerte de Dispositivo"
* **Dado que** estoy tomando muchas fotos y el brillo de mi pantalla está consumiendo mi energía,
* **Cuando** el nivel de batería de mi teléfono cae al **15%** (o al límite configurado),
* **Entonces** mi propia aplicación me muestra un pequeño banner: *"Batería baja. El rastreo de seguridad sigue activo, te sugerimos no perder de vista a tu guía."*

#### Escenario C: Degradación de Señal (Contexto de Desconexión)
* **Dado que** el autobús entra a una zona montañosa,
* **Cuando** la antena de mi celular reporta que la señal ha cambiado de `4G` a `Edge/2G` o está a punto de perderse,
* **Entonces** el último "Ping" que logra salir de mi teléfono marca un flag de `SIGNAL_DEGRADED`.
* **Y** si me desconecto completamente, el Guía sabrá (por este último aviso) que mi desaparición del mapa se debe a un problema de cobertura geográfica.

#### Escenario D: Auto-Ajuste de Consumo (Modo Supervivencia GPS) [Pendiente de Confirmar]
* **Dado que** mi batería ha llegado al **10%** y sigo lejos del hotel,
* **Cuando** el sistema operativo lanza la advertencia de "Batería Crítica",
* **Entonces** la App Turista intercepta este estado y entra automáticamente en "Modo Supervivencia".
* **Y** reconfigura el plugin del GPS: En lugar de enviar mi ubicación cada 30 segundos, la envía **cada 2 minutos** (o cuando presione el Botón de Pánico).
* **Y** esto garantiza la poca batería que me queda reservada por si llego a necesitar auxilio real.

---

### 3. Diseño y UX

* **Iconografía en el Lado del Guía:** (Relacionado con la Épica 2). Gracias a esta historia, el Guía verá un pequeño ícono de batería (verde, amarilla o roja) junto al nombre de cada turista en su lista, dándole una visión sobre la "salud tecnológica" de su grupo.

---

### 4. Notas Técnicas

* **Librerías Nativas (Flutter):**
  - Utilizar `battery_plus` para suscribirse al Stream de cambios de batería (`onBatteryStateChanged`).
  - Utilizar `connectivity_plus` para detectar cambios en el tipo de red (`onConnectivityChanged`).
* **Reconfiguración Dinámica del Background Geolocation:**
  - El plugin comercial/open-source de geolocalización debe permitir la reconfiguración en caliente (Hot Reload of Config).
  - En el Escenario D, el código debe ejecutar algo similar a: `BackgroundGeolocation.setConfig({ distanceFilter: 50, locationUpdateInterval: 180000 })` para reducir drásticamente el uso de la antena GPS y del procesador, alargando la vida útil del teléfono por hasta 1 o 2 horas adicionales en standby.

[⬆️ Volver al Índice](#indice)


<a name="tur-us07"></a>
## TUR-US07: Fin del Viaje, Desconexión Automática y Sistema de Reseñas
**ÉPICA: App Turista (Móvil)**

### 1. Valor de Negocio

**Como** Turista que acaba de terminar su viaje,  
**Quiero** que la aplicación deje de rastrear mi ubicación automáticamente sin que yo tenga que hacer nada, y tener una forma rápida de calificar la experiencia,  
**Para** tener la garantía absoluta de que mi privacidad está a salvo mientras regreso a mi hotel, ahorrar el resto de mi batería, y poder compartir mi opinión sobre el desempeño del guía para ayudar a futuros viajeros (o quejarme si algo salió mal).  

---

### 2. Criterios de Aceptación

#### Escenario A: Cumplimiento de Privacidad
* **Dado que** el Guía Líder ha presionado "Finalizar Viaje de Hoy" en su aplicación ([GUIA-US10](guide_user_stories.md#guia-us10)),
* **Cuando** mi teléfono móvil (tenga la app abierta o bloqueada en el bolsillo) recibe el evento silencioso de finalización,
* **Entonces** el sistema operativo de mi teléfono detiene **inmediata y permanentemente** el servicio de geolocalización en segundo plano.
* **Y** la notificación fija en mi barra de tareas ("OhtliAni está usando tu ubicación") desaparece por completo.
* **Y** el ícono del GPS en la barra de estado de mi celular se apaga, dándome la certeza física de que ya no estoy siendo monitoreado.

#### Escenario B: Cumplimiento de Privacidad II [Pendiente de Confirmar]
* **Dado que** mi teléfono se quedó sin internet y no pudo recibir el evento de finalización del Guía,
* **Cuando** la hora actual supera la "Hora de Fin Programada" del itinerario más un margen de tolerancia (Ej. +2 horas),
* **Entonces** la aplicación ejecuta un "Suicidio Lógico" (Self-Kill) de sus procesos de fondo de manera autónoma.
* **Y** detiene el rastreo GPS localmente, garantizando que no seré rastreado indefinidamente solo por haber perdido la conexión a la red.

#### Escenario C: El Sistema de Reseñas
* **Dado que** estoy viendo la pantalla de "Viaje Concluido",
* **Cuando** el sistema me invita a calificar mi experiencia,
* **Entonces** veo una interfaz simple con 5 estrellas en blanco y la pregunta: *"¿Cómo calificarías el desempeño de tu guía [Nombre del Guía]?"*.
* **Y** al tocar una estrella (Ej. 5 estrellas), aparece un campo de texto *opcional* para dejar un comentario, y un botón de "Enviar".
* **Y** esta reseña viaja directamente al Dashboard de la Agencia ([AGEN-US06](agency_user_stories.md#agen-us06)) para evaluar el rendimiento del empleado y alimentar las analíticas de satisfacción.

#### Escenario D: El "Call to Action" Comercial
* **Dado que** he enviado mi reseña exitosamente,
* **Cuando** la pantalla de agradecimiento aparece,
* **Entonces** la Agencia tiene un espacio configurado para mostrarme un botón de promoción: *"¿Buscas tu próxima aventura? Descubre más tours en [Sitio Web de la Agencia]"*.
* **Y** al presionarlo, me redirige al navegador web, cerrando el ciclo de vida de la app y fomentando la re-compra.

---

### 3. Diseño y UX

> [!NOTE]  
> **Psicología de la Conversión (Reseñas):** La pantalla de finalización debe mostrar **primero** el mensaje contundente de "Rastreo Desactivado" con un escudo. Reducir la ansiedad de privacidad del usuario aumenta drásticamente las probabilidades de que responda alegremente dejándote 5 estrellas.

* **Cero Cuentas, Cero Spam:** Como el turista nunca creó una cuenta con contraseña, no debemos pedirle que inicie sesión para dejar la reseña. El token JWT residual temporal del viaje es suficiente autorización digital para que el servidor Node la acepte.

---

### 4. Notas Técnicas

* **Ejecución del Auto-Kill Switch:**
  - El sistema debe estar suscrito al canal de WebSockets o a un *Silent Push* de Firebase Cloud Messaging (FCM). 
  - Al recibir el payload `{"action": "FORCE_STOP_TRACKING"}`, la app invoca el código nativo: `BackgroundGeolocation.stop()` y `BackgroundGeolocation.removeListeners()`.
* **El Cronómetro de Respaldo (Edge Computing):**
  - Para lograr el Escenario B, al momento de descargar el itinerario por la mañana, se debe registrar un `WorkManager` (Android) o un `BGTaskScheduler` (iOS) que despierte la app a la hora estimada de fin del tour + 2 horas para ejecutar la limpieza de la telemetría, independientemente de si hay internet o no.
* **Payload de la Reseña (API):**
  - Endpoint: `POST /trips/{trip_id}/reviews`
  - Body: `{ "tourist_id": "uuid-123", "rating": 5, "comment": "El guía fue súper atento cuando me perdí." }`
  - El backend debe validar que el `tourist_id` pertenezca a ese viaje y que no haya enviado una reseña previamente.

[⬆️ Volver al Índice](#indice)


<a name="tur-us08"></a>
## TUR-US08: Calculadora de Divisas Offline y Tipos de Cambio
**ÉPICA: App Turista (Móvil)**

### 1. Valor de Negocio

**Como** Turista internacional,  
**Quiero** tener una calculadora de divisas rápida que funcione sin conexión a internet y que conozca automáticamente mi moneda de origen y la moneda local del destino.  
**Para** poder convertir precios instantáneamente sin gastar mis datos móviles (roaming), evitar ser víctima de fraudes o tipos de cambio abusivos por parte de vendedores locales, y controlar mi presupuesto diario con confianza.  

---

### 2. Criterios de Aceptación

#### Escenario A: Sincronización Silenciosa del Tipo de Cambio
* **Dado que** la aplicación realiza su sincronización matutina de datos ([TUR-US01](#tur-us01)),
* **Cuando** mi teléfono detecta conexión Wi-Fi o datos,
* **Entonces** el sistema descarga silenciosamente el tipo de cambio oficial del día entre mi moneda de origen (Ej. MXN) y la moneda del destino del tour (Ej. USD o EUR).
* **Y** guarda este multiplicador (Tasa de Cambio) en la base de datos local junto con la fecha y hora de la última actualización.

#### Escenario B: Conversión Bidireccional Rápida
* **Dado que** estoy en un mercado de artesanías sin señal de internet,
* **Cuando** abro la pestaña "Herramientas" o "Divisas" en mi Guía de Bolsillo,
* **Entonces** veo una calculadora minimalista pre-configurada.
* **Y** si un vendedor me dice "Cuesta 500 pesos", escribo en el campo de Moneda Local (MXN) y el campo de Moneda de Origen (USD) se actualiza instantáneamente.
* **Y** la conversión funciona de manera inversa.

#### Escenario C: Botones de Acceso Rápido (Cero Fricción) [Pendiente de Confirmar]
* **Dado que** estoy apurado pagando en un taxi o restaurante,
* **Cuando** abro la calculadora,
* **Entonces** debajo de los campos de texto veo "Botones de Conversión Rápida" pre-calculados basados en denominaciones comunes de billetes locales (Ej. Botones para: `100 MXN`, `200 MXN`, `500 MXN`).
* **Y** al tocar uno, me da el equivalente en mi moneda al instante sin tener que abrir el teclado del teléfono.

#### Escenario D: Escaneo Inteligente de Precios por Cámara
* **Dado que** estoy viendo una etiqueta de precio en el aparador de una tienda o un menú de restaurante,
* **Cuando** presiono el ícono de la "Cámara" dentro de la calculadora de divisas,
* **Entonces** se abre un visor de cámara rápida en la mitad de la pantalla con un recuadro de enfoque.
* **Y** al apuntar el recuadro hacia la etiqueta física (Ej. "¥ 15,000"), el sistema reconoce los números mediante Inteligencia Artificial local.
* **Y** auto-rellena el campo de "Moneda Local" con el número extraído y realiza la conversión a mi moneda de origen en tiempo real, superponiendo el precio traducido en la pantalla como Realidad Aumentada (AR) o en los campos de la calculadora.

---

### 3. Diseño y UX

> [!CAUTION]  
> **Disclaimer Legal Financiero:** Debe haber un texto pequeño visible debajo del resultado pre-calculado que exprese: *"Tipo de cambio de referencia orientativo para el turista (1 USD = 17.5 MXN). No representa una tasa bancaria oficial ni constituye obligación legal para OhtliAni o la Agencia."*

---

### 4. Notas Técnicas

* **Consumo de API de Divisas (Backend vs Mobile):**
  - Para ahorrar costos de llamadas a APIs de terceros, los teléfonos móviles **NO** deben consultar la API externa directamente. 
  - El Backend de OhtliAni (NestJS) debe ejecutar un *Cron Job* diario a las 00:00 UTC para descargar las tasas globales y guardarlas en Redis. Luego, la App Móvil del turista simplemente descarga esa tasa desde nuestro propio backend durante el *Fetch* del itinerario.
* **Motor OCR On-Device:**
  - Se debe instanciar el modelo de reconocimiento `TextRecognitionScript.latin` en modo *On-Device*. NUNCA usar la versión *Cloud API* de ML Kit, ya que rompería nuestra promesa de funcionalidad Offline e incurriría en costos por cada escaneo del turista.
* **Almacenamiento Local:**
  - Almacenar los valores `base_currency`, `target_currency` y `exchange_rate` (Float/Double). Todas las multiplicaciones en el Escenario B suceden en la memoria RAM del teléfono, con latencia cero.

[⬆️ Volver al Índice](#indice)


<a name="tur-us09"></a>
## TUR-US09: Clima Logístico Contextual y Recomendaciones de Vestimenta [Pendiente de Confirmar]
**ÉPICA: App Turista (Móvil)**

### 1. Valor de Negocio

**Como** Turista preparándome para mi recorrido del día,  
**Quiero** conocer el pronóstico del clima atado específicamente a la ubicación y horario de mis actividades, junto con sugerencias de vestimenta. 
**Para** saber qué empacar en mi mochila, evitar golpes de calor o hipotermia, y cumplir con los códigos de vestimenta estrictos de ciertos recintos sin que el guía tenga que recordárnoslo uno por uno.  

---

### 2. Criterios de Aceptación

#### Escenario A: Pronóstico Atado a la Actividad (No a la Ciudad)
* **Dado que** estoy revisando mi Itinerario Interactivo (Guía de Bolsillo - [TUR-US03]),
* **Cuando** observo la tarjeta de una actividad futura (Ej. "Visita a la Zona Arqueológica" a las 12:00 PM),
* **Entonces** veo un pequeño widget del clima incrustado directamente en esa tarjeta.
* **Y** este widget no muestra el clima general de la ciudad, sino el clima proyectado **específicamente a las 12:00 PM** en la coordenada exacta (Ej. ☀️ 36°C - UV Extremo).

#### Escenario B: Las "Reglas de Vestimenta" (Dress Codes)
* **Dado que** el itinerario incluye la visita a una Catedral donde no se permiten hombros descubiertos ni shorts,
* **Cuando** la Agencia o el Guía han configurado un *Dress Code* para esa parada,
* **Entonces** la tarjeta de la actividad muestra un ícono de advertencia o de ropa.
* **Y** al tocarlo, se despliega una nota clara: *"⚠️ Código de Vestimenta Obligatorio: Pantalón largo y hombros cubiertos. Se negará el acceso en caso de incumplimiento."*

#### Escenario C: El "Briefing" Nocturno (Notificación Proactiva)
* **Dado que** son las 20:00 hrs y estoy en el hotel descansando,
* **Cuando** el sistema evalúa el itinerario del día de mañana,
* **Entonces** recibo una Notificación Push contextual diseñada para ayudarme a preparar mi ropa.
* **Y** el mensaje dice: *"Para tu tour de mañana se espera lluvia ligera y caminatas largas. Sugerencia: Lleva calzado cómodo y un impermeable."*

#### Escenario D: Actualizaciones de Clima Crítico (Live Updates)
* **Dado que** estamos en tránsito en el autobús y el clima cambia drásticamente,
* **Cuando** el servidor actualiza el pronóstico del clima a "Peligroso",
* **Entonces** la app actualiza el ícono del clima en mi itinerario y me muestra una recomendación automática de seguridad, permitiendo al guía y a la agencia anticipar retrasos sin que los turistas entren en pánico.

---

### 3. Diseño y UX

* **Visualización Intuitiva:** Debe ser un ícono simple (Sol, Nubes, Lluvia) y la temperatura junto al nombre de la actividad.
* **Iconografía de Vestimenta:** Las recomendaciones deben acompañarse de íconos universales. (Ej. Un dibujo de unos lentes de sol, una botella de agua, unas botas de montaña).

---

### 4. Notas Técnicas

* **Consumo del API Meteorológico (Backend):**
  - Al igual que las divisas, los celulares NO consumen directamente la API de clima.
  - El Backend (Node.js) consulta una API como *OpenWeatherMap* (usando el endpoint de pronóstico por horas o `One Call API`) para las coordenadas (`lat`, `lng`) de los hitos del viaje de mañana.
  - El backend inyecta estos datos (Ícono, Temperatura Máx/Min, Probabilidad de Lluvia) dentro del payload JSON del Itinerario que la App Turista descarga en su *Sincronización Matutina*.
* **Modelo de Datos Extendido (PostgreSQL):**
  - La tabla de `actividades` en la base de datos central debe incluir columnas como `codigo_vestimenta` (String/Text) y `equipo_recomendado` (Array de Strings: ['bloqueador', 'agua', 'sombrero']). Esto se gestiona desde el Portal de la Agencia en la Creación de Viajes.

[⬆️ Volver al Índice](#indice)

---

<a name="glosario"></a>
## Glosario de Términos

* **Folio de Viaje:** Alfanumérico corto único y de uso destructivo, repartido por correo o WhatsApp al cliente tras comprar el viaje en la agencia. Actúa como llave maestra y reemplaza al proceso tedioso de registro por contraseñas.
* **Device Binding:** Mecánica de ciberseguridad que ata inquebrantablemente el Token JWT válido hacia el identificador único físico del hardware del teléfono (IMEI / UUID). Evita que varias personas compartan un mismo Folio y clonen el GPS.
* **Audio Ducking:** Al emitir un sonido de alta prioridad sobre un canal, la programación nativa "hunde" (atenúa) el volumen base (Ej. Música de Spotify/Apple) al 20%, permitiendo escuchar al guía sin cortar violentamente la música de fondo del cliente.
* **LKL (Last Known Location):** Posición geográfica estática guardada un milisegundo antes de que la batería o señal del usuario mueran. Vital para limitar el radio o enviar brigadas de rescate al último punto conocido.
* **OCR (Optical Character Recognition):** Módulo de IA On-Device (procesado localmente por la RAM usando TensorFlow Lite/MLKit, sin consumir Wi-Fi de Azure/Google) que detecta trazados generados por la cámara y los traduce a texto digital manipulable, usándolo para la captura instantánea de precios turísticos e importes sin teclear en la calculadora.

[⬆️ Volver al Índice](#indice)
