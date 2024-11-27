import 'package:exercise_roadmap_app/cubit/roadmap_cubit.dart';
import 'package:exercise_roadmap_app/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();

  LoginScreen({super.key});

  Future<void> _saveUsername(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String username = _usernameController.text.trim();
    if (username.isNotEmpty) {
      await prefs.setString('username', username);

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Enter Username'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _saveUsername(context),
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
