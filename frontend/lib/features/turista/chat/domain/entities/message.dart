import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String text;
  final String senderId;
  final DateTime timestamp;
  final bool isMe;

  const Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.timestamp,
    required this.isMe,
  });

  @override
  List<Object?> get props => [id, text, senderId, timestamp, isMe];
}
