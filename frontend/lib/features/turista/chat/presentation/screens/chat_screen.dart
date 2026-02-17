import 'package:flutter/material.dart';
import 'package:frontend/features/turista/chat/presentation/widgets/chat_bubble.dart';
import 'package:frontend/features/turista/chat/presentation/widgets/message_input_field.dart';
import 'package:frontend/core/l10n/app_localizations.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add(_controller.text);
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

    return Column(
      children: [
        Expanded(
          child:
              _messages.isEmpty
                  ? Center(child: Text(l10n.typeMessage))
                  : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return ChatBubble(
                        message: _messages[index],
                        isSent: true,
                      );
                    },
                  ),
        ),
        MessageInputField(controller: _controller, onSend: _sendMessage),
      ],
    );
  }
}
