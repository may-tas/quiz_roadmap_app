import 'package:exercise_roadmap_app/cubit/roadmap_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:exercise_roadmap_app/cubit/mcq_cubit.dart';
import 'package:exercise_roadmap_app/cubit/mcq_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MCQScreen extends StatefulWidget {
  final String excercise;
  final String day;
  final int excerciseIndex;
  final int dayIndex;

  const MCQScreen(
      {super.key,
      required this.excercise,
      required this.day,
      required this.excerciseIndex,
      required this.dayIndex});

  @override
  State<MCQScreen> createState() => _MCQScreenState();
}

class _MCQScreenState extends State<MCQScreen> {
  late MCQCubit mcqCubit;
  late String? username;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz: ${widget.excercise}')),
      body: BlocBuilder<MCQCubit, MCQState>(
        bloc: mcqCubit,
        builder: (context, state) {
          if (state is MCQLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MCQLoaded) {
            final question = state.questions[state.currentQuestionIndex];
            final selectedOption = state.selectedOption;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.question,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ...question.options.map<Widget>((option) {
                    return GestureDetector(
                      onTap: () {
                        context.read<MCQCubit>().selectAnswer(option, state);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        decoration: BoxDecoration(
                          color: selectedOption == question.answer
                              ? Colors.green[300]
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: selectedOption == question.answer
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ),
                        child: Text(option),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  if (selectedOption != null)
                    ElevatedButton(
                      onPressed: () {
                        final isCorrect = selectedOption == question.answer;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isCorrect
                                  ? "Congrats! Correct Answer!"
                                  : "Wrong Answer!",
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                        context.read<MCQCubit>().checkAnswer(state, widget.day,
                            widget.excerciseIndex, widget.dayIndex);
                      },
                      child: const Text('Check Answer'),
                    ),
                ],
              ),
            );
          } else if (state is MCQCompleted) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Quiz Completed!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text('Correct Answers: ${state.correctAnswers}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<RoadmapCubit>().fetchUnlockedDays(username!);
                      Navigator.pop(context, state.correctAnswers);
                    },
                    child: const Text('Back to Exercises'),
                  ),
                ],
              ),
            );
          } else if (state is MCQError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No questions available.'));
        },
      ),
    );
  }
}
