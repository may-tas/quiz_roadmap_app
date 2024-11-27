import 'package:exercise_roadmap_app/cubit/excercise_cubit.dart';
import 'package:exercise_roadmap_app/cubit/excercise_state.dart';
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
  @override
  void initState() {
    super.initState();
    context.read<ExcerciseCubit>().fetchExercisesForDay(widget.day);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: MediaQuery.of(context).size.height * 0.6,
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
                return ListTile(
                  title: Text(excercise),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MCQScreen(
                                excercise: excercise,
                                day: widget.day,
                                excerciseIndex: index + 1,
                                dayIndex: widget.dayIndex)));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Clicked on $excercise')),
                    );
                  },
                );
              },
            );
          } else if (state is ExcerciseError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No exercises found.'));
        },
      ),
    );
  }
}
