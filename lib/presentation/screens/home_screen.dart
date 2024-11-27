import 'package:exercise_roadmap_app/cubit/roadmap_cubit.dart';
import 'package:exercise_roadmap_app/cubit/roadmap_state.dart';
import 'package:exercise_roadmap_app/presentation/widgets/excercise_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String? username;
  late RoadmapCubit homeCubit;
  @override
  void initState() {
    super.initState();
    homeCubit = BlocProvider.of<RoadmapCubit>(context);

    logIn(context);
  }

  void logIn(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username');
    context.read<RoadmapCubit>().fetchUnlockedDays(username!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Roadmap')),
      body: BlocBuilder<RoadmapCubit, RoadmapState>(
        bloc: homeCubit,
        builder: (context, state) {
          if (state is RoadmapLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is RoadmapLoaded) {
            return ListView.builder(
              itemCount: 6,
              itemBuilder: (context, index) {
                String day = 'day${index + 1}';
                final List<String> unlockedDays = state.unlockedDays;
                bool isUnlocked = unlockedDays.contains(day);

                return ListTile(
                  title: Text(
                    day,
                    style: TextStyle(
                      color: isUnlocked ? Colors.black : Colors.grey,
                    ),
                  ),
                  trailing: isUnlocked
                      ? Icon(Icons.check_circle, color: Colors.green)
                      : Icon(Icons.lock, color: Colors.red),
                  onTap: isUnlocked
                      ? () {
                          showModalBottomSheet(
                            context: context,
                            isDismissible: true,
                            builder: (context) {
                              return ExcerciseBottomSheet(
                                day: day,
                                dayIndex: index + 1,
                              );
                            },
                          );
                        }
                      : null,
                );
              },
            );
          } else if (state is RoadmapError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: Text('No data available.'));
          }
        },
      ),
    );
  }
}
