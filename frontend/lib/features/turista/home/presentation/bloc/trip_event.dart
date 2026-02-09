import 'package:equatable/equatable.dart';

abstract class TripEvent extends Equatable {
  const TripEvent();

  @override
  List<Object?> get props => [];
}

class TripStarted extends TripEvent {}

class TripDayChanged extends TripEvent {
  final String day;
  const TripDayChanged(this.day);

  @override
  List<Object?> get props => [day];
}

class TripFilterChanged extends TripEvent {
  final String filter;
  const TripFilterChanged(this.filter);

  @override
  List<Object?> get props => [filter];
}
