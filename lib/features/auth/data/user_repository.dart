import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  final CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('users');

  Future<void> createUserIfNotExists(User firebaseUser) async {
    final userDoc = usersCollection.doc(firebaseUser.uid);
    final snapshot = await userDoc.get();
    if (!snapshot.exists) {
      await userDoc.set({
        'displayName': firebaseUser.displayName ?? 'user',
        'email': firebaseUser.email ?? '',
        'kickBits': 0,
        'skills': {
          'defending': 0,
          'shooting': 0,
          'passing': 0,
        },
        'friends': <String>[],
        'friendRequests': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Stream user profile data in real-time
  Stream<Map<String, dynamic>> watchUserProfile(String uid) {
    return usersCollection.doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      } else {
        return {};
      }
    });
  }

  // Update profile fields
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) {
    return usersCollection.doc(uid).update(data);
  }
}