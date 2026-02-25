import 'package:flutter/material.dart';
import 'package:frontend/features/turista/chat/presentation/widgets/chat_bubble.dart';
import 'package:frontend/features/turista/chat/presentation/widgets/message_input_field.dart';

/// Chat grupal del guía.
/// Diferenciador vs. turista: botón de "Anuncio General" que resalta el mensaje
/// para todos los participantes del grupo.
class GuiaChatScreen extends StatefulWidget {
  const GuiaChatScreen({super.key});

  @override
  State<GuiaChatScreen> createState() => _GuiaChatScreenState();
}

class _GuiaChatScreenState extends State<GuiaChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  final List<_MensajeGuia> _mensajes = [
    _MensajeGuia(
      texto: 'Buenos días grupo, listos para arrancar 🎒',
      esPropio: true,
      esAnuncio: false,
      hora: '08:02',
    ),
    _MensajeGuia(
      texto: '¿Cuánto tiempo en las ruinas?',
      esPropio: false,
      esAnuncio: false,
      hora: '08:04',
      autor: 'Juan D.',
    ),
    _MensajeGuia(
      texto: '📢 ANUNCIO: Nos reunimos en la Puerta Norte a las 11:00 AM.',
      esPropio: true,
      esAnuncio: true,
      hora: '08:10',
    ),
    _MensajeGuia(
      texto: 'Ok! ✅',
      esPropio: false,
      esAnuncio: false,
      hora: '08:11',
      autor: 'Ana M.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _enviar({bool esAnuncio = false}) {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _mensajes.add(
        _MensajeGuia(
          texto:
              esAnuncio
                  ? '📢 ANUNCIO: ${_controller.text.trim()}'
                  : _controller.text.trim(),
          esPropio: true,
          esAnuncio: esAnuncio,
          hora: _horaActual(),
        ),
      );
      _controller.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _horaActual() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chat del grupo', style: TextStyle(fontSize: 15)),
            Text(
              '24 participantes · 19 en línea',
              style: TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.people_rounded), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Lista de mensajes
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              itemCount: _mensajes.length,
              itemBuilder: (_, i) => _BurbujaMensaje(mensaje: _mensajes[i]),
            ),
          ),

          // Botón de anuncio
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _enviar(esAnuncio: true),
                    icon: const Icon(Icons.campaign_rounded, size: 16),
                    label: const Text(
                      'Anuncio general',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE65100),
                      side: const BorderSide(color: Color(0xFFE65100)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Barra de entrada
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 4),
            child: MessageInputField(
              controller: _controller,
              onSend: _enviar,
              hintText: 'Escribe un mensaje...',
            ),
          ),
        ],
      ),
    );
  }
}

// ── Modelos ───────────────────────────────────────────────────────────────────

class _MensajeGuia {
  final String texto;
  final bool esPropio;
  final bool esAnuncio;
  final String hora;
  final String? autor;

  const _MensajeGuia({
    required this.texto,
    required this.esPropio,
    required this.esAnuncio,
    required this.hora,
    this.autor,
  });
}

// ── Burbuja de mensaje ────────────────────────────────────────────────────────

class _BurbujaMensaje extends StatelessWidget {
  final _MensajeGuia mensaje;
  const _BurbujaMensaje({required this.mensaje});

  @override
  Widget build(BuildContext context) {
    // Anuncio general: banner ancho centralizado
    if (mensaje.esAnuncio) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFE65100).withAlpha(15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE65100).withAlpha(80)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.campaign_rounded,
              color: Color(0xFFE65100),
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                mensaje.texto,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: Color(0xFFBF360C),
                ),
              ),
            ),
            Text(
              mensaje.hora,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    // Mensaje normal: reutiliza ChatBubble del turista
    return Column(
      crossAxisAlignment:
          mensaje.esPropio ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (!mensaje.esPropio && mensaje.autor != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 2),
            child: Text(
              mensaje.autor!,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        Row(
          mainAxisAlignment:
              mensaje.esPropio
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!mensaje.esPropio) ...[
              CircleAvatar(
                radius: 12,
                backgroundColor: const Color(0xFF3D5AF1).withAlpha(30),
                child: Text(
                  mensaje.autor?.substring(0, 1) ?? '?',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF3D5AF1),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
            ChatBubble(message: mensaje.texto, isSent: mensaje.esPropio),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(
            left: mensaje.esPropio ? 0 : 30,
            right: mensaje.esPropio ? 4 : 0,
            bottom: 8,
          ),
          child: Text(
            mensaje.hora,
            style: TextStyle(fontSize: 9, color: Colors.grey.shade400),
          ),
        ),
      ],
    );
  }
}
