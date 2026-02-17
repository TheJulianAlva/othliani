import 'package:equatable/equatable.dart';

enum ActivityStatus { pending, inProgress, finished }

class Activity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String time;
  final ActivityStatus status;

  const Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.status,
  });

  @override
  List<Object> get props => [id, title, description, time, status];
}
