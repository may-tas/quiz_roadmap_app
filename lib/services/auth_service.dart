import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> registerUser(
    String email,
    String password,
    String username,
  ) async {
    try {
      // Register the user with Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        // Initialize the Firestore document for the user
        await _firestore.collection('users').doc(username).set({
          'progress': {
            'day1': {
              'excercise1': false,
              'excercise2': false,
              'excercise3': false,
            },
            'day2': {
              'excercise1': false,
              'excercise2': false,
            },
            'day3': {
              'excercise1': false,
              'excercise2': false,
            },
            'day4': {
              'excercise1': false,
              'excercise2': false,
            },
            'day5': {
              'excercise1': false,
              'excercise2': false,
            },
            'day6': {
              'excercise1': false,
              'excercise2': false,
              'excercise3': false,
            },
          }, // Initialize progress as empty
          'unlockedDays': ['day1'], // Start with day1 unlocked
        });

        log("User registered and Firestore initialized successfully!");
      }
    } catch (e) {
      log("Error during registration: $e");
    }
  }
}
