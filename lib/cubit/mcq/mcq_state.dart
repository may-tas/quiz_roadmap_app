// Define the states for the MCQ
import 'package:exercise_roadmap_app/models/question_model.dart';

abstract class MCQState {}

class MCQInitial extends MCQState {}

class MCQLoading extends MCQState {}

class MCQLoaded extends MCQState {
  final List<Question> questions;
  final int currentQuestionIndex;
  final int correctAnswers;
  final String? selectedOption;
  final bool isAnswerChecked;

  MCQLoaded(
      {required this.questions,
      required this.currentQuestionIndex,
      required this.correctAnswers,
      this.selectedOption,
      this.isAnswerChecked = false});

  MCQLoaded copyWith({
    List<Question>? questions,
    int? currentQuestionIndex,
    int? correctAnswers,
    String? selectedOption,
    bool? isAnswerChecked,
  }) {
    return MCQLoaded(
        questions: questions ?? this.questions,
        currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
        correctAnswers: correctAnswers ?? this.correctAnswers,
        selectedOption: selectedOption,
        isAnswerChecked: isAnswerChecked ?? this.isAnswerChecked);
  }
}

class MCQCompleted extends MCQState {
  final int correctAnswers;
  MCQCompleted({required this.correctAnswers});
}

class MCQError extends MCQState {
  final String message;
  MCQError(this.message);
}
