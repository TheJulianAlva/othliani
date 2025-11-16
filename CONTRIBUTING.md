# Flujo de Trabajo en Git (Git Workflow)

Para evitar el caos y asegurar la calidad del código, todo el equipo debe seguir este flujo de trabajo. Está basado en **Pull Requests (PRs)**.

## Las Reglas de Oro

1.  La rama `main` está **protegida**. Nadie puede hacer `push` directamente a `main`.
2.  Todo el trabajo (nuevas funcionalidades, corrección de bugs) **debe** hacerse en una rama separada.
3.  Todo el código **debe** ser revisado y aprobado por al menos **un (1)** otro miembro del equipo antes de ser fusionado (merged) a `main`.

## El Proceso de Contribución (Paso a Paso)

Este es el ciclo de vida de tu trabajo. Puedes usar la terminal (para poder) o la GUI de VS Code (para velocidad).

### 1. Sincronizar tu Repositorio Local
Antes de empezar a programar, asegúrate de tener la última versión del código.

* **Vía Terminal:**
    ```bash
    git checkout main
    git pull origin main
    ```
* **Vía VS Code (GUI):**
    1.  Haz clic en el nombre de la rama actual en la esquina inferior izquierda (ej. `main`).
    2.  Selecciona `main` de la lista para asegurar que estás en ella.
    3.  Haz clic en el botón **"Sincronizar Cambios"** (el icono de nube o flechas circulares) en la barra de estado inferior. Esto hace `pull` y `push` (si tuvieras commits locales, pero no deberías en `main`).

### 2. Crear tu Rama de Trabajo (Feature Branch)
Crea una nueva rama para tu tarea. Nómbrala de forma descriptiva.

**Prefijos:** `feature/`, `bugfix/`, `docs/`.

* **Vía Terminal:**
    ```bash
    # Crea y muévete a tu nueva rama
    git checkout -b feature/auth-login-screen
    ```
* **Vía VS Code (GUI):**
    1.  Haz clic en el nombre de la rama (`main`) en la esquina inferior izquierda.
    2.  En el menú superior, selecciona `+ Crear nueva rama...`.
    3.  Escribe el nombre de tu nueva rama (ej. `feature/auth-login-screen`) y presiona Enter.

### 3. Trabajar y Hacer Commits
Trabaja en tu código. Haz "commits" pequeños y frecuentes con buenos mensajes.

* **Vía Terminal:**
    ```bash
    git add .
    git commit -m "feat: Implementa la pantalla de login para Turista"
    ```
* **Vía VS Code (GUI):**
    1.  Abre el panel de **Control de Código Fuente** (el icono de las tres ramas).
    2.  Los archivos modificados aparecerán en "Cambios".
    3.  Haz clic en el **icono `+`** junto a cada archivo para "prepararlo" (Stage Changes), o en el `+` junto a "Cambios" para prepararlos todos.
    4.  Escribe tu mensaje de commit (ej. `feat: Implementa la pantalla de login`) en el cuadro de texto superior.
    5.  Presiona el **icono de check (✓)** o `Ctrl+Enter` para hacer el commit.

### 4. Subir tu Rama a GitHub
Cuando tu trabajo esté listo para ser revisado (o al final del día), sube tu rama al repositorio remoto.

* **Vía Terminal:**
    ```bash
    git push -u origin feature/auth-login-screen
    ```
* **Vía VS Code (GUI):**
    * La primera vez que hagas commit en una rama nueva, verás un botón que dice **"Publicar Rama"** (Publish Branch) en el panel de Control de Código Fuente. Haz clic en él.
    * Si la rama ya existe en el remoto, el botón "Sincronizar Cambios" subirá tus commits.

### 5. Crear el Pull Request (PR)
* **Vía GitHub.com (Recomendado):**
    1.  Ve a la página del repositorio en GitHub.
    2.  Verás un botón amarillo para "Compare & pull request". Haz clic.
    3.  **Título:** Coloca un título descriptivo.
    4.  **Descripción:** Explica *qué*, *por qué* y *cómo* probarlo.
    5.  **Revisores:** Asigna al menos a un miembro del equipo.
* **Vía VS Code (GUI):**
    1.  Después de "Publicar Rama", VS Code usualmente te mostrará una notificación emergente con un botón para **"Crear Pull Request"**.
    2.  Alternativamente, puedes ir al panel de **"GitHub Pull Requests and Issues"** (instalado con las extensiones de GitHub), encontrar tu rama y hacer clic en el icono de crear PR.


### 6. Revisión de Pares (Code Review)
* **Como Revisor (Vía VS Code):**
    1.  Abre el panel "GitHub Pull Requests and Issues".
    2.  Busca el PR, haz clic en "Revisar".
    3.  Puedes ver todos los archivos cambiados, dejar comentarios en líneas específicas y, finalmente, "Aprobar" (Approve) directamente desde VS Code.
* **Como Autor:** Atiende los comentarios, haz los cambios (paso 3) y sube tus nuevos commits (paso 4). El PR se actualizará automáticamente.

### 7. Fusionar (Merge) y Limpiar
* **Fusionar (Merge):** Esto se hace mejor en **GitHub.com** para usar el botón **"Squash and merge"**. Esto mantiene nuestro historial de `main` limpio.
* **Limpiar (Vía VS Code):**
    1.  Haz clic en el nombre de tu rama (ej. `feature/auth-login-screen`) en la esquina inferior.
    2.  Selecciona `main` para cambiar a ella.
    3.  Haz clic en **"Sincronizar Cambios"** (las flechas circulares) para bajar el código que acabas de fusionar.
    4.  (Opcional) Haz clic en el nombre de la rama (`main`) de nuevo, busca tu rama `feature/...` en la lista, y haz clic en el icono de la papelera a su lado para borrarla de tu local.
