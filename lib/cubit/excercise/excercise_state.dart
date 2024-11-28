import 'package:equatable/equatable.dart';

abstract class ExcerciseState extends Equatable {
  @override
  List<Object> get props => [];
}

class ExcerciseInitial extends ExcerciseState {}

class ExcerciseLoading extends ExcerciseState {}

class ExcercisesLoaded extends ExcerciseState {
  final List<String> excercises;

  ExcercisesLoaded(this.excercises);

  @override
  List<Object> get props => [excercises];
}

class ExcerciseError extends ExcerciseState {
  final String message;

  ExcerciseError(this.message);

  @override
  List<Object> get props => [message];
}
