import 'package:exercise_roadmap_app/cubit/roadmap_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late RoadmapCubit homeCubit;
  @override
  void initState() {
    super.initState();
    homeCubit = BlocProvider.of<RoadmapCubit>(context);

    logIn(context);
  }

  void logIn(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    context.read<RoadmapCubit>().fetchUnlockedDays(username!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Roadmap')),
      body: BlocBuilder<RoadmapCubit, List<String>>(
        bloc: homeCubit,
        builder: (context, unlockedDays) {
          return ListView.builder(
            itemCount: 6,
            itemBuilder: (context, index) {
              String day = 'day${index + 1}';
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
                        // Navigate to exercise screen
                      }
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
