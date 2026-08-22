# Documentación de Historias de Usuario: App Guía (Móvil)

## Introducción
Este documento contiene las historias de usuario correspondientes a la **App Guía (Móvil)** del sistema OthliAni. Aquí se detalla la funcionalidad que permite a los guías de turistas (Líderes y de Apoyo) operar la logística en campo, llevar el control de los pasajeros, comunicarse con la agencia, y responder a incidentes en tiempo real o en modo offline.

## Roles
* **Guía Líder:** Principal responsable del grupo en campo. Tiene permisos para arrancar el viaje, omitir hitos, reportar alertas clave, y emitir el cierre oficial del tour.
* **Guía de Apoyo:** Ayudante logístico. Tiene acceso de lectura al itinerario y radar, y comunicación celular privada con el Guía Líder y la Agencia, pero las acciones irreversibles para el tour como tal están restringidas.

<a name="indice"></a>
## Índice
1. [Matriz de Historias de Usuario](#matriz)
2. [GUIA-US01: Autenticación, Detección de Viaje y Sincronización Inicial (Offline-First)](#guia-us01)
3. [GUIA-US02: Pase de Lista Digital y Control de Acceso](#guia-us02)
4. [GUIA-US03: Ejecución del Itinerario y Sincronización de Actualizaciones en Vivo](#guia-us03)
5. [GUIA-US04: Mapa Táctico, Radar de Proximidad y Clustering](#guia-us04)
6. [GUIA-US05: Recepción de Alertas, Triaje en Campo y Reporte Rápido a Central](#guia-us05)
7. [GUIA-US06: Megáfono Digital PTT y Chat de Agencia](#guia-us06)
8. [GUIA-US07: Protocolo de Rescate Local (Re-vinculación de Turista)](#guia-us07)
9. [GUIA-US08: Control Avanzado del Itinerario (Gestión de Retrasos, Omisiones y Check-in)](#guia-us08)
10. [GUIA-US09: Mi Perfil, Agenda de Viajes Futuros y Ajustes Locales](#guia-us09)
11. [GUIA-US10: Cierre de Viaje, Sincronización Final y Apagado Legal del GPS](#guia-us10)
12. [Glosario de Términos](#glosario)

<a name="matriz"></a>
## Matriz de Historias de Usuario

| ID                     | Resumen                                | Perfil(es)   | Prioridad |
| :--------------------- | :------------------------------------- | :----------- | :-------- |
| **[US01](#guia-us01)** | Autenticación y Sincronización Offline | Líder, Apoyo | 🔴 Alta    |
| **[US02](#guia-us02)** | Pase de Lista Digital y Control Médico | Líder, Apoyo | 🔴 Alta    |
| **[US03](#guia-us03)** | Ejecución de Itinerario y Live Updates | Líder        | 🔴 Alta    |
| **[US04](#guia-us04)** | Mapa Táctico y Radar de Proximidad     | Líder, Apoyo | 🔴 Alta    |
| **[US05](#guia-us05)** | Alertas, Triaje y Reportes a Central   | Líder        | 🟡 Media   |
| **[US06](#guia-us06)** | Megáfono PTT, Chat y Unicast           | Líder, Apoyo | 🟡 Media   |
| **[US07](#guia-us07)** | Protocolo de Rescate / Re-vinculación  | Líder        | 🟡 Media   |
| **[US08](#guia-us08)** | Control Avanzado (Retrasos, Omisiones) | Líder        | 🟢 Baja    |
| **[US09](#guia-us09)** | Agenda, Perfil y Precarga Logística    | Líder, Apoyo | 🟢 Baja    |
| **[US10](#guia-us10)** | Cierre de Viaje y Kill-Switch de GPS   | Líder        | 🔴 Alta    |

[⬆️ Volver al Índice](#indice)

---

<a name="guia-us01"></a>
## GUIA-US01: Autenticación, Detección de Viaje y Sincronización Inicial (Offline-First)
**ÉPICA: App Guía (Móvil)**

### 1. Valor de Negocio

**Como** Guía de Turistas (Líder o Apoyo)  
**Quiero** iniciar sesión en mi aplicación móvil y que el sistema descargue automáticamente toda la información logística de mi viaje del día (itinerario, pasajeros, reglas de seguridad y mapas).  
**Para** poder operar el tour, hacer el pase de lista y conocer las alergias de mis turistas incluso si me encuentro en una zona remota (selva, montaña, carretera) sin cobertura de red celular.  

---

### 2. Criterios de Aceptación

#### Escenario A: Inicio de Sesión y Detección de Viaje Activo
* **Dado que** abro la App Guía por primera vez o mi sesión expiró,
* **Cuando** ingreso mis credenciales (Correo y Contraseña) y presiono "Entrar",
* **Entonces** el backend valida mi cuenta y retorna un Token JWT de acceso seguro.
* **Y** el sistema consulta inmediatamente si tengo un viaje asignado en estado `PROGRAMADO` o `EN_CURSO`.
* **Y** si no tengo viajes asignados, me muestra una pantalla de "Día Libre" con mi perfil y la opción de cerrar sesión.

#### Escenario B: Sincronización (Pre-Fetch Logístico)
* **Dado que** el sistema detectó que tengo un viaje asignado para hoy,
* **Cuando** el inicio de sesión es exitoso (y tengo conexión a Internet/Wi-Fi),
* **Entonces** la app muestra una pantalla de bloqueo temporal ("Sincronizando viaje... No cierres la app").
* **Y** la app descarga y guarda en la base de datos local los siguientes bloques de información:
  1. **El Itinerario:** Todas las paradas, horarios y coordenadas geográficas.
  2. **El Manifiesto de Pasajeros:** La lista de turistas (folios), nombres (si ya se registraron) y, críticamente, sus *Etiquetas de Riesgo Médico* (alergias, condiciones).
  3. **Reglas Operativas:** Los metros de alejamiento máximo y tiempos de tolerancia configurados por la agencia.
* **Y** al llegar al 100%, me redirige al "Dashboard del Guía" listo para operar.

#### Escenario C: Supervivencia Offline (Sesión Cacheada)
* **Dado que** inicié sesión y sincronicé el viaje anteriormente,
* **Cuando** no tengo datos móviles y abro la aplicación,
* **Entonces** la app NO me pide correo ni contraseña.
* **Y** lee instantáneamente la base de datos local, mostrándome el itinerario y la lista de pasajeros con un banner superior amarillo que dice: *"Modo Offline: Mostrando datos sincronizados a las 22:00 hrs"*.

#### Escenario D: Recepción del "Kill Switch" (Bloqueo Remoto)
* **Dado que** la sesión está activa y el teléfono está conectado a la red,
* **Cuando** la Agencia ejecuta el protocolo de robo/extravío presionando "Revocar Dispositivo",
* **Entonces** la app recibe una notificación Push silenciosa.
* **Y** sin importar en qué pantalla me encuentre, la app ejecuta un `clear()` de la base local, borra el JWT del almacenamiento seguro y me expulsa a la pantalla de Login.
---

### 3. Diseño y UX

* **Indicador Permanente de Conectividad:** La app del guía debe tener un ícono en todo momento. Para saber, si hay conexión al WebSocket del servidor o si está operando con la base de datos local por falta de señal.
* **Biometría (Opcional pero recomendada):** Para agilizar el Escenario A en el día a día, ofrecer el inicio de sesión con FaceID (iOS) o Huella Dactilar (Android) usando el paquete `local_auth`.

---

### 4. Notas Técnicas

> [!IMPORTANT]  
> **Seguridad de Almacenamiento Local:** Los Tokens JWT deben guardarse OBLIGATORIAMENTE usando `flutter_secure_storage` (Keychain en iOS, Keystore en Android). Nunca en *SharedPreferences* de texto plano.

* **Manejo de Tokens y Refresh:**
  - Implementar interceptores (`InterceptorsWrapper` en Dio/http). Si una petición al backend falla con un `HTTP 401 Unauthorized` por token expirado, la app debe intentar usar el `Refresh Token` de forma silenciosa antes de expulsar al guía al login.

[⬆️ Volver al Índice](#indice)


<a name="guia-us02"></a>
## GUIA-US02: Pase de Lista Digital y Control de Acceso
**ÉPICA: App Guía (Móvil)**

### 1. Valor de Negocio

**Como** Guía de Turistas
**Quiero** visualizar la lista de pasajeros, registrar su asistencia al abordar, consultar sus restricciones médicas (alergias/condiciones) y poder bloquear el acceso a la red de cualquier dispositivo comprometido de un turista.  
**Para** garantizar que nadie se quede atrás, anticiparme a emergencias de salud conociendo el perfil del grupo, y proteger la privacidad logística de todos aislando inmediatamente un teléfono robado o extraviado de un pasajero.  

---

### 2. Criterios de Aceptación

#### Escenario A: Pase de Lista Visual e Interactivo (Abordaje) [Pendiente de Confirmación]
* **Dado que** estoy en la pestaña de "Grupo" o "Pase de Lista",
* **Cuando** visualizo el manifiesto de pasajeros (pre-cargado desde la [GUIA-US01](#guia-us01)),
* **Entonces** veo una lista ordenada alfabéticamente con el nombre de cada turista.
* **Y** cada fila tiene un botón amplio (Check) para marcar la asistencia física ("A bordo") con un solo toque.
* **Y** la lista muestra un indicador visual del estado digital del pasajero: 
  - 🟢 *Conectado:* Ya activó su app móvil y su GPS está transmitiendo.
  - 🟡 *Folio Pendiente:* La agencia le creó el lugar, pero el turista aún no descarga la app ni quema su folio.

#### Escenario B: Visualización Crítica de Riesgos Médicos [Pendiente de Confirmación]
* **Dado que** estoy revisando la lista de pasajeros,
* **Cuando** un turista tiene información médica pre-cargada (Ej. "Alergia a la penicilina" o "Hipertensión"),
* **Entonces** su nombre en la lista muestra un ícono de alerta médica (Ej. una cruz roja o un escudo).
* **Y** al tocar su perfil, se despliega una tarjeta de emergencia detallando sus condiciones, tipo de sangre (si lo proporcionó) y el teléfono de su contacto de emergencia.
* **Y** esta información debe estar disponible 100% **Offline** leyendo directamente la base de datos local para emergencias en zonas sin señal.

#### Escenario C: El "Kill Switch" del Turista (Bloqueo de Dispositivo Robado)
* **Dado que** un turista físico se me acerca y reporta que le acaban de robar su celular en el mercado,
* **Cuando** abro el perfil de ese turista en mi App Guía y presiono la opción "Reportar Dispositivo Perdido / Revocar Acceso",
* **Entonces** el sistema me exige confirmar la acción para evitar bloqueos accidentales.
* **Y** al confirmar (si tengo datos móviles), la App Guía notifica al backend para invalidar el token (JWT) de ese turista, expulsándolo de la red de telemetría y del mapa táctico.
* **Y** visualmente en mi lista, el turista pasa a estado ⚫ *Desconectado/Bloqueado*, pero NO desaparece de mi lista física (porque la persona física sigue en mi tour y debo seguir pasándole lista a voz).

#### Escenario D: Sincronización Diferida (Pase de Lista Offline)
* **Dado que** estoy haciendo el pase de lista en un estacionamiento subterráneo (zona sin señal),
* **Cuando** marco a 15 personas como "A bordo",
* **Entonces** la App no muestra errores de conexión; guarda los cambios en la memoria local.
* **Y** en el momento en que el autobús sale a la calle y el teléfono recupera señal 4G, un proceso en segundo plano envía la asistencia al servidor para que el monitor de la Agencia lo vea reflejado en tiempo real.

---

### 3. Diseño y UX

* **Contadores Globales:** En la parte superior de la pantalla debe haber un contador muy grande: **"A bordo: 28 / 30"**.
* **UI del Kill Switch:** La opción de revocar el dispositivo del turista no debe ser un switch a la vista para evitar que el guía lo active por accidente.

---

### 4. Notas Técnicas

* **Gestión de la Cola de Sincronización (Sync Queue):**
  - Se debe implementar un patrón de "Cola de Tareas" local. Cuando ocurre el Escenario D, cada *Check* se encola. Si la app se cierra, al volver a abrirse debe procesar la cola pendiente hacia la API (`POST /trips/{id}/attendance`). 

* **Payload del Kill Switch (Backend):**
  - El endpoint de la API (`POST /trips/passengers/{id}/revoke`) debe hacer dos cosas: 
    1) Meter el ID del dispositivo del turista a la Lista Negra de Redis. 
    2) Emitir un evento de WebSocket `TOURIST_REVOKED` a la sala (Room) del viaje para que todos los demás dispositivos (Guías y Agencia) borren de su mapa el "punto" de ese turista y eviten confusiones.

[⬆️ Volver al Índice](#indice)


<a name="guia-us03"></a>
## GUIA-US03: Ejecución del Itinerario y Sincronización de Actualizaciones en Vivo
**ÉPICA: App Guía (Móvil)**

### 1. Valor de Negocio

**Como** Guía de Turistas Líder  
**Quiero** visualizar la línea de tiempo de mis actividades del día, marcar el avance logístico (Check-in/Check-out de cada hito) y recibir modificaciones en tiempo real desde la central.  
**Para** mantener el control de los tiempos del tour, enviar datos de puntualidad a la agencia para las métricas post-viaje, y estar sincronizado instantáneamente si la agencia tiene que cambiar la ruta por una emergencia climática o logística.  

---

### 2. Criterios de Aceptación

#### Escenario A: Visualización y Ejecución de la Línea de Tiempo (Timeline)
* **Dado que** estoy operando un viaje,
* **Cuando** ingreso a la pestaña "Itinerario",
* **Entonces** veo una lista vertical cronológica de las actividades (hitos) del día.
* **Y** el sistema me permite deslizar (Swipe) o presionar un botón grande para cambiar el estado de la actividad actual de `PROGRAMADO` a `EN_CURSO` (Iniciando la visita) y luego a `COMPLETADO` (Terminando la visita).
* **Y** visualmente, las actividades pasadas se bloquean y se tornan grises, resaltando automáticamente la siguiente actividad en la lista.

#### Escenario B: Recepción de "Live Updates" (Cambios de la Agencia)
* **Dado que** la Agencia ha modificado el itinerario desde su portal (AGEN-US10) debido a un imprevisto,
* **Cuando** mi dispositivo móvil tiene conexión a internet y está suscrito al WebSocket del viaje,
* **Entonces** la app recibe silenciosamente el payload con el parche (`ITINERARY_PATCH`).
* **Y** la base de datos local se actualiza instantáneamente sin que yo tenga que presionar "Refrescar".
* **Y** la app me muestra un Banner flotante no intrusivo (SnackBar): *"La Agencia ha actualizado la ruta: Cambio en Restaurante"*.
* **Y** en la línea de tiempo, el hito modificado o agregado muestra una etiqueta visual de "NUEVO" o "MODIFICADO" para llamar mi atención.

#### Escenario C: Resiliencia Offline en Transiciones de Estado
* **Dado que** acabamos de terminar el recorrido por una cueva (zona sin señal),
* **Cuando** marco la actividad de la cueva como `COMPLETADO`,
* **Entonces** el sistema NO me bloquea con un error de red.
* **Y** guarda la transición de estado con la marca de tiempo (Timestamp) exacta en la base de datos local, marcándola en la UI con un ícono de "Sincronización Pendiente" (Ej. una nubecita con una flecha).
* **Y** en cuanto recobra señal, el proceso en segundo plano envía este Timestamp a la Agencia para que sus métricas de puntualidad sean precisas.

#### Escenario D: Cambio Dinámico de Parámetros de Seguridad
* **Dado que** el itinerario dicta que hemos llegado a la actividad "Tiempo Libre en Mercado",
* **Cuando** marco esa actividad como `EN_CURSO`,
* **Entonces** la app lee localmente los parámetros de esa actividad específica (AGEN-US02).
* **Y** el motor de telemetría de mi teléfono (y el de los turistas) expande automáticamente el radio de la geocerca permitida y silencia las alertas menores sin que yo tenga que configurar nada manualmente.

---

### 3. Diseño y UX

* **Jerarquía Visual del Tiempo:** - **Pasado:** Texto atenuado.
  - **Presente (Activo):** Tarjeta expandida, borde resaltado, color vivo, mostrando información adicional.
  - **Futuro:** Tarjeta colapsada, color neutro.

---

### 4. Notas Técnicas

* **Manejo de Tiempos Absolutos (UTC):**
  - Todos los `timestamps` generados al marcar un hito como completado deben guardarse localmente y enviarse al servidor en formato **UTC (ISO 8601)**, ignorando la zona horaria del teléfono. Esto evita bugs críticos si el tour cruza zonas horarias.
* **Resolución de Conflictos (El Guía tiene la razón):**
  > [!NOTE]  
  > Si el guía marca un hito offline, y luego recobra la señal, el backend debe darle prioridad al `Timestamp` local del guía sobre una edición web paralela que haga la agencia. En operaciones turísticas el operador de campo tiene el registro verídico de a qué hora sucedió el evento en la vida real.
* **WebSockets y Notificaciones:**
  - El frontend en Flutter debe usar un `StreamBuilder` conectado a la base local. Cuando llega un evento de WebSocket, el backend inserta; esto disparará automáticamente la reactividad del `StreamBuilder` repintando la pantalla del itinerario.

[⬆️ Volver al Índice](#indice)


<a name="guia-us04"></a>
## GUIA-US04: Mapa Táctico, Radar de Proximidad y Clustering
**ÉPICA: App Guía (Móvil)**

### 1. Valor de Negocio

**Como** Guía de Turistas 
**Quiero** visualizar un "Radar" o Mapa Táctico centrado en mi posición actual que muestre la ubicación relativa de mis turistas agrupados, junto con los límites de la geocerca permitida.  
**Para** saber de un solo vistazo si tengo al grupo bajo control e identificar visualmente a quién se está rezagando antes de que ocurra una emergencia.

---

### 2. Criterios de Aceptación

#### Escenario A: Renderizado del Radar y la Geocerca Dinámica
* **Dado que** el viaje está `EN_CURSO` y accedo a la pestaña "Radar",
* **Cuando** la pantalla carga,
* **Entonces** el mapa se centra automáticamente en mi ubicación actual (marcada con una estrella o ícono de Líder).
* **Y** el mapa dibuja un círculo semitransparente a mi alrededor que representa el radio de la geocerca activa. Este círculo crece o se encoge dinámicamente según la actividad actual (GUIA-US03).

#### Escenario B: Clustering de Turistas Sanos (Optimización Cognitiva y de Batería)
* **Dado que** mis turistas están caminando junto a mí dentro de la geocerca,
* **Cuando** observo el mapa táctico,
* **Entonces** el sistema agrupa automáticamente a los turistas cercanos en un "Cluster" (Una burbuja verde que dice "30").
* **Y** al hacer zoom-in con los dedos, la burbuja se rompe en clústeres más pequeños (Ej. "15", "10", "5") hasta revelar los puntos individuales de los turistas.

#### Escenario C: Exclusión del Cluster por Anomalía (El Rezagado)
* **Dado que** el grupo avanza pero el turista "Carlos" se detiene a tomar fotos,
* **Cuando** Carlos se acerca peligrosamente al borde de la geocerca o la cruza,
* **Entonces** el motor lógico de la app separa a Carlos del Cluster principal inmediatamente, sin importar el nivel de zoom.
* **Y** el punto individual de Carlos se vuelve de color Naranja (Advertencia) o Rojo (Fuera de Geocerca) en el mapa, y la burbuja del cluster central disminuye a "29".
* **Y** al tocar el punto rojo de Carlos, se despliega una pequeña tarjeta con su nombre y un botón directo para "Llamar".

#### Escenario D: Degradación Honesta (Pausa de Telemetría)
* **Dado que** el grupo entra a una zona sin cobertura celular,
* **Cuando** la App Guía pierde la conexión al WebSocket por más de X minutos,
* **Entonces** el Mapa Táctico se torna en una escala de grises y muestra un banner rojo claro: "Sin Conexión: Radar Pausado. Mantenga contacto con el grupo."
* **Y** el sistema pausa temporalmente el cálculo de alertas de proximidad para no generar falsos positivos ni drenar la batería, reanudando todo automáticamente al recuperar la señal.

---

### 3. Diseño y UX

* **Estilo Cartográfico Minimalista:** El mapa base debe estar configurado sin Puntos de Interés (POIs) innecesarios. El fondo del mapa debe ser limpio para que los puntos verdes y rojos de los turistas resalten con máxima visibilidad bajo el sol.
* **Botón de Enfoque Rápido:** Debe existir un *Floating Action Button* en la esquina inferior derecha del mapa con el ícono de "Mira de Francotirador". Al pulsarlo, el mapa vuelve a centrarse en el guía y ajusta el zoom para que toda la geocerca quepa exactamente en la pantalla.

---

### 4. Notas Técnicas

* **El Algoritmo de Clustering (Rendimiento):**
  - Si usamos `flutter_map`, usar `flutter_map_marker_cluster`.
  > [!WARNING]  
  > **Regla Crítica de Exclusión:** En el método `build()` del clúster de Mapas, el desarrollador debe interceptar el listado de elementos. Si un turista tiene `status == 'ALERT'`, ese turista **debe ser excluido de la lógica de agrupamiento** y dibujarse siempre como un marcador superior (Z-Index alto) independiente e inquebrantable, sin importar el nivel de zoom.
* **El Motor de Distancia Local (Haversine Edge-Computing):**
  - Para ahorrar procesamiento en el servidor de la agencia, el teléfono del guía debe calcular la distancia `Guía <-> Turista` localmente usando la fórmula de *Haversine* con el paquete `geolocator` cada vez que el WebSocket le entrega una nueva posición del turista. Esto se conoce como Edge Computing (procesamiento en el borde).
* **Consumo de Batería (Location Settings):**
  - Configurar el stream del GPS del guía con un `distanceFilter` de 5 metros y un `timeLimit` estratégico. El guía no necesita precisión militar de centímetros si está caminando por una ciudad; forzar el GPS a actualizarse cada milisegundo drenaría la batería en 2 horas.

[⬆️ Volver al Índice](#indice)


<a name="guia-us05"></a>
## GUIA-US05: Recepción de Alertas, Triaje en Campo y Reporte Rápido a Central
**ÉPICA: App Guía (Móvil)**

### 1. Valor de Negocio

**Como** Guía de Turistas Líder  
**Quiero** ser notificado inmediatamente mediante alertas visuales y sonoras si un turista cruza la geocerca o presiona su botón de pánico, y poder enviar un reporte rápido (con notas de voz) a la agencia.  
**Para** interceptar problemas antes de que se conviertan en tragedias, evitar el uso del teclado en momentos de alto estrés, y escalar la situación al equipo de monitoreo logístico para recibir apoyo inmediato.  

---

### 2. Criterios de Aceptación

#### Escenario A: Interrupción y Alerta de Alto Impacto (El Aviso)
* **Dado que** la app está en primer plano (o en segundo plano),
* **Cuando** el motor lógico detecta una anomalía (Ej. Turista a >500m o Turista envía `ALERTA_PANICO`),
* **Entonces** el teléfono del guía emite un patrón de vibración prolongado (Haptic Feedback de emergencia) y un sonido.
* **Y** la pantalla muestra un panel con la siguiente información: Nombre, Distancia actual y el tipo de alerta (Ej. "🚨 Pánico Activado" o "⚠️ Fuera de Rango: 520m").

#### Escenario B: Triaje Rápido en Campo (Descarte o Escalación)
* **Dado que** he recibido una alerta en mi pantalla,
* **Cuando** localizo visualmente al turista y determino que fue un error (Ej. cruzó la calle equivocada y ya viene de regreso),
* **Entonces** puedo presionar un botón gris de **"Falsa Alarma / Resuelto"**.
* **Y** el sistema apaga la alerta local, regresa el punto del turista a color verde en el mapa, y registra en bitácora el evento cerrado.

#### Escenario C: El "Reporte Rápido" a la Agencia (Escalamiento sin Teclado)
* **Dado que** la alerta es real (Ej. un turista sufrió una lesión),
* **Cuando** decido escalar el incidente a la central, presiono el botón **"Reportar a Agencia"**.
* **Entonces** la UI me muestra una cuadrícula de 4 a 6 botones gigantes de categorización (Ej. 🏥 Médico, 🚶‍♂️ Extravío, 👮 Seguridad, 🚌 Logística).
* **Y** al seleccionar uno, aparece un botón de micrófono tipo "Push-to-Talk" (WhatsApp style).
* **Y** al mantener presionado, grabo una nota de voz breve que se transcribe a texto.
* **Y** al soltar el botón, el reporte completo (Categoría + Coordenadas + Audio + Transcripción a Texto) se envía inmediatamente a la Agencia, detonando la AGEN-US04.

#### Escenario D: Resiliencia del Reporte
* **Dado que** intento enviar el Reporte Rápido en una zona arqueológica sin señal,
* **Cuando** suelto el botón de micrófono,
* **Entonces** la app guarda el audio y el payload del incidente en la base de datos local.
* **Y** me muestra un banner amarillo: *"Sin conexión. El reporte se enviará automáticamente al recuperar la señal"*.
* **Y** el *Background Worker* encola el envío, garantizando que el mensaje de auxilio saldrá del teléfono en cuanto se detecte una red 3G/4G disponible.

---

### 3. Diseño y UX

* **Prioridad Visual y Táctil:** - En emergencias, las habilidades motoras finas del ser humano disminuyen. NO se deben usar botones pequeños, sliders complejos o teclados QWERTY para el Escenario C. Todo debe ser operable "con el pulgar y sin mirar fijamente".
* **Código de Colores Estricto:** - 🔴 **Rojo:** Alerta de Pánico (Iniciada por el turista).
  - 🟠 **Naranja:** Alerta de Proximidad (Calculada por el sistema, el turista quizás ni sabe que está lejos).
* **Reproducción de Audio Local:** Antes de enviar, si el guía desliza el dedo (Slide to cancel), la nota de voz se borra por si se equivocó al hablar.

---

### 4. Notas Técnicas

* **Compresión de Audio:**
  - Los archivos de audio grabados no deben ser `.wav` pesados. Deben comprimirse usando un codec como `AAC` u `Opus` (formato `.m4a` o `.ogg`). Un audio de 10 segundos no debe pesar más de 50 KB para asegurar que se pueda transmitir incluso si la conexión a internet de la zona arqueológica es apenas "Edge" (2G).
* **Payload del Incidente:**
  ```json
  {
    "trip_id": "uuid-viaje-123",
    "tourist_id": "uuid-carlos-456",
    "incident_type": "MEDICAL",
    "lat": 20.6843,
    "lng": -88.5678,
    "audio_payload": "base64_string_or_signed_url",
    "timestamp": "2024-05-20T14:35:00Z"
  }
  ```
  - Si se usa Base64 para el audio, limitarlo estrictamente a notas de voz de máximo 30 segundos. Para mayor escalabilidad, subir el archivo a un bucket (Ej. AWS S3 / Firebase Storage) y enviar solo la URL generada en el payload.

[⬆️ Volver al Índice](#indice)


<a name="guia-us06"></a>
## GUIA-US06: Megáfono Digital PTT y Chat de Agencia
**ÉPICA: App Guía (Móvil)**

### 1. Valor de Negocio

**Como** Guía de Turistas en campo  
**Quiero** contar con un sistema de comunicación que incluya un "Walkie-Talkie" (Push-To-Talk) para transmitir mensajes de voz masivos a todo mi grupo, y un chat directo con la central de la agencia.  
**Para** dar instrucciones claras en entornos ruidosos, asegurar que todos los turistas reciban avisos críticos simultáneamente, y coordinar la logística.  

---

### 2. Criterios de Aceptación

#### Escenario A: El Megáfono Digital (Broadcast al Grupo)
* **Dado que** estoy en la pestaña de "Comunicaciones" o usando el botón de megáfono,
* **Cuando** mantengo presionado el botón central de "Hablar al Grupo" (Push-To-Talk),
* **Entonces** la app comienza a grabar mi voz, mostrando un indicador visual de grabación y un límite de tiempo (Ej. Máximo 30 segundos).
* **Y** al soltar el botón, el mensaje de voz se comprime y se envía instantáneamente a todo el grupo de turistas asignados al viaje activo.
* **Y** recibo un indicador visual de confirmación: *"Mensaje enviado a 30 pasajeros"*.

#### Escenario B: Degraciación Honesta
* **Dado que** intento usar el Megáfono Digital en una cueva o zona arqueológica sin cobertura de datos (3G/4G),
* **Cuando** presiono el botón de "Hablar al Grupo",
* **Entonces** el sistema detecta la falta de conexión al WebSocket.
* **Y** la app NO me deja grabar en falso. En su lugar, el botón vibra en error, se torna gris, y muestra un aviso emergente: *"Sin conexión a internet: El megáfono digital está deshabilitado. Utilice instrucciones verbales directas."*

#### Escenario C: Chat de Soporte Logístico (1 a 1 con la Agencia)
* **Dado que** necesito pedir autorización para algún cambio de itinerario o avisar de un retraso por tráfico,
* **Cuando** abro la pestaña de "Chat con Central",
* **Entonces** accedo a una interfaz de chat bidireccional exclusiva entre mi dispositivo y el Operador de la Agencia (Vinculado a AGEN-US04).
* **Y** puedo enviar mensajes de texto y notas de voz cortas (que se transcriben a texto).
* **Y** si estoy sin señal, mis mensajes de texto muestran un ícono de "Reloj" (En espera), y se enviarán automáticamente en cuanto el teléfono recupere la conexión de red (Store and Forward).

#### Escenario D: Recepción de Notificaciones Prioritarias (Desde Agencia)
* **Dado que** tengo la app en segundo plano y el teléfono guardado,
* **Cuando** el operador de la Agencia me escribe un mensaje urgente en el Chat de Soporte,
* **Entonces** mi teléfono emite un tono de notificación único.
* **Y** recibo una Notificación Push que, al tocarla, abre directamente la pantalla de Chat con la Central, garantizando que no me pierda de instrucciones logísticas críticas.

#### Escenario E: Intervención Directa (Unicast Iniciado por el Guía) [Pendiente de Confirmación]
* **Dado que** observo en el Mapa que el turista "Carlos" se está quedando atrás (pero aún no cruza la geocerca),
* **Cuando** toco el avatar de Carlos en el mapa y selecciono el ícono de "Micrófono Directo",
* **Entonces** se abre un canal privado. Al mantener presionado el botón, le envío un audio exclusivo a Carlos (Ej. "Carlos, apura el paso por favor, ya vamos a entrar al museo").
* **Y** Carlos recibe el audio en su teléfono sin que el resto de los 29 turistas escuchen la corrección.
* **Y** (Regla Crítica) al recibir este mensaje directo del guía, la app de Carlos le "desbloquea" temporalmente el botón de micrófono para que pueda responderle al guía (Ej. "Voy corriendo, disculpa").

#### Escenario F: Canal de Emergencia (Unicast Iniciado por el Turista)
* **Dado que** el canal de voz hacia el guía está bloqueado por defecto para los turistas,
* **Cuando** un turista presiona el **Botón de Pánico** o el sistema detecta que **salió de la Geocerca** (Alerta Automática),
* **Entonces** la interfaz del turista cambia a "Modo Emergencia" y se le desbloquea un botón rojo gigante de "Hablar con el Guía".
* **Y** el turista puede enviar un mensaje de voz inmediato.
* **Y** el Guía recibe la alerta visual roja ([GUIA-US05](#guia-us05)) junto con el audio del turista reproduciéndose automáticamente.
* **Y** el Guía y el Turista pueden seguir intercambiando audios privados hasta que el Guía marque el incidente como `RESUELTO`, momento en el cual el micrófono del turista vuelve a bloquearse.

#### Escenario G: Canal de Radio Interno (Staff - Guía Líder ↔ Guía de Apoyo) [Pendiente de Confirmación]
* **Dado que** estoy operando un viaje que tiene asignado a un "Guía de Apoyo",
* **Cuando** accedo a la pestaña "Staff" o toco el avatar de mi compañero (marcado en color azul) en el Mapa Táctico,
* **Entonces** se habilita un botón de intercomunicador exclusivo (Ej. "Radio Staff").
* **Y** al enviar un mensaje de voz por este canal, el audio se transmite ÚNICAMENTE al dispositivo del Guía de Apoyo (y viceversa).
* **Y** los turistas NO tienen acceso, conocimiento, ni reciben notificaciones de este canal privado de coordinación operativa.

---

### 3. Diseño y UX

* **Botón "Lock-to-Talk" (Opcional):** Para mensajes largos, si el guía desliza el botón de micrófono hacia arriba, se bloquea la grabación para que no tenga que mantener el pulgar apretado en la pantalla.
* **Cancelación Rápida:** Si mientras mantiene presionado el botón PTT el guía se equivoca (Ej. estornuda o da una instrucción errónea), puede deslizar el dedo hacia la izquierda ("Slide to cancel") para descartar el audio instantáneamente.

---

### 4. Notas Técnicas

* **Arquitectura de Broadcast:**
  - Cuando el guía suelta el botón (Escenario A), el audio comprimido (`.aac` o `.opus`) se sube al backend y se distribuye de dos formas:
    1. A través de la sala (`Room`) de **Socket.io**, para que los turistas con la app abierta lo reproduzcan instantáneamente.
    2. A través de **Firebase Cloud Messaging (FCM)** con prioridad `high` (Payload Data), para despertar los teléfonos de los turistas que tienen la app en el bolsillo, forzando una notificación sonora que diga: *"📢 Nueva instrucción del guía"*.
* **Manejo del Audio en el Teléfono:**
  - Usar el paquete `record` para capturar el audio en baja tasa de bits (Bitrate) y evitar saturar los datos móviles.
  - Usar `audioplayers` o `just_audio` para reproducir las respuestas o notas de voz de la agencia.
* **Permisos Nativos:**
  - El primer día de uso, la App Guía debe solicitar el permiso nativo de `RECORD_AUDIO` en Android/iOS de forma explícita, explicando: *"OhtliAni necesita acceso al micrófono para que puedas usar el megáfono digital y comunicarte con tu grupo"*. Si se niega, los escenarios A y C se bloquean elegantemente.

[⬆️ Volver al Índice](#indice)


<a name="guia-us07"></a>
## GUIA-US07: Protocolo de Rescate Local (Re-vinculación de Turista) [Pendiente de Confirmación]
**ÉPICA: App Guía (Móvil)**

### 1. Valor de Negocio

**Como** Guía de Turistas Líder 
**Quiero** poder generar un Código QR de un solo uso (o un PIN dinámico) directamente en la pantalla de mi teléfono para un turista específico.  
**Para** re-vincular de forma inmediata a un pasajero que cambió de dispositivo, reinstaló la app o sufrió el robo de su equipo, sin necesidad de contactar a la central de la agencia ni depender de correos electrónicos de recuperación.  

---

### 2. Criterios de Aceptación

#### Escenario A: Generación del QR de Rescate
* **Dado que** un turista se acerca porque su teléfono original cayó al agua y ahora está usando el celular de un acompañante suyo,
* **Cuando** abro la lista de pasajeros, busco el perfil del turista y presiono **"Generar Acceso de Rescate"**,
* **Entonces** la App del Guía solicita un token temporal al backend (si hay red) o genera un token firmado criptográficamente con la llave local del guía (si están offline).
* **Y** la pantalla de mi teléfono eleva su brillo al 100% y muestra un Código QR grande.
* **Y** debajo del QR, se muestra un PIN numérico de 6 dígitos (Ej. `482-910`) como método alternativo, junto con un temporizador de expiración (Ej. 5 minutos).

#### Escenario B: Re-vinculación Exitosa (El Turista)
* **Dado que** el turista ha descargado la App OhtliAni en su nuevo dispositivo y está en la pantalla inicial (sin iniciar sesión),
* **Cuando** el turista presiona el botón **"Tengo un QR de mi Guía"** y escanea la pantalla de mi teléfono,
* **Entonces** su dispositivo consume el token de un solo uso.
* **Y** el backend autoriza el acceso, le inyecta un nuevo JWT a ese nuevo dispositivo, y vincula este nuevo hardware al identificador único del turista (`tourist_id`).
* **Y** el sistema invalida automáticamente cualquier sesión anterior que el turista tuviera en su teléfono viejo (completando el protocolo de seguridad si no se había usado el Kill Switch previo).

#### Escenario C: Contingencia de Hardware (Ingreso por PIN)
* **Dado que** la cámara del nuevo celular del turista está dañada o no enfoca bien el QR bajo el sol,
* **Cuando** el turista selecciona "Ingresar PIN manual" en su app,
* **Entonces** puede teclear el código de 6 dígitos que yo le dicto desde mi pantalla.
* **Y** el resultado de re-vinculación es exactamente el mismo que en el Escenario B.

#### Escenario D: Seguridad y Expiración (Prevención de Clonación)
* **Dado que** he generado el QR de rescate para el turista en un sitio público,
* **Cuando** pasan los 5 minutos del temporizador O si la app del turista escanea el código exitosamente,
* **Entonces** el código QR y el PIN se autodestruyen y se marcan como `BURNED` (Quemados) en la base de datos.
* **Y** si una persona malintencionada que tomó una foto del QR a lo lejos intenta usarlo después, el sistema rechazará la conexión con una advertencia de "Token Inválido o Expirado".

---

### 3. Diseño y UX

* **Control de Brillo Automático:** Al generar el QR, la app del guía debe forzar el brillo de la pantalla al máximo (usando el paquete `screen_brightness` en Flutter).

---

### 4. Notas Técnicas

* **Estructura del Payload (Deep Linking / QR):**
  - El QR generado debe ser una URL de enlace profundo (Deep Link) encriptada. 
  - Ejemplo: `ohtliani://rescue?tId=uuid-carlos&token=aB9x...&exp=1716223000`
  - Esto permite que, si en el futuro el turista escanea el QR con la cámara nativa de iOS/Android, el sistema operativo abra la app de OhtliAni automáticamente y procese el login.
* **Arquitectura de Rescate Offline (Criptografía Asimétrica):**
  - Si el guía y el turista están en una zona sin internet celular, el backend no puede generar el token.
  - **Solución Edge:** Durante la sincronización de madrugada ([GUIA-US01](#guia-us01)), el servidor le entrega a la App del Guía una llave privada temporal del viaje. El Guía genera el QR firmado localmente. El celular nuevo del turista lee el QR, confía en la firma, y guarda su estado en como `A_BORDO`. Al recuperar ambos la señal de internet, el celular del turista se autentica formalmente con el backend usando ese token firmado por el guía.
* **Limpieza de Sesiones (Backend):**
  - El endpoint `POST /auth/rescue/consume` debe hacer un *Revoke* implícito. Buscar si el `tourist_id` de Carlos tenía otro `device_id` activo, invalidar ese JWT viejo en Redis, y emitir un evento por WebSocket para actualizar el mapa del Guía (removiendo el punto fantasma del celular viejo de Carlos).

[⬆️ Volver al Índice](#indice)


<a name="guia-us08"></a>
## GUIA-US08: Control Avanzado del Itinerario (Gestión de Retrasos, Omisiones y Check-in)
**ÉPICA: App Guía (Móvil)**

### 1. Valor de Negocio

**Como** Guía de Turistas Líder  
**Quiero** poder registrar el inicio y fin de mis actividades reportando justificaciones si hay retrasos, y tener la capacidad de omitir paradas (Skip) si es necesario.  
**Para** proteger mis métricas de rendimiento documentando los imprevistos (tráfico, clima, impuntualidad de los clientes), y mantener a la agencia informada de la realidad operativa en campo sin tener que llamarles para dar explicaciones.  

---

### 2. Criterios de Aceptación

#### Escenario A: Check-in Puntual (El Happy Path)
* **Dado que** estoy frente al hito "Museo de Antropología" programado a las 10:00 AM,
* **Cuando** marco la actividad como `EN_CURSO` entre las 09:45 AM y las 10:15 AM (Ventana de tolerancia),
* **Entonces** el sistema registra el inicio exitoso sin hacer más preguntas.
* **Y** el hito se torna azul brillante en mi pantalla, mostrando el cronómetro del tiempo que tenemos asignado para esta parada.

#### Escenario B: Check-in con Retraso y Justificación
* **Dado que** llegamos al mismo museo a las 10:45 AM (Fuera de la ventana de tolerancia),
* **Cuando** deslizo para marcar la actividad como `EN_CURSO`,
* **Entonces** la app pausa la acción y despliega un Bottom Sheet preguntando: *"Registrando retraso de +45 min. ¿Cuál es el motivo principal?"*.
* **Y** me muestra una lista de botones de selección rápida: `[Tráfico/Accidente]`, `[Clima]`, `[Turistas Impuntuales]`, `[Retén/Autoridad]`, `[Otro]`.
* **Y** al seleccionar una opción, el sistema guarda la actividad como `EN_CURSO` y adjunta esta "Etiqueta de Justificación" al reporte que se envía a la Agencia.

#### Escenario C: Hitos Rígidos vs. Flexibles
* **Dado que** nos retrasamos 45 minutos (Escenario B) y el sistema recalcula los tiempos,
* **Cuando** el sistema evalúa la siguiente actividad en la lista,
* **Entonces** verifica la regla comercial de ese hito:
  - Si es **Flexible** (Ej. "Tiempo libre en plaza"): El sistema recorre el horario estimado (+45 min) silenciosamente.
  - Si es **Rígido** (`es_rigido = true`, Ej. "Vuelo de regreso" o "Cena Michelin"): El sistema NO recorre el horario. En su lugar, emite una advertencia visual bloqueante:

  > [!CAUTION]  
  > *"Atención: La siguiente actividad es RÍGIDA y no puede reprogramarse. Apresure el paso con el grupo"*.

#### Escenario D: Solicitud de Omisión de Actividades (Escalación a Central)
* **Dado que** está lloviendo a cántaros y es peligroso hacer una parada,
* **Cuando** selecciono esa actividad y presiono **"Solicitar Omisión"**,
* **Entonces** el sistema me exige seleccionar un motivo de Fuerza Mayor.
* **Y** la actividad NO se elimina de inmediato, sino que cambia su estado a `SOLICITUD_OMISION` (Color amarillo/espera).
* **Y** se dispara una Alerta Logística en el Dashboard de la Agencia notificando la solicitud (Vínculo temporal con **[AGEN-US04](agency_user_stories.md#agen-us04)**).
* **Y** solo cuando la Agencia hace clic en "Aprobar" desde su portal, la actividad cambia a estado `OMITIDO` (Tachado) en mi app y se notifica a los turistas para evitar confusiones. (Si la Agencia rechaza, el hito vuelve a estado normal con un mensaje del operador).

---

### 3. Diseño y UX

* **Contraste de Estados:** - `EN_CURSO` (Puntual): Cronómetro en Verde.
  - `EN_CURSO` (Con Retraso): Cronómetro en Naranja con un ícono de advertencia (⚠️).
  - `OMITIDO`: Texto tachado, para que el guía sepa visualmente que ese punto ya no forma parte del plan de hoy.

---

### 4. Notas Técnicas

* **Evolución del Modelo de Datos:** [Pendiente de Confirmación]
  - La tabla `actividad_instancias` debe enriquecerse gracias a esta historia. Necesitará columnas adicionales: `minutos_desviacion` (Integer, puede ser negativo si llegaron antes), `motivo_retraso_id` (Enum o Foreign Key al catálogo de motivos), y permitir el estado `OMITTED`.
* **Cálculo de Tolerancia Local:** [Pendiente de Confirmación]
  - La App móvil evaluará el retraso comparando la `hora_actual` contra la `hora_programada` usando un parámetro de `grace_period_minutes` descargado en la [GUIA-US01](#guia-us01).
* **Flujo WebSocket Bidireccional (Escenario D):**
  - Guía emite `REQUEST_OMIT_ACTIVITY` -> Backend actualiza DB a `SOLICITUD_OMISION` -> Backend avisa a Agencia (Dashboard).
  - Agencia emite `APPROVE_OMISSION` -> Backend actualiza DB a `OMITIDO` -> Backend emite `ITINERARY_PATCH` a Guía y Turistas.

[⬆️ Volver al Índice](#indice)


<a name="guia-us09"></a>
## GUIA-US09: Mi Perfil, Agenda de Viajes Futuros y Ajustes Locales
**ÉPICA: App Guía (Móvil)**

### 1. Valor de Negocio

**Como** Guía de Turistas  
**Quiero** consultar mi agenda de viajes asignados para los próximos días, gestionar la descarga de mapas offline con anticipación, y personalizar las preferencias de mi aplicación (idioma, modo oscuro).  
**Para** planificar mi semana laboral sin tener que llamar a la agencia para pedir mi itinerario, asegurar que mi teléfono esté preparado logísticamente (con datos descargados en Wi-Fi) antes de salir a campo, y adaptar la interfaz a las condiciones de luz extremas del turismo.  

---

### 2. Criterios de Aceptación

#### Escenario A: Visualización de la Agenda Semanal (Upcoming Trips)
* **Dado que** estoy en la pantalla de inicio (sin un viaje activo en curso) o en la pestaña "Mi Agenda",
* **Cuando** el sistema se conecta a internet,
* **Entonces** consulta al servidor y me muestra una lista cronológica de los viajes (`PROGRAMADO`) que la Agencia me ha asignado para los próximos 15 días.
* **Y** cada tarjeta de viaje futuro muestra: Fecha, Nombre del Tour, Hora de cita, Lugar de inicio y la cantidad de turistas registrados hasta el momento.

#### Escenario B: Pre-Descarga Logística Inteligente (Wi-Fi Fetch)
* **Dado que** veo que tengo un tour en la selva asignado para mañana a las 5:00 AM,
* **Cuando** selecciono ese viaje en mi agenda y presiono el botón **"Descargar Datos Offline"**,
* **Entonces** la app descarga todo el manifiesto de pasajeros, las reglas médicas y, lo más importante, los *Tiles* (cuadros) del mapa de la ruta en la memoria del dispositivo.
* **Y** me muestra un indicador de "Listo para Offline 🟢", garantizando que mañana de madrugada, aunque me quede sin saldo o sin internet, podré iniciar el viaje y pasar lista (Complemento de [GUIA-US01](#guia-us01)).

#### Escenario C: Personalización Visual y Operativa (Modo Sol / Noche)
* **Dado que** opero en diferentes horarios,
* **Cuando** ingreso a "Ajustes de App",
* **Entonces** puedo forzar el tema de la aplicación (Claro / Oscuro / Sistema). El Modo Claro (Alto Contraste) es crucial para ver la pantalla bajo el sol del mediodía, mientras que el Modo Oscuro evita deslumbrar al guía (y a los turistas) durante un "Tour de Leyendas Nocturnas".
* **Y** puedo cambiar el idioma de la interfaz de la app independientemente del idioma del sistema de mi teléfono.

#### Escenario D: Perfil y Cierre de Sesión Seguro
* **Dado que** mi jornada ha terminado o voy a cambiar de dispositivo,
* **Cuando** ingreso a "Mi Perfil",
* **Entonces** veo mi información (Solo lectura): Nombre, Agencia a la que pertenezco y mi calificación promedio de estrellas (calculada desde las reseñas de los turistas).
* **Y** puedo presionar "Cerrar Sesión", lo cual purga todos mis datos locales, borra mis mapas cacheados para liberar espacio, y destruye mi token JWT en el Secure Storage.

---

### 3. Diseño y UX

* **El "Empty State" (Estado Vacío):** Si el guía no tiene viajes asignados para hoy, la pantalla principal no debe ser un mapa vacío o un error. Debe ser una pantalla de "Día Libre" amigable, que lo invite a revisar su pestaña de "Agenda" para ver sus próximos compromisos.
* **Gestión de Almacenamiento:** En los ajustes, debe haber una barra visual indicando cuánto espacio ocupan los "Mapas Offline" en el celular, con un botón grande para "Limpiar caché de viajes pasados" y evitar llenar la memoria del teléfono del guía.

---

### 4. Notas Técnicas

* **Consumo de API (Agenda):**
  - El backend solo debe retornar viajes con estado `PROGRAMADO` donde este usuario sea `GUIA_LIDER` o `GUIA_APOYO`.
* **Motor de Caché de Mapas:**
  - Para implementar el Escenario B, el desarrollador debe utilizar el gestor de caché de `flutter_map` (ej. `flutter_map_tile_caching`).
  - Calcular el *Bounding Box* (Caja delimitadora) de todas las coordenadas del itinerario futuro, y descargar recursivamente los mosaicos (tiles) de zoom nivel 10 al 18 dentro de esa caja.
* **Estado Global:**
  - Las preferencias de Tema (Claro/Oscuro) y el Idioma deben guardarse en `SharedPreferences` (estas no son sensibles, no necesitan `SecureStorage`) y aplicarse instantáneamente en toda la app usando el gestor de estado.

[⬆️ Volver al Índice](#indice)


<a name="guia-us10"></a>
## GUIA-US10: Cierre de Viaje, Sincronización Final y Apagado Legal del GPS
**ÉPICA: App Guía (Móvil)**

### 1. Valor de Negocio

**Como** Guía de Turistas Líder  
**Quiero** finalizar formalmente el viaje en el sistema una vez que he dejado a todos los turistas en el punto de retorno.  
**Para** enviar el reporte final de asistencia e incidentes a la Agencia, liberar mi pantalla principal para mi próximo tour, y garantizar (arquitectónicamente) que el rastreo GPS de mi teléfono y el de todos mis turistas se apague de inmediato, protegiendo nuestra privacidad y batería.  

---

### 2. Criterios de Aceptación

#### Escenario A: Validación de Cierre (Prevención de Errores)
* **Dado que** el viaje sigue en estado `EN_CURSO`,
* **Cuando** presiono el botón **"Finalizar Viaje de Hoy"**,
* **Entonces** el sistema valida si he marcado el último hito del itinerario como `COMPLETADO`.
* **Y** si aún hay hitos pendientes, la app me muestra una advertencia: *"Aún tienes actividades marcadas como 'En Curso' o pendientes. ¿Estás seguro de que deseas forzar el final del viaje?"*.
* **Y** el sistema me exige una confirmación de seguridad (Ej. deslizar un botón de lado a lado "Slide to End Tour") para evitar cierres accidentales en el bolsillo.

#### Escenario B: El "Kill Switch" Legal de Telemetría (Privacidad)
* **Dado que** he confirmado el cierre del viaje,
* **Cuando** la app cambia el estado del viaje localmente a `FINALIZADO`,
* **Entonces** el sistema operativo de mi móvil (Flutter a través de canales nativos) **detiene y destruye** el Servicio en Segundo Plano (Foreground/Background Task) que lee el hardware del GPS.
* **Y** la notificación fija en mi barra de estado (Ej. "OhtliAni está usando tu ubicación") desaparece instantáneamente.
* **Y** mi dispositivo se desconecta de la sala de telemetría de WebSockets.

#### Escenario C: Sincronización de Bitácora (El Cierre de Caja)
* **Dado que** el GPS ya se apagó y el viaje terminó,
* **Cuando** la app tiene conexión a internet,
* **Entonces** el *Background Worker* empaca todas las justificaciones de retrasos ([GUIA-US08](#guia-us08)), las asistencias offline ([GUIA-US02](#guia-us02)) y los incidentes locales en un payload final (Sync Batch).
* **Y** lo envía al servidor de NestJS.
* **Y** al recibir el `HTTP 200 OK` del servidor, mi base de datos local borra permanentemente los datos médicos de los turistas de mi teléfono celular (por leyes de protección de datos como GDPR/HIPAA).

#### Escenario D: Pantalla de Resumen (Feedback del Día)
* **Dado que** el proceso de sincronización terminó exitosamente,
* **Cuando** la pantalla de cierre desaparece,
* **Entonces** veo un modal de "¡Buen trabajo!"
* **Y** al cerrar este modal, regreso a mi pantalla de inicio vacía o a mi Agenda ([GUIA-US09](#guia-us09)), listo para mi siguiente asignación.

---

### 3. Diseño y UX

* **La Acción Destructiva de Cierre:** El botón de "Finalizar Viaje" no debe ser un botón de toque simple. Usar un componente de `SwipeableButton` (deslizar para confirmar). El cierre prematuro arruina la telemetría del día, debe ser una acción cognitiva deliberada.
* **Transparencia en la Privacidad:** Es buena práctica de UX mostrar un mensaje verde durante unos segundos tras el cierre: *"Rastreo GPS finalizado. Tu ubicación ya no está siendo compartida."* Esto da paz mental tanto al guía como al turista.

---

### 4. Notas Técnicas

* **El Payload del "Kill Switch" (Turistas):**
  - Al recibir la petición `POST /trips/{id}/finish` del Guía Líder, el backend (Node.js) debe hacer dos cosas críticas:
    1. Borrar todas las coordenadas en caché de este viaje en Redis (`DEL trip:{id}:locations`).
    2. Emitir un WebSocket/Push a las apps de los Turistas con el comando `FORCE_STOP_TRACKING`.
    
    > [!CAUTION]  
    > Aunque el turista nunca abra su app al llegar a su hotel, su teléfono obedecerá la orden remota de matar el proceso del GPS en segundo plano inmediatamente. Esto previene ilegalidades de rastreo post-viaje y protege la batería personal del turista para que OhtliAni la consuma por error.
* **Limpieza de Datos Sensibles:**
  - Una vez confirmado el cierre (Escenario C), el desarrollador móvil debe hacer un `db.pasajerosLocales.clear()`. Un guía NO debe retener en su dispositivo personal información.

[⬆️ Volver al Índice](#indice)

---

<a name="glosario"></a>
## Glosario de Términos

* **Offline-First:** Arquitectura de priorización móvil en la que la aplicación interactúa de forma primaria con una base de datos local instalada, en lugar de contactar primero al backend. Asume falta de red constante, y encola la sincronización en segundo plano solo a detectar Wi-Fi / LTE / 5G.
* **Geocerca (Geo-fence):** Un perímetro de seguridad virtual alrededor del guía o del punto de reunión. Quien traspase su límite activa la telemetría excepcional.
* **Kill Switch:** Orden de ejecución destructiva para revocar control a móviles comprometidos. En turistas desactiva tracking por completo y mata su acceso. En Guías, purga todos los datos offline del tour para que si le roban el celular en un asalto, los ladrones no expongan ni vendan la información de las personas (los turistas).
* **Botones PTT (Push To Talk):** Paradigma de interfaz que activa el "Walkie-talkie", grabando el micrófono SÓLO mientras el usuario aplaste su dedo en un área central. Esto minimiza reportar y mandar por accidente audios vacíos.
* **Deep Link:** URL incrustada en un QR (Ej. `ohtliani://rescue?id=X`) o Mensaje que elude el navegador; abriéndose de lleno sobre nuestra App. Útil para re-vincular de regreso a un turista al circuito si pierde su hardware logrando esquivar su login tradicional.

[⬆️ Volver al Índice](#indice)