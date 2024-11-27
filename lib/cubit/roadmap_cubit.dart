import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoadmapCubit extends Cubit<List<String>> {
  RoadmapCubit() : super([]);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchUnlockedDays(String username) async {
    try {
      final userDoc = await _firestore.collection('users').doc(username).get();
      if (userDoc.exists) {
        List<String> unlockedDays = List<String>.from(userDoc['unlockedDays']);
        emit(unlockedDays);
      } else {
        emit([]);
      }
    } catch (e) {
      emit([]);
      print("Error fetching unlocked days: $e");
    }
  }
}
