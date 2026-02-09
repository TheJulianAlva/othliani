import 'package:frontend/features/turista/chat/data/datasources/chat_remote_data_source.dart';
import 'package:frontend/features/turista/chat/domain/entities/message.dart';
import 'package:frontend/features/turista/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<Message>> getMessages() {
    return remoteDataSource.getMessages();
  }

  @override
  Future<void> sendMessage(String text) async {
    return await remoteDataSource.sendMessage(text);
  }
}
