import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_constants.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isSent;

  const ChatBubble({super.key, required this.message, this.isSent = true});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color:
              isSent ? AppColors.chatBubbleSent : AppColors.chatBubbleReceived,
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(message),
      ),
    );
  }
}
