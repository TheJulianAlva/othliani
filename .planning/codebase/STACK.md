# Technology Stack

**Analysis Date:** 2026-08-22

## Languages

**Primary:**
- Dart 3.7+ - Flutter frontend (three mobile apps: Turista, Guía, Agencia)
- JavaScript (Node.js) - Backend server

**Tertiary:**
- Bash/Shell - Development scripts
- SQL - Planned database migrations (PostgreSQL/PostGIS)

## Runtime

**Environment:**
- Flutter SDK 3.38.1 (includes Dart 3.7+)
- Node.js 18+ (via NVM on development machines)

**Package Manager:**
- Dart Pub - Frontend dependency management
  - Lockfile: `frontend/pubspec.lock`
- npm - Backend dependency management
  - Lockfile: `backend/demo-server/package-lock.json` (if present)

## Frameworks

**Frontend:**
- Flutter - Cross-platform mobile UI framework
  - `flutter_bloc` 9.1.1 - State management (BLoC pattern)
  - `go_router` 14.6.0 - Navigation and routing
  - `google_maps_flutter` 2.14.0 - Map display (Turista, Guía apps)
  - `flutter_map` 8.2.2 - Alternative map display (Agencia app, OpenStreetMap tiles)

**Backend:**
- Socket.IO 4.8.0 - Real-time communication (currently only demo-server implemented)
- Express.js - Planned for REST API (not yet implemented, documented in architecture)

**Testing:**
- `flutter_test` - Flutter's built-in testing framework
- `bloc_test` 10.0.0 - BLoC testing utilities
- `mocktail` 1.0.4 - Mocking library for tests

**Build/Dev:**
- `flutter_gen` 5.12.0 - Code generation for assets and localization
- `flutter_launcher_icons` 0.14.4 - App icon generation

## Key Dependencies

**Critical for Architecture:**
- `dartz` 0.10.1 - Functional error handling (Either type for usecases)
- `equatable` 2.0.8 - Object equality comparison (for BLoC state comparison)
- `get_it` 9.2.0 - Service locator for dependency injection

**HTTP/Network:**
- `dio` 5.9.1 - HTTP client with interceptors, timeouts, logging
- `http` 1.1.0 - Standard HTTP client (used for Pexels API calls)
- `socket_io_client` 2.0.3 - Socket.IO client for real-time features (Walkie Talkie)

**Geolocation & Maps:**
- `geolocator` 10.1.0 - Device GPS location services
- `google_mlkit_text_recognition` 0.11.0 - OCR via Google ML Kit
- `latlong2` 0.9.1 - Latitude/longitude handling for maps
- `connectivity_plus` 6.1.0 - Network connectivity detection

**UI/Display:**
- `flutter_localizations` - Multi-language support (localized strings)
- `dropdown_search` 5.0.6 - Searchable dropdown widget
- `animated_bottom_navigation_bar` 1.3.3 - Custom navigation bar
- `emoji_picker_flutter` 3.1.0 - Emoji picker for chat/messages
- `country_picker` 2.0.26 - Country selection widget
- `mask_text_input_formatter` 2.9.0 - Input masking for phone numbers

**Local Storage & Preferences:**
- `shared_preferences` 2.5.3 - Key-value local storage (theme, session state)
- `flutter_dotenv` 6.0.0 - Environment variable loading from .env file

**Media & Files:**
- `camera` 0.10.5+5 - Camera access for photos
- `image_picker` 1.0.4 - Image/photo selection
- `file_picker` 8.0.0 - File selection from device
- `pdf` 3.11.3 - PDF generation
- `printing` 5.14.2 - Print document handling
- `path_provider` 2.1.5 - Device file system paths

**Audio/Voice Features:**
- `record` 6.2.0 - Audio recording
- `flutter_sound` 9.2.13 - Audio playback and recording
- `speech_to_text` 7.3.0 - Speech recognition (Walkie Talkie)
- `flutter_tts` 4.2.5 - Text-to-speech output

**Data Processing:**
- `csv` 6.0.0 - CSV parsing and generation (trip itinerary import/export)
- `intl` 0.20.2 - Internationalization and number/date formatting
- `uuid` 4.5.2 - UUID generation
- `translator` 1.0.4+1 - Text translation support
- `rxdart` 0.28.0 - Reactive extensions for Dart (event streams)

**Platform-Specific:**
- `permission_handler` 11.0.1 - Cross-platform permissions (camera, location, microphone)
- `window_manager` 0.5.1 - Window management (desktop support)

**Backend Dependencies:**
- `socket.io` 4.8.0 - Real-time event emitter (Node.js)

## Configuration

**Environment:**
- `.env` file for secrets (loaded via `flutter_dotenv`)
- Required env vars:
  - `PEXELS_API_KEY` - Pexels API key for photo search
- Configurable settings:
  - `kDemoMode` - Boolean flag for demo vs. production mode
  - `kDemoServerUrl` - Backend URL when in demo mode (Railway deployment)
  - `baseUrl` - Local backend URL during development (`http://10.170.6.0:3000`)

**Build:**
- `flutter pub get` - Install frontend dependencies
- `flutter pub upgrade` - Update frontend dependencies
- `npm install` - Install backend dependencies
- `flutter doctor` - Verify development environment setup

## Platform Requirements

**Development:**
- Windows, macOS, or Linux
- 8GB+ RAM recommended
- Git version control
- VS Code with Flutter/Dart extensions
- Android Studio (for Android SDK and emulator)
- Docker Desktop (planned for local PostgreSQL/PostGIS)

**Deployment Target:**
- iOS (via Flutter)
- Android (via Flutter)
- Backend: Node.js 18+ on Railway (production)

## Database (Planned - Not Yet Implemented)

**Technology:**
- PostgreSQL with PostGIS extension (planned for backend)
- Stored locally via Docker during development
- Not currently active; demo server uses in-memory Socket.IO only

**Note:** Architecture doc (`docs/05-ARQUITECTURA_BACKEND.md`) describes planned Express.js REST API with PostgreSQL/PostGIS, but only Socket.IO demo-server currently exists. Full backend implementation is a future phase.

---

*Stack analysis: 2026-08-22*
