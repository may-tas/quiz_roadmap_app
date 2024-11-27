import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Listen to user progress updates
  Stream<Map<String, dynamic>> listenToUserProgress(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) => snapshot.data()?['progress'] ?? {});
  }

  // Fetch user progress
  Future<Map<String, dynamic>> fetchUserProgress(String userId) async {
    try {
      final DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('progress')) {
          return data['progress'] as Map<String, dynamic>;
        }
      }

      // Return an empty map if progress doesn't exist
      return {};
    } catch (e) {
      throw Exception('Failed to fetch user progress: $e');
    }
  }

  // Update user progress
  Future<void> updateProgress(
      String userId, String dayId, String exerciseId) async {
    try {
      final DocumentReference userRef =
          _firestore.collection('users').doc(userId);

      // Update the specific exercise as completed
      await userRef.set({
        'progress': {
          dayId: {exerciseId: true}
        }
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update progress: $e');
    }
  }
}
