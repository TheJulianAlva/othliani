# Conversor de Moneda con OCR

## Descripción General

El **Conversor de Moneda** es una funcionalidad completa que permite a los turistas convertir precios entre diferentes monedas de manera rápida y sencilla. Incluye dos métodos de entrada:

1. **Entrada Manual**: Escribir el monto directamente
2. **Escaneo OCR**: Tomar una foto del precio o seleccionar una imagen de la galería para extraer automáticamente el número

## Características Principales

### 🎯 Funcionalidades

- ✅ Conversión entre 6 monedas principales (USD, MXN, EUR, GBP, JPY, CAD)
- ✅ Entrada manual de cantidades
- ✅ Captura de fotos con la cámara
- ✅ Selección de imágenes desde la galería
- ✅ Reconocimiento de texto (OCR) automático usando Google ML Kit
- ✅ Intercambio rápido de monedas (botón swap)
- ✅ Conversión en tiempo real mientras escribes
- ✅ Visualización de la tasa de cambio actual
- ✅ Interfaz intuitiva con banderas y nombres de monedas

### 📱 Flujo de Usuario

1. **Acceso**: Desde el Home Screen, toca la tarjeta "Cambio de Moneda" (verde)
2. **Seleccionar Monedas**: 
   - Elige la moneda de origen (De)
   - Elige la moneda de destino (A)
   - Usa el botón de intercambio para invertirlas rápidamente
3. **Ingresar Monto**:
   - **Opción A**: Escribe el monto manualmente
   - **Opción B**: Toca "Tomar Foto" para capturar un precio
   - **Opción C**: Toca "Galería" para seleccionar una imagen existente
4. **Ver Resultado**: El resultado se muestra automáticamente en tiempo real

## Dependencias Utilizadas

### Paquetes de Flutter

```yaml
# Cámara e Imágenes
camera: ^0.10.5+5              # Captura de fotos
image_picker: ^1.0.4           # Selección de imágenes

# OCR (Reconocimiento de Texto)
google_mlkit_text_recognition: ^0.11.0  # ML Kit para OCR

# Conversión de Moneda
http: ^1.1.0                   # Para futuras llamadas a APIs de tasas
intl: ^0.19.0                  # Formateo de números y monedas

# UI
dropdown_search: ^5.0.6        # Selectores mejorados (opcional)
```

### Permisos Configurados

**Android** (`AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-feature android:name="android.hardware.camera" android:required="false"/>
```

**iOS** (`Info.plist`):
```xml
<key>NSCameraUsageDescription</key>
<string>Esta aplicación necesita acceso a la cámara para escanear precios</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Esta aplicación necesita acceso a tus fotos para seleccionar imágenes</string>
```

## Arquitectura Técnica

### Componentes Principales

1. **CurrencyConverterScreen** (`currency_converter_screen.dart`)
   - Widget principal de la pantalla
   - Maneja el estado de la conversión
   - Integra cámara y OCR

2. **Reconocimiento OCR**
   - Usa Google ML Kit Text Recognition
   - Extrae números de imágenes automáticamente
   - Busca patrones numéricos con regex: `[\d,]+\.?\d*`

3. **Sistema de Tasas de Cambio**
   - Actualmente usa tasas hardcodeadas (para desarrollo)
   - Estructura preparada para integrar API real
   - Mapa de conversiones bidireccionales

### Monedas Soportadas

| Código | Nombre | Símbolo | Bandera |
|--------|--------|---------|---------|
| USD | Dólar Estadounidense | $ | 🇺🇸 |
| MXN | Peso Mexicano | $ | 🇲🇽 |
| EUR | Euro | € | 🇪🇺 |
| GBP | Libra Esterlina | £ | 🇬🇧 |
| JPY | Yen Japonés | ¥ | 🇯🇵 |
| CAD | Dólar Canadiense | $ | 🇨🇦 |

## Uso del OCR

### Cómo Funciona

1. **Captura de Imagen**: El usuario toma una foto o selecciona una imagen
2. **Procesamiento**: Google ML Kit analiza la imagen
3. **Extracción**: Se buscan patrones numéricos en el texto reconocido
4. **Auto-completado**: El primer número encontrado se ingresa automáticamente
5. **Conversión**: Se realiza la conversión instantáneamente

### Ejemplo de Uso

```dart
// Tomar foto
await _takePicture();

// Procesar imagen con OCR
final inputImage = InputImage.fromFilePath(imagePath);
final textRecognizer = TextRecognizer();
final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

// Extraer números
final RegExp numberRegex = RegExp(r'[\d,]+\.?\d*');
final match = numberRegex.firstMatch(line.text);
```

## Mejoras Futuras

### 🚀 Próximas Funcionalidades

1. **API de Tasas en Tiempo Real**
   - Integrar con APIs como:
     - [ExchangeRate-API](https://www.exchangerate-api.com/)
     - [Fixer.io](https://fixer.io/)
     - [Open Exchange Rates](https://openexchangerates.org/)
   
2. **Más Monedas**
   - Agregar monedas de América Latina
   - Soporte para criptomonedas
   
3. **Historial de Conversiones**
   - Guardar conversiones recientes
   - Favoritos de pares de monedas
   
4. **Modo Offline**
   - Caché de tasas de cambio
   - Última actualización visible
   
5. **OCR Mejorado**
   - Detección de símbolos de moneda
   - Reconocimiento de múltiples precios en una imagen
   - Selección manual del número a usar

## Integración con API Real

### Ejemplo de Implementación

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, double>> fetchExchangeRates(String baseCurrency) async {
  final response = await http.get(
    Uri.parse('https://api.exchangerate-api.com/v4/latest/$baseCurrency'),
  );
  
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return Map<String, double>.from(data['rates']);
  }
  throw Exception('Failed to load exchange rates');
}
```

## Troubleshooting

### Problemas Comunes

**1. OCR no detecta números**
- Asegúrate de que la imagen tenga buena iluminación
- El texto debe estar enfocado y legible
- Prueba con diferentes ángulos

**2. Permisos de cámara denegados**
- Ve a Configuración > Apps > OthliAni > Permisos
- Habilita Cámara y Almacenamiento

**3. Error al procesar imagen**
- Verifica que Google ML Kit esté correctamente instalado
- Ejecuta `flutter pub get` para asegurar dependencias

## Testing

### Comandos de Prueba

```bash
# Instalar dependencias
flutter pub get

# Ejecutar en modo debug
flutter run

# Verificar permisos (Android)
adb shell pm list permissions -d -g

# Limpiar y reconstruir
flutter clean
flutter pub get
flutter run
```

## Notas de Desarrollo

- Las tasas de cambio actuales son **valores de ejemplo**
- Para producción, **DEBES** integrar una API real de tasas
- El OCR funciona mejor con texto impreso que manuscrito
- Las imágenes se procesan localmente (no se envían a servidores)
- El botón walkie-talkie es arrastrable en esta pantalla también

## Recursos Adicionales

- [Google ML Kit Documentation](https://developers.google.com/ml-kit/vision/text-recognition)
- [Flutter Camera Plugin](https://pub.dev/packages/camera)
- [Image Picker Plugin](https://pub.dev/packages/image_picker)
- [ExchangeRate API Docs](https://www.exchangerate-api.com/docs)
