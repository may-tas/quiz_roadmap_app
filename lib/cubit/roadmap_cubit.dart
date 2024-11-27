import 'package:exercise_roadmap_app/cubit/roadmap_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoadmapCubit extends Cubit<RoadmapState> {
  RoadmapCubit() : super(RoadmapInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchUnlockedDays(String username) async {
    if (isClosed) return;
    emit(RoadmapLoading());
    try {
      final snapshot = await _firestore.collection('users').doc(username).get();
      final data = snapshot.data();
      final unlockedDays = List<String>.from(data?['unlockedDays'] ?? []);
      emit(RoadmapLoaded(unlockedDays));
    } catch (e) {
      emit(RoadmapError("Error fetching unlocked days: $e"));
    }
  }
}
