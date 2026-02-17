import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/turista/chat/domain/entities/message.dart';
import 'package:frontend/features/turista/chat/domain/usecases/get_messages_usecase.dart';
import 'package:frontend/features/turista/chat/domain/usecases/send_message_usecase.dart';
import 'package:frontend/features/turista/chat/presentation/bloc/chat_event.dart';
import 'package:frontend/features/turista/chat/presentation/bloc/chat_state.dart';

// Private event for internal use
class _MessagesUpdated extends ChatEvent {
  final List<Message> messages;

  const _MessagesUpdated(this.messages);
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  StreamSubscription? _messagesSubscription;

  ChatBloc({required this.getMessagesUseCase, required this.sendMessageUseCase})
    : super(ChatInitial()) {
    on<ChatStarted>(_onChatStarted);
    on<MessageSent>(_onMessageSent);
    on<_MessagesUpdated>(_onMessagesUpdated);
  }

  Future<void> _onChatStarted(
    ChatStarted event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    await _messagesSubscription?.cancel();
    _messagesSubscription = getMessagesUseCase().listen(
      (messages) {
        if (!isClosed) {
          add(_MessagesUpdated(messages));
        }
      },
      onError: (error) {
        if (!isClosed) emit(ChatError(error.toString()));
      },
    );
  }

  Future<void> _onMessagesUpdated(
    _MessagesUpdated event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoaded(event.messages));
  }

  Future<void> _onMessageSent(
    MessageSent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      await sendMessageUseCase(event.text);
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
