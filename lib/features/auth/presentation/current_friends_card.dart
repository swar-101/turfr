import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CurrentFriendsCard extends StatelessWidget {
  const CurrentFriendsCard({super.key});

  Future<List<Map<String, dynamic>>> _fetchFriends() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return [];
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
    final data = userDoc.data() ?? {};
    final friends = List<String>.from(data['friends'] ?? []);
    if (friends.isEmpty) return [];
    final friendDocs = await Future.wait(friends.map((uid) => FirebaseFirestore.instance.collection('users').doc(uid).get()));
    return friendDocs.map((doc) {
      final d = doc.data() ?? {};
      return {
        'uid': doc.id,
        'displayName': d['displayName'] ?? 'user',
        'email': d['email'] ?? '',
        'skills': d['skills'] ?? {'defending': 0, 'shooting': 0, 'passing': 0},
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent, // Allow gradient background to show
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your Friends', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchFriends(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final friends = snapshot.data!;
                if (friends.isEmpty) {
                  return const Text('No friends yet.');
                }
                return SizedBox(
                  height: 200, // Adjust height as needed for your UI
                  child: ListView.builder(
                    itemCount: friends.length,
                    itemBuilder: (context, index) {
                      final friend = friends[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: const AssetImage('assets/images/user-default-icon.png'),
                        ),
                        title: Text(friend['displayName']),
                        subtitle: Text(friend['email']),
                        trailing: Text('Skills: D ${friend['skills']['defending']}, S ${friend['skills']['shooting']}, P ${friend['skills']['passing']}'),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
