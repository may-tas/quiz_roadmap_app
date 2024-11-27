import 'package:exercise_roadmap_app/cubit/excercise_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExcerciseCubit extends Cubit<ExcerciseState> {
  ExcerciseCubit() : super(ExcerciseInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchExercisesForDay(String day) async {
    if (isClosed) return;
    emit(ExcerciseLoading());
    try {
      final snapshot = await _firestore
          .collection('roadmap')
          .doc(day)
          .collection('excercises')
          .get();
      final excercises =
          snapshot.docs.map((doc) => doc['title'] as String).toList();
      emit(ExcercisesLoaded(excercises));
    } catch (e) {
      emit(ExcerciseError("$e"));
    }
  }
}
