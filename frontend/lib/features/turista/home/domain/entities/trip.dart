import 'package:equatable/equatable.dart';
import 'package:frontend/features/turista/home/domain/entities/activity.dart';

class Trip extends Equatable {
  final String id;
  final String title;
  final String description;
  final Map<String, List<Activity>> activitiesByDay;

  const Trip({
    required this.id,
    required this.title,
    required this.description,
    required this.activitiesByDay,
  });

  List<String> get days => activitiesByDay.keys.toList();

  @override
  List<Object> get props => [id, title, description, activitiesByDay];
}
