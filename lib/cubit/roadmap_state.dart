import 'package:equatable/equatable.dart';

abstract class RoadmapState extends Equatable {
  @override
  List<Object> get props => [];
}

class RoadmapInitial extends RoadmapState {}

class RoadmapLoading extends RoadmapState {}

class RoadmapLoaded extends RoadmapState {
  final List<String> unlockedDays;

  RoadmapLoaded(this.unlockedDays);

  @override
  List<Object> get props => [unlockedDays];
}

class RoadmapError extends RoadmapState {
  final String message;

  RoadmapError(this.message);

  @override
  List<Object> get props => [message];
}
