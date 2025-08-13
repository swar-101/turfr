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

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.photoUrl,
    required this.passing,
    required this.dribbling,
    required this.shooting,
    required this.defending,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      passing: data['passing'] ?? 0,
      dribbling: data['dribbling'] ?? 0,
      shooting: data['shooting'] ?? 0,
      defending: data['defending'] ?? 0,
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
