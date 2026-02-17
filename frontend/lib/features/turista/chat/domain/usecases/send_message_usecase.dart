import 'package:frontend/features/turista/chat/domain/repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<void> call(String text) async {
    return await repository.sendMessage(text);
  }
}
