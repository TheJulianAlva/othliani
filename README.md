# OhtliAni

<p align="left">
  <img src="https://img.shields.io/badge/Flutter-3.7.0%2B-02569B?logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Windows%20%7C%20Web-blue" alt="Platform">
  <img src="https://img.shields.io/badge/License-Proprietary-red" alt="License">
  <img src="https://img.shields.io/badge/Status-In%20Development-yellow" alt="Status">
</p>

**Smart Management for Travel Safety & Logistics**

OhtliAni is a comprehensive ecosystem designed to revolutionize how travel agencies manage safety, logistics, and communication. It connects tourists, guides, and agency staff through a unified platform, ensuring safer and more organized travel experiences.

---

## 📋 Table of Contents

*   [Ecosystem](#-ecosystem)
*   [Key Features](#-key-features)
*   [Architecture](#-architecture)
*   [Getting Started](#-getting-started)
*   [Roadmap](#-roadmap)
*   [Contributing](#-contributing)
*   [License](#-license)

---

## 🚀 Ecosystem

The project consists of three integrated client applications and a central server, all managed within a single monorepository:

1.  **Tourist App (Mobile):** Empowering travelers with itinerary details, safety alerts, and real-time communication.
2.  **Guide App (Mobile):** Tools for guides to manage participants, track locations, and handle incidents efficiently.
3.  **Agency App (Desktop/Web):** A powerful administrative dashboard for staff to manage trips, users, and system configurations.

## ✨ Key Features

*   **Real-time Tracking:** Monitor group locations for enhanced safety.
*   **Incident Management:** Quick reporting and handling of emergencies.
*   **Itinerary Management:** Digital itineraries always available to tourists.
*   **Unified Communication:** Seamless connection between the agency, guides, and tourists.
*   **Offline Capabilities:** Essential features work even without internet access in remote areas.

## 🏗️ Architecture

OhtliAni is built using a **Clean Architecture** approach to ensure scalability, testability, and maintainability.

*   **Monorepo:** A single source of truth for all frontend and backend code.
*   **Shared Core:** The three Flutter applications share 100% of the **Domain** (Business Logic) and **Data** (Repository/API) layers, ensuring consistency across the platform. Only the Presentation layer (UI) is specific to each app.
*   **Tech Stack:**
    *   **Frontend:** Flutter (Dart)
    *   **State Management:** flutter_bloc
    *   **Routing:** go_router
    *   **Maps:** Google Maps & OpenStreetMap (flutter_map)
    *   **Backend:** Node.js (In Development)
    *   **Database:** PostGIS (In Development)

## 🛠️ Getting Started

Follow these instructions to set up the project locally.

### Prerequisites

*   [Flutter SDK](https://flutter.dev/docs/get-started/install) (latest stable version)
*   VS Code or Android Studio
*   Android Emulator or Physical Device

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/ohtliani-mvp.git
    cd ohtliani-mvp
    ```

2.  **Install dependencies:**
    Navigate to the frontend directory and fetch dependencies.
    ```bash
    cd frontend
    flutter pub get
    ```

### Running the Applications

Since this project contains multiple entry points, you must specify the target file when running.

*   **Run Tourist App:**
    ```bash
    flutter run -t lib/main_turista.dart
    ```

*   **Run Guide App:**
    ```bash
    flutter run -t lib/main_guia.dart
    ```

*   **Run Agency App:**
    ```bash
    flutter run -t lib/main_agencia.dart -d windows  # or macos/linux/chrome
    ```

## 🗺️ Roadmap

*   [x] MVP Frontend Interfaces (Tourist, Guide, Agency)
*   [x] Shared Domain & Data Layers
*   [ ] Backend API Implementation (Node.js)
*   [ ] Database Integration (PostGIS)
*   [ ] Real-time Socket Communication

## 🤝 Contributing

This is a collaborative project. Please refer to the [Contributing Guidelines](CONTRIBUTING.md) and follow the coding standards outlined in the `docs/` folder before submitting Pull Requests.

## 📄 License

**Copyright © 2024 OhtliAni. All Rights Reserved.**

This project is proprietary software. Unauthorized copying, modification, distribution, or use of this software, in whole or in part, is strictly prohibited.
