# External Integrations

**Analysis Date:** 2026-08-22

## APIs & External Services

**Photo Search:**
- **Pexels API** - Stock photo search
  - SDK/Client: `http` package + custom `PexelsService`
  - Location: `frontend/lib/core/services/pexels_service.dart`
  - Auth: `PEXELS_API_KEY` environment variable
  - Usage: Trip itinerary creation (Agencia app) to find trip-related photos

**Location & Maps:**
- **Google Maps API** - Interactive map display
  - SDK/Client: `google_maps_flutter` 2.14.0
  - Location: `frontend/lib/features/turista/home/presentation/screens/mapa_itinerario_screen.dart`
  - Usage: Trip tracking map for Turista and Guía apps
  - Key feature: Real-time location markers, zooming, rotation

- **Google ML Kit** - Optical character recognition (OCR)
  - SDK/Client: `google_mlkit_text_recognition` 0.11.0
  - Location: `frontend/lib/core/tools/presentation/screens/currency_converter_screen.dart`
  - Usage: Text recognition from camera (currency converter tool)

- **OpenStreetMap** - Free map tiles
  - SDK/Client: `flutter_map` 8.2.2
  - Tile URLs: `https://tile.openstreetmap.org/{z}/{x}/{y}.png`
  - Alternative: CartoDB tiles `https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png`
  - Location: `frontend/lib/features/agencia/trips/presentation/widgets/trip_detail/trip_map_viewer.dart`
  - Usage: Trip route display and planning in Agencia app

- **Nominatim API** - OpenStreetMap geocoding
  - SDK/Client: `http` package
  - Base URL: `https://nominatim.openstreetmap.org/search`
  - Location: `frontend/lib/features/agencia/trips/presentation/widgets/itinerary_builder/location_picker_modal.dart`
  - Usage: Location name to coordinates conversion (itinerary builder)

**Device GPS:**
- **Geolocator** - Device location services
  - SDK/Client: `geolocator` 10.0.0
  - Location: `frontend/lib/core/services/location_service.dart`
  - Permissions: Requires location permission from OS
  - Features: High-precision GPS, 5-second timeout to avoid blocking SOS protocol
  - Usage: Real-time location for guide tracking (Walkie Talkie SOS feature)

## Data Storage

**Local Storage:**
- **SharedPreferences** - Key-value storage on device
  - Package: `shared_preferences` 2.5.3
  - Purpose: Theme settings, session data, user preferences
  - Locations:
    - `frontend/lib/main_turista.dart` - Turista app initialization
    - `frontend/lib/main_guia.dart` - Guía app initialization
    - `frontend/lib/features/guia/settings/presentation/cubit/guia_theme_cubit.dart` - Theme persistence

**Backend Storage (Planned - Not Implemented):**
- **PostgreSQL with PostGIS** - Geographic database
  - Type: Relational database with spatial extensions
  - Deployment: Docker container (development), managed cloud (production)
  - Status: Planned, not yet built
  - Purpose: Store trip data, guide locations, tourist locations; GIS queries for proximity searches
  - Documentation: `docs/05-ARQUITECTURA_BACKEND.md`

**File Storage:**
- No cloud file storage currently implemented
- Local device file system used for:
  - Camera uploads (temporary, via `image_picker` 1.0.4)
  - CSV export/import (via `csv` 6.0.0)
  - PDF generation (via `pdf` 3.11.3)

## Authentication & Identity

**Status:** Not yet implemented

**Planned Approach:**
- Custom implementation (not Firebase, Auth0, or Cognito)
- Backend will handle JWT or session-based auth (planned REST API)
- Frontend will store session in SharedPreferences
- Each app (Turista, Guía, Agencia) will have separate auth flows

**Current State:**
- Auth layers exist but are wired to mock data sources (`auth_local_data_source.dart`)
- No backend API authentication yet (Socket.IO server is unauthenticated)

## Real-Time Communication

**Socket.IO 4.8.0:**
- Server: `backend/demo-server/server.js`
- Port: 3000 (local dev), production via Railway
- Deployment: `https://othliani-production.up.railway.app`
- Client: `socket_io_client` 2.0.3 (Dart package)

**Implemented Features:**
- Join trip channels (trip rooms)
- Tourist panic button event broadcasting (`turista_panico`)
- Guide voice channel requests (`solicitarCanal`)
- Audio stream relay (`audioStream`)
- Channel state management (`estadoCanal`)

**Client Locations:**
- Walkie Talkie voice communication: `frontend/lib/features/turista/home/presentation/widgets/walkie_talkie_button.dart`
- Location sharing: `frontend/lib/features/turista/home/presentation/screens/trip_home_screen.dart`
- Guide management: `frontend/lib/features/guia/home/presentation/screens/pantalla_gestion_cambios.dart`

**Demo Configuration:**
- Demo trip ID: `demo-trip-cancun-2026`
- Demo tourist name: `Ana Martínez`
- Demo panic channel: `demo-direct-guia-ana`

## HTTP Client Configuration

**Dio HTTP Client:**
- Base URL: `http://10.170.6.0:3000` (development)
- Location: `frontend/lib/core/network/dio_client.dart`
- Features:
  - Request/response logging (interceptors)
  - 15-second connection timeout
  - 15-second receive timeout
  - Automatic JSON content-type headers

**Current Usage:**
- Currently connects to local dev server (no backend API yet)
- Wired in data sources but no actual endpoints available
- Will serve as primary HTTP layer for planned REST API

## Monitoring & Observability

**Error Tracking:**
- None detected (not implemented)

**Logs:**
- Console logging via `debugPrint()` throughout codebase
- Dio interceptor logs HTTP requests/responses
- Socket.IO server logs connection events and messages
- Location: `backend/demo-server/server.js` includes console.log for debugging

**Example log statements:**
- Pexels service: `debugPrint("📸 URL de Pexels encontrada: ...")`
- Socket.IO: `console.log('[+] ${socket.id} conectado')`

## CI/CD & Deployment

**Hosting:**
- Frontend: Deployed to iOS/Android app stores (not yet live)
- Backend: Railway (`https://othliani-production.up.railway.app`)

**CI Pipeline:**
- Not detected (not currently configured)
- Git workflow: Traditional PR-based with manual deployment

**Infrastructure:**
- Demo mode URL: `kDemoServerUrl = 'https://othliani-production.up.railway.app'`
- Environment: `kDemoMode` flag controls server selection

## Environment Configuration

**Required Environment Variables:**

| Variable | Purpose | Used By |
|----------|---------|---------|
| `PEXELS_API_KEY` | Pexels photo API authentication | `frontend/lib/core/services/pexels_service.dart` |
| `PORT` | Backend server port (default 3000) | `backend/demo-server/server.js` |

**Configurable Constants:**

| Constant | Location | Purpose |
|----------|----------|---------|
| `kDemoMode` | `frontend/lib/core/demo/demo_config.dart` | Enable demo mode (true = use Railway URL, false = use local dev) |
| `kDemoServerUrl` | `frontend/lib/core/demo/demo_config.dart` | Production backend URL (Railway deployment) |
| `kDemoTripId` | `frontend/lib/core/demo/demo_config.dart` | Shared demo trip ID between apps |
| `baseUrl` (Dio) | `frontend/lib/core/network/dio_client.dart` | HTTP client base URL |

**Secrets Location:**
- `.env` file (git-ignored, not committed)
- Loaded via `flutter_dotenv` at startup
- Never committed to repository

## Webhooks & Callbacks

**Incoming:**
- Not implemented

**Outgoing:**
- Not implemented

## Third-Party Service Dependencies

**Summary by Feature:**

| Feature | Service | Status |
|---------|---------|--------|
| Trip photos | Pexels API | Active |
| Interactive maps | Google Maps API | Active |
| Free map tiles | OpenStreetMap/CartoDB | Active |
| Location search | Nominatim API | Active |
| OCR/text recognition | Google ML Kit | Active |
| GPS location | Device native | Active |
| Real-time voice/chat | Socket.IO (custom server) | Active (demo) |
| User authentication | Not implemented | Planned |
| Structured data storage | PostgreSQL/PostGIS | Planned |
| Error tracking | Not implemented | Future |
| Analytics | Not implemented | Future |

---

*Integration audit: 2026-08-22*
