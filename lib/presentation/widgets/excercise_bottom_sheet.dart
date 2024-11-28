import 'package:exercise_roadmap_app/cubit/excercise/excercise_cubit.dart';
import 'package:exercise_roadmap_app/cubit/excercise/excercise_state.dart';
import 'package:exercise_roadmap_app/presentation/screens/mcq_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExcerciseBottomSheet extends StatefulWidget {
  final String day;
  final int dayIndex;
  const ExcerciseBottomSheet(
      {super.key, required this.day, required this.dayIndex});

  @override
  State<ExcerciseBottomSheet> createState() => _ExcerciseBottomSheetState();
}

class _ExcerciseBottomSheetState extends State<ExcerciseBottomSheet> {
  String? selectedExercise;
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    context.read<ExcerciseCubit>().fetchExercisesForDay(widget.day);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16.0),
          const Icon(
            Icons.drag_handle_rounded,
            color: Colors.grey,
            size: 40,
          ),
          const SizedBox(height: 8.0),
          const Text(
            'Choose Exercise',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: BlocBuilder<ExcerciseCubit, ExcerciseState>(
              builder: (context, state) {
                if (state is ExcerciseLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ExcercisesLoaded) {
                  final excercises = state.excercises;
                  return ListView.builder(
                    itemCount: excercises.length,
                    itemBuilder: (context, index) {
                      final excercise = excercises[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedExercise = excercise;
                              selectedIndex = index + 1;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 12.0),
                            decoration: BoxDecoration(
                              color: selectedExercise == excercise
                                  ? const Color(0xFF5D5FEF)
                                  : const Color(0xFF292929),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Text(
                              excercise,
                              style: TextStyle(
                                color: selectedExercise == excercise
                                    ? Colors.white
                                    : const Color(0xFFBDBDBD),
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else if (state is ExcerciseError) {
                  return Center(child: Text(state.message));
                }
                return const Center(child: Text('No exercises found.'));
              },
            ),
          ),
          const SizedBox(height: 16.0),
          if (selectedExercise != null)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MCQScreen(
                      excercise: selectedExercise!,
                      day: widget.day,
                      excerciseIndex: selectedIndex!,
                      dayIndex: widget.dayIndex,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5D5FEF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 32.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text(
                'Start Practice',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}
