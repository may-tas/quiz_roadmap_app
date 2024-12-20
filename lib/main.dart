import 'package:exercise_roadmap_app/cubit/excercise/excercise_cubit.dart';
import 'package:exercise_roadmap_app/cubit/mcq/mcq_cubit.dart';
import 'package:exercise_roadmap_app/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/roadmap/roadmap_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => RoadmapCubit(),
        ),
        BlocProvider(
          create: (context) => ExcerciseCubit(),
        ),
        BlocProvider(
          create: (context) => MCQCubit(),
        )
      ],
      child: MaterialApp.router(
        title: "Roadmap App",
        routerConfig: goRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
