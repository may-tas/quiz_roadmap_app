import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exercise_roadmap_app/cubit/mcq_state.dart';
import 'package:exercise_roadmap_app/models/question_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MCQCubit extends Cubit<MCQState> {
  MCQCubit() : super(MCQInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void loadQuestions(String excercise, String day) async {
    emit(MCQLoading());
    try {
      final querySnapshot = await _firestore
          .collection('roadmap')
          .doc(day)
          .collection('excercises')
          .doc(excercise)
          .collection('questions')
          .get();
      final List<Question> questionDoc = querySnapshot.docs.map((doc) {
        return Question.fromMap(doc.data());
      }).toList();
      emit(MCQLoaded(
          questions: questionDoc, correctAnswers: 0, currentQuestionIndex: 0));
    } catch (e) {
      emit(MCQError(e.toString()));
    }
  }

  void selectAnswer(String selectedOption, MCQState state) {
    final currentState = state as MCQLoaded;
    emit(currentState.copyWith(
      selectedOption: selectedOption,
    ));
  }

  void checkAnswer(
      MCQState state, String day, int excerciseIndex, int dayIndex) {
    final currentState = state as MCQLoaded;
    final currentQuestion =
        currentState.questions[currentState.currentQuestionIndex];

    String correctAnswer = currentQuestion.answer;
    int correctAnswers = currentState.correctAnswers;

    if (currentState.selectedOption == correctAnswer) {
      correctAnswers++;
    }

    if (currentState.currentQuestionIndex < currentState.questions.length - 1) {
      emit(MCQLoaded(
        questions: currentState.questions,
        currentQuestionIndex: currentState.currentQuestionIndex + 1,
        correctAnswers: correctAnswers,
        selectedOption: null, // Reset selection
      ));
    } else {
      emit(MCQCompleted(correctAnswers: correctAnswers));
      _storeProgress(currentState.questions.length, correctAnswers, day,
          excerciseIndex, dayIndex);
    }
  }

  Future<void> _storeProgress(int totalQuestions, int correctAnswers,
      String day, int excerciseIndex, int dayIndex) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String exerciseKey = 'progress_${DateTime.now().toIso8601String()}';
    prefs.setInt(exerciseKey, correctAnswers);
    final username = prefs.getString('username');
    // Fetch current progress from Firestore
    DocumentSnapshot progressDoc =
        await _firestore.collection('users').doc(username).get();

    Map<String, dynamic> progress =
        (progressDoc.data() as Map<String, dynamic>)['progress'] ?? {};
    String currentDay = day;
    String exerciseId = 'excercise$excerciseIndex';

    // Mark the exercise as completed
    progress[currentDay] ??= {};
    progress[currentDay][exerciseId] = true;

    // Update Firestore
    await _firestore
        .collection('users')
        .doc(username)
        .update({'progress': progress});

    // Check if all exercises are completed for the current day
    bool allCompleted =
        (progress[currentDay] as Map).values.every((val) => val == true);
    if (allCompleted) {
      print('im here');
      await _unlockNextDay(progressDoc, username, dayIndex);
    }
  }

  Future<void> _unlockNextDay(
      DocumentSnapshot progressDoc, String? username, int dayIndex) async {
    List<String> unlockedDays =
        List<String>.from(progressDoc['unlockedDays'] ?? ['day1']);

    // Unlock the next day if not already unlocked
    if (unlockedDays.contains('day$dayIndex')) {
      if (dayIndex != 6) {
        unlockedDays.add('day${dayIndex + 1}');
      }
// Example: unlock day2
      await _firestore
          .collection('users')
          .doc(username)
          .update({'unlockedDays': unlockedDays});
    }
  }
}
