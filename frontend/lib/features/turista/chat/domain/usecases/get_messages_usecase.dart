import 'package:frontend/features/turista/chat/domain/entities/message.dart';
import 'package:frontend/features/turista/chat/domain/repositories/chat_repository.dart';

class GetMessagesUseCase {
  final ChatRepository repository;

  GetMessagesUseCase(this.repository);

  Stream<List<Message>> call() {
    return repository.getMessages();
  }
}
