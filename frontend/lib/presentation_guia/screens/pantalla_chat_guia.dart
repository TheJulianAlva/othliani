import 'package:flutter/material.dart';
import 'package:frontend/presentation_turista/widgets/chat_bubble.dart';
import 'package:frontend/presentation_turista/widgets/message_input_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChatScreenGuia extends StatefulWidget {
  const ChatScreenGuia({super.key});

  @override
  State<ChatScreenGuia> createState() => _ChatScreenGuiaState();
}

class _ChatScreenGuiaState extends State<ChatScreenGuia> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [
    "¡Hola a todos! Bienvenidos al tour.",
    "¿A qué hora es la comida?",
  ];
  final List<bool> _isSentByMe = [true, false]; // Mock data

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add(_controller.text);
        _isSentByMe.add(true);
        _controller.clear();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chat),
        actions: [
          IconButton(
            icon: const Icon(Icons.campaign), // Broadcast icon
            tooltip: 'Enviar anuncio',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Funcionalidad de anuncio global próximamente')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Estás chateando como Guía. Tus mensajes son visibles para todos.',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(l10n.typeMessage),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return ChatBubble(
                        message: _messages[index],
                        isSent: _isSentByMe[index],
                      );
                    },
                  ),
          ),
          MessageInputField(controller: _controller, onSend: _sendMessage),
        ],
      ),
    );
  }
}
