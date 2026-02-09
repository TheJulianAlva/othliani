import 'package:frontend/features/turista/chat/domain/entities/message.dart';

abstract class ChatRepository {
  Stream<List<Message>> getMessages();
  Future<void> sendMessage(String text);
}
