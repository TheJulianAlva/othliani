import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class ChatStarted extends ChatEvent {}

class MessageSent extends ChatEvent {
  final String text;

  const MessageSent(this.text);

  @override
  List<Object> get props => [text];
}
