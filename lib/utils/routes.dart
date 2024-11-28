import 'package:exercise_roadmap_app/presentation/screens/home_screen.dart';
import 'package:exercise_roadmap_app/presentation/screens/login_screen.dart';
import 'package:exercise_roadmap_app/presentation/screens/register_user_screen.dart';
import 'package:go_router/go_router.dart';

final GoRouter goRouter = GoRouter(
  initialLocation: '/register',
  routes: [
    GoRoute(
      path: '/register',
      builder: (context, state) {
        return const RegisterScreen();
      },
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) {
        return const HomeScreen();
      },
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) {
        return const LoginScreen();
      },
    ),
  ],
);
