# 02. Configuración del Entorno de Desarrollo (EDE)

## Filosofía de Estandarización

Para evitar el problema de "en mi máquina sí funciona", es **crítico** que los 4 miembros del equipo utilicemos las mismas herramientas y versiones.

Nuestra filosofía será:

* **Nativo para Velocidad:** Desarrollaremos Flutter y Node.js de forma nativa en nuestras PCs para aprovechar el *hot-reload*.
* **Docker para Consistencia:** Usaremos Docker *exclusivamente* para la base de datos, garantizando que todos tengamos la misma versión de PostGIS.

## Checklist de Instalación

Cada miembro del equipo debe instalar el siguiente software.

### 1. Herramientas Base (Todos)

* **Git:** El sistema de control de versiones. [Descargar Git](https://git-scm.com/downloads).
* **VS Code:** Nuestro editor de código (IDE). [Descargar VS Code](https://code.visualstudio.com/download).

### 2. Entorno Backend (Todos) (No es necesario aún)

* **Node.js (vía NVM):** No instales Node.js directamente. Usa un gestor de versiones:
    * **Mac/Linux:** Instalar [nvm](https://github.com/nvm-sh/nvm).
    * **Windows:** Instalar [nvm-windows](https://github.com/coreybutler/nvm-windows).
    * Una vez instalado NVM, ejecuta: `nvm install --lts` (esto instala la última versión de Soporte a Largo Plazo).
* **Docker Desktop:** El motor para nuestros contenedores. [Descargar Docker Desktop](https://www.docker.com/products/docker-desktop/).

### 3. Entorno Frontend (Todos)

* **Flutter SDK:** Sigue la guía oficial de [Instalación de Flutter](https://docs.flutter.dev/get-started/install) para tu sistema operativo (Windows/Mac/Linux). Esto instalará Dart automáticamente.
* **Android Studio:** No lo usaremos como IDE, pero es *necesario* para instalar el SDK de Android y el gestor de emuladores (AVD Manager). [Descargar Android Studio](https://developer.android.com/studio).

* **Extensiones de VS Code (¡Crítico!):** Para que el IDE entienda Flutter y nuestra arquitectura, instalen las siguientes extensiones desde el panel de Extensiones de VS Code:

    * `Dart` (Dart Code): Soporte oficial del lenguaje Dart (autocompletado, análisis de código).

    * `Flutter` (Flutter): Soporte oficial de Flutter (comandos de flutter doctor, hot-reload, gestión de dispositivos).

    * `Live Share`: Permite la programación en pares (pair programming) en tiempo real, cada uno desde su propio VS Code.

    * `REST Client`: Permite crear archivos `.http` para definir y ejecutar peticiones a nuestra API de Node.js.

    * **(Recomendado)** `Material Icon Theme` **o similar:** Mejora visual que añade iconos específicos a los archivos y carpetas.

    * **(Opcional)** `indent-rainbow`: Colorea las líneas de indentación. Extremadamente útil en Flutter para visualizar la anidación profunda de widgets.

## Validación del Entorno

1.  **Validar Flutter:** Abre una terminal y ejecuta:

    ```bash
    flutter doctor
    ```

    Este comando te dirá si algo falta. **No continúes hasta que `flutter doctor` muestre `Flutter`, `Android toolchain`, y `VS Code` en verde**


## *(No implementar aún)* Cómo Iniciar la Base de Datos Local

Gracias a Docker, este es el único comando que necesitarás para levantar tu base de datos PostGIS local. Ejecuta esto desde la raíz del repositorio:

```bash
# Inicia la base de datos en segundo plano (-d)
docker compose up -d
```

Tu base de datos PostGIS idéntica a la de tus compañeros estará corriendo en `localhost:5432`.
