import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:translator/translator.dart';
import 'package:frontend/core/l10n/app_localizations.dart'; // Para traducciones de la AppBar

class TraductorScreen extends StatefulWidget {
  const TraductorScreen({super.key});

  @override
  State<TraductorScreen> createState() => _TraductorScreenState();
}

class _TraductorScreenState extends State<TraductorScreen> {
  File? _image;
  String _textoExtraido = "";
  String _textoTraducido = "";
  bool _isProcessing = false;

  final ImagePicker _picker = ImagePicker();
  final GoogleTranslator _translator = GoogleTranslator();

  // ✨ NUEVO: Mapa de idiomas soportados y el idioma seleccionado por defecto
  String _idiomaDestino = 'es';
  final Map<String, String> _idiomasSoportados = {
    'es': 'Español',
    'en': 'Inglés',
    'fr': 'Francés',
    'de': 'Alemán',
    'it': 'Italiano',
    'pt': 'Portugués',
    'ja': 'Japonés',
  };

  // 📸 1. Capturar o seleccionar la imagen
  Future<void> _capturarImagen(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _textoExtraido = "";
        _textoTraducido = "";
        _isProcessing = true;
      });

      await _procesarImagenYTraducir();
    }
  }

  // 🧠 2. Extraer el texto (OCR) y Traducir
  Future<void> _procesarImagenYTraducir() async {
    if (_image == null) return;

    try {
      // A. Extraer Texto (ML Kit)
      final inputImage = InputImage.fromFile(_image!);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      String textoDetectado = recognizedText.text;
      
      // B. Si encontró texto, lo traducimos al idioma destino
      if (textoDetectado.trim().isNotEmpty) {
        var translation = await _translator.translate(
          textoDetectado,
          to: _idiomaDestino,
        );
        
        setState(() {
          _textoExtraido = textoDetectado;
          _textoTraducido = translation.text;
          _isProcessing = false;
        });
      } else {
        setState(() {
          _textoExtraido = "No se detectó ningún texto en la imagen.";
          _isProcessing = false;
        });
      }
      
      // Cerrar el reconocedor para liberar memoria
      textRecognizer.close();
    } catch (e) {
      setState(() {
        _textoExtraido = "Error al procesar la imagen.";
        _isProcessing = false;
      });
    }
  }

  // 🔄 3. Re-traducir texto existente si se cambia el idioma
  Future<void> _traducirTextoExistente() async {
    if (_textoExtraido.isEmpty ||
        _textoExtraido == "No se detectó ningún texto en la imagen." ||
        _textoExtraido == "Error al procesar la imagen.") {
      return;
    }

    setState(() => _isProcessing = true);

    try {
      var translation = await _translator.translate(
        _textoExtraido,
        to: _idiomaDestino,
      );
      setState(() {
        _textoTraducido = translation.text;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _textoTraducido = "Error al traducir.";
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Intentar obtener el título traducido si existe, sino fallback a "Traductor Visual"
    final l10n = AppLocalizations.of(context);
    final title = l10n?.translatorTitle ?? 'Traductor Visual';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- ÁREA DE LA IMAGEN ---
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: _image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(_image!, fit: BoxFit.cover),
                    )
                  : const Center(
                      child: Text('Toma una foto de un letrero o menú',
                          style: TextStyle(color: Colors.grey)),
                    ),
            ),
            // --- SELECTOR DE IDIOMA ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Traducir al: ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _idiomaDestino,
                      items:
                          _idiomasSoportados.entries.map((entry) {
                            return DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(
                                entry.value,
                                style: const TextStyle(fontSize: 16),
                              ),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _idiomaDestino = newValue;
                          });
                          // Si ya hay texto, vuelve a traducirlo al nuevo idioma
                          _traducirTextoExistente();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // --- BOTONES DE ACCIÓN ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isProcessing ? null : () => _capturarImagen(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Cámara'),
                ),
                ElevatedButton.icon(
                  onPressed: _isProcessing ? null : () => _capturarImagen(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galería'),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // --- ESTADO DE CARGA ---
            if (_isProcessing)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text("Leyendo y traduciendo..."),
                  ],
                ),
              ),

            // --- RESULTADOS ---
            if (!_isProcessing && _textoExtraido.isNotEmpty) ...[
              const Text(
                'Texto Original:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(top: 8, bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_textoExtraido),
              ),
              
              if (_textoTraducido.isNotEmpty) ...[
                Text(
                  'Traducción (${_idiomasSoportados[_idiomaDestino]}):',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text(
                    _textoTraducido,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ]
            ],
          ],
        ),
      ),
    );
  }
}
