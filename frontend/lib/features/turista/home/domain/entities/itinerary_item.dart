import 'package:equatable/equatable.dart';

class ItineraryItem extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String location;

  const ItineraryItem({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
  });

  @override
  List<Object> get props => [
    id,
    title,
    description,
    startTime,
    endTime,
    location,
  ];
}
