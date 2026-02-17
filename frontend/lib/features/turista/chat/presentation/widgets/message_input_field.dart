import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_constants.dart';

class MessageInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final String hintText;

  const MessageInputField({
    super.key,
    required this.controller,
    required this.onSend,
    this.hintText = 'Escribe un mensaje...',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppBorderRadius.xl),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: onSend,
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}
