import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String phone;
  final String photoUrl;
  final int passing;
  final int dribbling;
  final int shooting;
  final int defending;
  final double skillLevel;
  final List<String> gallery;

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.photoUrl,
    required this.passing,
    required this.dribbling,
    required this.shooting,
    required this.defending,
    required this.skillLevel,
    required this.gallery,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    double skillLevelValue = 0.0;
    if (data['skillLevel'] != null) {
      if (data['skillLevel'] is int) {
        skillLevelValue = (data['skillLevel'] as int).toDouble();
      } else if (data['skillLevel'] is double) {
        skillLevelValue = data['skillLevel'];
      }
    }
    List<String> galleryList = [];
    if (data['gallery'] != null && data['gallery'] is List) {
      galleryList = List<String>.from(data['gallery']);
    }
    return User(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      passing: data['passing'] ?? 0,
      dribbling: data['dribbling'] ?? 0,
      shooting: data['shooting'] ?? 0,
      defending: data['defending'] ?? 0,
      skillLevel: skillLevelValue,
      gallery: galleryList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,
      'passing': passing,
      'dribbling': dribbling,
      'shooting': shooting,
      'defending': defending,
      'skillLevel': skillLevel,
      'gallery': gallery,
    };
  }
}

class UserService {
  final usersRef = FirebaseFirestore.instance.collection('users');

  Future<User?> getUser(String id) async {
    final doc = await usersRef.doc(id).get();
    if (!doc.exists) return null;
    return User.fromFirestore(doc);
  }

  Future<void> setUser(User user) async {
    await usersRef.doc(user.id).set(user.toMap());
  }

  Future<List<User>> getAllUsers() async {
    final query = await usersRef.get();
    return query.docs.map((doc) => User.fromFirestore(doc)).toList();
  }
}
