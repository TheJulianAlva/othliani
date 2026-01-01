# Configuración de Google Maps API

## Pasos para obtener tu API Key

### 1. Crear un proyecto en Google Cloud Console

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Crea un nuevo proyecto o selecciona uno existente
3. Habilita la facturación (Google ofrece $300 de crédito gratis)

### 2. Habilitar las APIs necesarias

1. Ve a "APIs & Services" > "Library"
2. Busca y habilita:
   - **Maps SDK for Android**
   - **Maps SDK for iOS**
   - **Geolocation API**

### 3. Crear credenciales

1. Ve a "APIs & Services" > "Credentials"
2. Click en "Create Credentials" > "API Key"
3. Copia la API key generada

### 4. Configurar restricciones (Recomendado)

**Para Android:**

1. Edita tu API key
2. En "Application restrictions", selecciona "Android apps"
3. Agrega el nombre del paquete: `com.example.frontend`
4. Agrega tu SHA-1 fingerprint (obtenerlo con el comando abajo)

**Para iOS:**

1. Crea otra API key (o usa la misma sin restricciones para desarrollo)
2. En "Application restrictions", selecciona "iOS apps"
3. Agrega el Bundle ID: `com.example.frontend`

## Obtener SHA-1 Fingerprint (Android)

### Para Debug

```bash
cd android
./gradlew signingReport
```

Busca la línea que dice `SHA1:` bajo `Variant: debug`

### Para Release

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

## Configurar la API Key en el proyecto

### Android

Reemplaza `YOUR_GOOGLE_MAPS_API_KEY_HERE` en:
`android/app/src/main/AndroidManifest.xml`

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="TU_API_KEY_AQUI"/>
```

### iOS

Agrega en `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("TU_API_KEY_AQUI")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## Notas Importantes

⚠️ **Seguridad:**

- Nunca subas tu API key a repositorios públicos
- Usa restricciones de API para limitar el uso
- Considera usar variables de entorno para producción

💡 **Desarrollo:**

- Puedes usar una API key sin restricciones para desarrollo local
- Google ofrece $200 de crédito mensual gratis para Maps
- El uso típico de desarrollo no excede el límite gratuito

🔧 **Troubleshooting:**

- Si el mapa no carga, verifica los logs de Android/iOS
- Asegúrate de que las APIs estén habilitadas en Google Cloud
- Verifica que la API key esté correctamente configurada
