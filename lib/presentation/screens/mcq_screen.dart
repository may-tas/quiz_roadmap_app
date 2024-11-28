import 'package:exercise_roadmap_app/cubit/roadmap/roadmap_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:exercise_roadmap_app/cubit/mcq/mcq_cubit.dart';
import 'package:exercise_roadmap_app/cubit/mcq/mcq_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MCQScreen extends StatefulWidget {
  final String excercise;
  final String day;
  final int excerciseIndex;
  final int dayIndex;

  const MCQScreen({
    super.key,
    required this.excercise,
    required this.day,
    required this.excerciseIndex,
    required this.dayIndex,
  });

  @override
  State<MCQScreen> createState() => _MCQScreenState();
}

class _MCQScreenState extends State<MCQScreen> {
  late MCQCubit mcqCubit;
  late String? username;
  bool isAnswerChecked = false;
  String? correctAnswer;

  @override
  void initState() {
    super.initState();
    setUsername();
    mcqCubit = BlocProvider.of<MCQCubit>(context);
    mcqCubit.loadQuestions("excercise${widget.excerciseIndex}", widget.day);
  }

  Future<void> setUsername() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username');
  }

  Future<void> handleAnswerCheck(MCQLoaded state, String selectedOption) async {
    setState(() {
      isAnswerChecked = true;
      correctAnswer = state.questions[state.currentQuestionIndex].answer;
    });

    final isCorrect = selectedOption == correctAnswer;

    // Show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCorrect ? "🎉 Congrats! Correct Answer!" : "❌ Wrong Answer!",
        ),
        backgroundColor: isCorrect ? Colors.green[700] : Colors.red[700],
        duration: const Duration(seconds: 1),
      ),
    );

    // Wait for 1 second before moving to next question
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        isAnswerChecked = false;
        correctAnswer = null;
      });
      context.read<MCQCubit>().checkAnswer(
            state,
            widget.day,
            widget.excerciseIndex,
            widget.dayIndex,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1a1a1a),
            Color(0xFF1a237e),
            Color(0xFF1a1a1a),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Quiz: ${widget.excercise}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: BlocBuilder<MCQCubit, MCQState>(
          bloc: mcqCubit,
          builder: (context, state) {
            if (state is MCQLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            } else if (state is MCQLoaded) {
              final question = state.questions[state.currentQuestionIndex];
              final selectedOption = state.selectedOption;

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.grey[800],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (state.currentQuestionIndex + 1) /
                                state.questions.length,
                            backgroundColor: Colors.transparent,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF4CAF50),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Question ${state.currentQuestionIndex + 1}/${state.questions.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        question.question,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ...List.generate(
                        question.options.length,
                        (index) {
                          final option = question.options[index];
                          final isCorrectAnswer = option == correctAnswer;
                          final isSelected = selectedOption == option;
                          final isWrongAnswer =
                              isAnswerChecked && isSelected && !isCorrectAnswer;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: GestureDetector(
                              onTap: () {
                                if (!isAnswerChecked) {
                                  context
                                      .read<MCQCubit>()
                                      .selectAnswer(option, state);
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: isAnswerChecked
                                        ? (isCorrectAnswer
                                            ? [
                                                Colors.green[700]!,
                                                Colors.green[900]!
                                              ]
                                            : isWrongAnswer
                                                ? [
                                                    Colors.red[700]!,
                                                    Colors.red[900]!
                                                  ]
                                                : [
                                                    Colors.grey[800]!,
                                                    Colors.grey[900]!
                                                  ])
                                        : isSelected
                                            ? [
                                                Colors.blue[600]!,
                                                Colors.blue[900]!
                                              ]
                                            : [
                                                Colors.grey[800]!,
                                                Colors.grey[900]!
                                              ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: Text(
                                            String.fromCharCode(65 + index),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          option,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: selectedOption == null || isAnswerChecked
                              ? null
                              : () => handleAnswerCheck(state, selectedOption),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 24,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: const Text(
                            'Check Answer',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is MCQCompleted) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '🎉 Quiz Completed!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Correct Answers: ${state.correctAnswers}',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<RoadmapCubit>()
                            .fetchUnlockedDays(username!);
                        Navigator.pop(context, state.correctAnswers);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Back to Exercises',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is MCQError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }
            return const Center(
              child: Text(
                'No questions available.',
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }
}
