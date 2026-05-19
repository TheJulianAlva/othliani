# Guía de Demo en Vivo — Veltur

## Estado de implementación

| Fase | Descripción | Estado |
|---|---|---|
| Fase 1 | Auth bypass + datos mock + demo_config | ✅ Completada |
| Fase 2 | Servidor Railway + Socket.IO service | ⏳ Pendiente |
| Fase 3 | Pánico, walkie-talkie, trigger respaldo | ⏳ Pendiente |
| Fase 4 | Documentación y ensayos | ⏳ Pendiente |

---

## Cómo levantar las apps (Fase 1 lista)

```bash
# App Turista (Dispositivo A)
cd frontend
flutter run -t lib/main_turista.dart

# App Guía (Dispositivo B)
cd frontend
flutter run -t lib/main_guia.dart
```

Ambas apps arrancan directamente en su pantalla principal, sin login ni folio.

---

## Activar / desactivar el modo demo

Editar `frontend/lib/core/demo/demo_config.dart`:

```dart
const bool kDemoMode = true;   // Demo activo
const bool kDemoMode = false;  // Comportamiento normal de producción
```

---

## Instrucciones para crear el entorno en Railway (Fase 2)

### Requisitos previos
- Cuenta en [railway.app](https://railway.app) (gratis con GitHub)
- El servidor está en `backend/demo-server/` (se crea en Fase 2)
- Tener acceso de administrador al repositorio de GitHub

### Pasos de deploy

1. **Iniciar sesión en Railway**
   - Ir a [railway.app](https://railway.app)
   - Hacer clic en **"Start a New Project"**
   - Seleccionar **"Deploy from GitHub repo"**
   - Autorizar el acceso a GitHub y seleccionar el repositorio `othliani`

2. **Configurar el root directory**
   - En la pantalla del proyecto, ir a **Settings → General**
   - En el campo **"Root Directory"** escribir: `backend/demo-server`
   - Railway detecta automáticamente que es Node.js y usa `npm start`

3. **Configurar el puerto**
   - Railway inyecta la variable `PORT` automáticamente
   - El servidor ya la usa: `process.env.PORT || 3000`
   - No es necesario configurar nada adicional

4. **Obtener la URL pública**
   - En el panel del proyecto, ir a **Settings → Networking**
   - Hacer clic en **"Generate Domain"**
   - Railway asigna una URL del tipo: `veltur-demo.up.railway.app`

5. **Actualizar `demo_config.dart`**
   - Copiar la URL generada por Railway
   - Editar `frontend/lib/core/demo/demo_config.dart`:
     ```dart
     const String kDemoServerUrl = 'https://TU-URL-AQUI.up.railway.app';
     ```

6. **Verificar que el servidor responde**
   - Abrir en el navegador: `https://TU-URL-AQUI.up.railway.app`
   - Debe responder (aunque sea vacío o con 404 — eso confirma que está corriendo)

### Verificación rápida de conectividad

Antes de la demo, abrir la URL del servidor en el navegador desde **los mismos datos móviles** que usarán los dispositivos. Si responde, la conexión está funcionando.

---

## Plan de contingencia

| Fallo | Acción inmediata |
|---|---|
| Servidor Railway no responde | Usar trigger manual oculto en App Guía (triple-tap, disponible en Fase 3) |
| Walkie-talkie no transmite | Reproducir audio pregrabado del mensaje del guía |
| App Turista no compila | Mostrar capturas de pantalla del Acto 1 en slides |
| App Guía no compila | El integrante lejano muestra capturas en su teléfono |
| Internet del evento inestable | Activar hotspot 4G personal en ambos dispositivos |
| App se cierra inesperadamente | Tener la app en segundo plano, swipe para regresar |

---

## Guión de la demo

### Introducción (1 min)
> "El 72% de los turistas se pierde en su destino. Las agencias hoy usan WhatsApp para coordinar — sin privacidad, sin emergencias, sin control. Veltur reemplaza eso con una sola app que conecta al turista y al guía en tiempo real."

### Acto 1 — Lo que Ana tiene en su bolsillo (3–4 min)
*[App Turista — Dispositivo A, frente a los jueces]*

1. Mostrar pantalla de inicio → **"Sin registros ni contraseñas. La agencia lo prepara todo."**
2. Abrir itinerario → **"Ana sabe exactamente qué sigue, a qué hora y dónde reunirse."**
3. Abrir traductor de voz → demostrar en vivo
4. Abrir conversor de divisas → apuntar cámara a un precio → OCR en acción
5. Abrir divisor de gastos → **"Todo lo que antes requería 4 apps, aquí integrado."**
6. Abrir mapa de seguridad → mostrar geocerca → **"Ana puede ver si se está alejando demasiado."**

### Acto 2 — Ana se aleja (2 min)
*[App Turista → App Guía]*

1. Navegar al botón de asistencia rápida
2. **"Para evitar activaciones accidentales, se requiere mantenerlo presionado 3 segundos"**
3. Activar → pantalla roja de emergencia
4. **"En ese momento, el guía recibe una alerta inmediata."**
5. *[Señal al integrante lejano]* → mostrar alerta en App Guía

### Acto 3 — El guía responde (2–3 min)
*[App Guía → App Turista, voz real entre dispositivos]*

1. El integrante lejano activa el walkie-talkie → graba: *"Ana, quédate donde estás, en dos minutos estoy contigo"*
2. *[Mostrar App Turista]* → el audio llega y se reproduce
3. **"Sin llamadas. Sin revelar números. Solo Veltur."**
4. El guía marca "Resuelto" → estado vuelve a normal

### Cierre (1 min)
> "Esto no es solo una app — es una red de seguridad invisible que protege al turista sin invadir su privacidad, y le da a las agencias control real sobre sus operaciones desde cualquier dispositivo."

---

## Checklist pre-demo (15 minutos antes)

- [ ] Servidor Railway activo — verificar abriendo la URL en el navegador
- [ ] App Turista instalada y abierta en la pantalla de itinerario
- [ ] App Guía instalada y abierta en la pantalla principal con la lista de turistas visible
- [ ] Ambos dispositivos con batería > 80%
- [ ] Ambos dispositivos con datos móviles propios activos (no depender solo del WiFi del evento)
- [ ] El integrante del equipo con App Guía conoce exactamente cuándo hablar (señal acordada)
- [ ] Audio de respaldo pregrabado listo en el teléfono del integrante lejano
- [ ] Capturas de pantalla del Acto 1 en slides listos como respaldo
