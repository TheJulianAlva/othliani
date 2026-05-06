import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';
import 'package:frontend/core/l10n/app_localizations.dart';

class TraductorVozScreen extends StatefulWidget {
  const TraductorVozScreen({super.key});

  @override
  State<TraductorVozScreen> createState() => _TraductorVozScreenState();
}

class _TraductorVozScreenState extends State<TraductorVozScreen>
    with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  late FlutterTts _flutterTts;
  final GoogleTranslator _translator = GoogleTranslator();

  bool _isListening = false;
  bool _isProcessing = false;
  String _textoReconocido = "Presiona el micrófono y empieza a hablar";
  String _textoTraducido = "";
  
  // Animación del botón del micrófono
  late AnimationController _animationController;

  // Idiomas
  String _idiomaOrigen = 'es';
  String _idiomaDestino = 'en';

  final Map<String, String> _idiomasSoportados = {
    'es': 'Español',
    'en': 'Inglés',
    'fr': 'Francés',
    'de': 'Alemán',
    'it': 'Italiano',
    'pt': 'Portugués',
    'ja': 'Japonés',
  };

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    
    _configurarTts();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  Future<void> _configurarTts() async {
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _speech.cancel();
    _flutterTts.stop();
    super.dispose();
  }

  // --- Voz a Texto ---
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done') {
            setState(() => _isListening = false);
            // Cuando deja de escuchar, traduce lo recolectado
            if (_textoReconocido.isNotEmpty &&
                _textoReconocido != "Presiona el micrófono y empieza a hablar") {
              _traducirTexto();
            }
          }
        },
        onError: (val) => debugPrint('onError: $val'),
      );
      
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _textoReconocido = val.recognizedWords;
          }),
          localeId: _idiomaOrigen, // Escucha en el idioma seleccionado de origen
        );
      } else {
        setState(() {
          _isListening = false;
          _textoReconocido = "El reconocimiento de voz no está disponible en este dispositivo.";
        });
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  // --- Traducir Texto ---
  Future<void> _traducirTexto() async {
    if (_textoReconocido.isEmpty) return;
    
    setState(() => _isProcessing = true);
    
    try {
      var translation = await _translator.translate(
        _textoReconocido,
        from: _idiomaOrigen,
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

  // --- Texto a Voz (Hablar la traducción) ---
  Future<void> _speak() async {
    if (_textoTraducido.isNotEmpty && _textoTraducido != "Error al traducir.") {
      await _flutterTts.setLanguage(_idiomaDestino);
      await _flutterTts.speak(_textoTraducido);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos traducciones seguras con fallback en español
    final title = (() {
      try {
        return AppLocalizations.of(context)?.translatorTitle ?? 'Traductor de Voz';
      } catch (e) {
        return 'Traductor de Voz';
      }
    })();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // --- SELECTORES DE IDIOMAS ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Idioma Origen
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Yo hablo:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _idiomaOrigen,
                              items: _idiomasSoportados.entries.map((e) => 
                                DropdownMenuItem(value: e.key, child: Text(e.value))
                              ).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _idiomaOrigen = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Icono Intercambio
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: IconButton(
                      icon: const Icon(Icons.swap_horiz, size: 30, color: Colors.blueAccent),
                      onPressed: () {
                        setState(() {
                          final temp = _idiomaOrigen;
                          _idiomaOrigen = _idiomaDestino;
                          _idiomaDestino = temp;
                          _traducirTexto();
                        });
                      },
                    ),
                  ),

                  // Idioma Destino
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Traducir a:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _idiomaDestino,
                              items: _idiomasSoportados.entries.map((e) => 
                                DropdownMenuItem(value: e.key, child: Text(e.value))
                              ).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _idiomaDestino = val);
                                  _traducirTexto();
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),

              // --- TEXTO RECONOCIDO ---
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Texto reconocido:',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            _textoReconocido,
                            style: const TextStyle(fontSize: 22, color: Colors.black87),
                          ),
                        ),
                      ),
                      if (_isProcessing)
                        const LinearProgressIndicator(color: Colors.blueAccent),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // --- TEXTO TRADUCIDO ---
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Traducción (${_idiomasSoportados[_idiomaDestino]}):',
                            style: const TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_textoTraducido.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.volume_up, color: Colors.blueAccent),
                              iconSize: 32,
                              onPressed: _speak,
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            _textoTraducido.isEmpty ? "..." : _textoTraducido,
                            style: const TextStyle(
                              fontSize: 24, 
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // --- BOTÓN PRINCIPAL DE GRABACIÓN ---
              GestureDetector(
                onTap: _listen,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          if (_isListening)
                            BoxShadow(
                              color: Colors.redAccent.withValues(alpha: 0.4),
                              spreadRadius: _animationController.value * 20,
                              blurRadius: 10,
                            ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: _isListening ? Colors.redAccent : Colors.blueAccent,
                        child: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _isListening ? 'Escuchando...' : 'Toca para hablar',
                style: TextStyle(
                  color: _isListening ? Colors.redAccent : Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
