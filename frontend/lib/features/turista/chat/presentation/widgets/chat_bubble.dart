import 'package:flutter/material.dart';
import 'package:frontend/core/theme/veltur_tokens.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isSent;

  const ChatBubble({super.key, required this.message, this.isSent = true});

  @override
  Widget build(BuildContext context) {
    final tokens = VelturTokens.of(context);
    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSent ? tokens.primarySoft : tokens.accentTealSoft,
          borderRadius: BorderRadius.circular(tokens.radiusMd),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(message, style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }
}
