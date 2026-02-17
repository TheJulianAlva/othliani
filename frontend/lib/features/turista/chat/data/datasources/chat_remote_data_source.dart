import 'dart:async';
import 'package:frontend/features/turista/chat/domain/entities/message.dart';

abstract class ChatRemoteDataSource {
  Stream<List<Message>> getMessages();
  Future<void> sendMessage(String text);
}

class ChatMockDataSource implements ChatRemoteDataSource {
  final _controller = StreamController<List<Message>>.broadcast();
  final List<Message> _messages = [];

  ChatMockDataSource() {
    // Initial mock message
    _messages.add(
      Message(
        id: '1',
        text: '¡Hola! Bienvenido al chat de soporte.',
        senderId: 'support',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isMe: false,
      ),
    );
    _controller.add(List.from(_messages));
  }

  @override
  Stream<List<Message>> getMessages() {
    return _controller.stream;
  }

  @override
  Future<void> sendMessage(String text) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simular red
    final newMessage = Message(
      id: DateTime.now().toString(),
      text: text,
      senderId: 'user',
      timestamp: DateTime.now(),
      isMe: true,
    );
    _messages.add(newMessage);
    _controller.add(List.from(_messages));

    // Simulate auto-reply
    if (text.toLowerCase().contains('hola')) {
      Future.delayed(const Duration(seconds: 1), () {
        _messages.add(
          Message(
            id: DateTime.now().toString(),
            text: '¿En qué puedo ayudarte hoy?',
            senderId: 'support',
            timestamp: DateTime.now(),
            isMe: false,
          ),
        );
        _controller.add(List.from(_messages));
      });
    }
  }

  void dispose() {
    _controller.close();
  }
}
