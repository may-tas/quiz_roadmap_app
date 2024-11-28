import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exercise_roadmap_app/cubit/roadmap/roadmap_cubit.dart';
import 'package:exercise_roadmap_app/cubit/roadmap/roadmap_state.dart';
import 'package:exercise_roadmap_app/presentation/widgets/excercise_bottom_sheet.dart';
import 'package:exercise_roadmap_app/presentation/widgets/road_map_visualization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? username;
  late RoadmapCubit homeCubit;
  Map<String, String> dayTitles = {};

  @override
  void initState() {
    super.initState();
    homeCubit = BlocProvider.of<RoadmapCubit>(context);
    fetchDayTitles();
    logIn(context);
  }

  Future<void> fetchDayTitles() async {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('roadmap').get();

    setState(() {
      dayTitles = Map.fromEntries(snapshot.docs
          .map((doc) => MapEntry(doc.id, doc.get('title') as String)));
    });
  }

  void logIn(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username');
    context.read<RoadmapCubit>().fetchUnlockedDays(username!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30.0),
            Text(
              'Hey $username !',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: BlocBuilder<RoadmapCubit, RoadmapState>(
                bloc: homeCubit,
                builder: (context, state) {
                  if (state is RoadmapLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is RoadmapLoaded) {
                    return RoadmapVisualization(
                      dayTitles: dayTitles,
                      unlockedDays: state.unlockedDays,
                      onNodeTap: (day, dayIndex) {
                        showModalBottomSheet(
                          context: context,
                          isDismissible: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) {
                            return ExcerciseBottomSheet(
                              day: day,
                              dayIndex: dayIndex,
                            );
                          },
                        );
                      },
                    );
                  } else if (state is RoadmapError) {
                    return Center(
                        child: Text(state.message,
                            style: const TextStyle(color: Colors.white)));
                  } else {
                    return const Center(
                        child: Text('No data available.',
                            style: TextStyle(color: Colors.white)));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
