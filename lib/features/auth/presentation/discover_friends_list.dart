import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DiscoverFriendsList extends StatefulWidget {
  const DiscoverFriendsList({super.key});

  @override
  State<DiscoverFriendsList> createState() => _DiscoverFriendsListState();
}

class _DiscoverFriendsListState extends State<DiscoverFriendsList> {
  String _searchQuery = '';

  Future<List<Map<String, dynamic>>> _fetchDiscoverableUsers() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return [];
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
    final data = userDoc.data() ?? {};
    final friends = List<String>.from(data['friends'] ?? []);
    final allUsers = await FirebaseFirestore.instance.collection('users').get();
    return allUsers.docs.where((doc) => doc.id != currentUser.uid && !friends.contains(doc.id)).map((doc) {
      final d = doc.data() as Map<String, dynamic>;
      final skills = d['skills'] is Map<String, dynamic> ? Map<String, dynamic>.from(d['skills']) : {};
      return {
        'uid': doc.id,
        'displayName': d['displayName'] ?? 'user',
        'email': d['email'] ?? '',
        'skills': {
          'defending': skills['defending'] ?? 0,
          'shooting': skills['shooting'] ?? 0,
          'passing': skills['passing'] ?? 0,
        },
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFB71C1C).withOpacity(0.08), // Grayish red background
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Discover Friends', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search by email or username',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
              },
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchDiscoverableUsers(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var users = snapshot.data!;
                if (_searchQuery.isNotEmpty) {
                  final query = _searchQuery.toLowerCase();
                  users = users.where((user) =>
                    user['displayName'].toString().toLowerCase().contains(query) ||
                    user['email'].toString().toLowerCase().contains(query)
                  ).toList();
                }
                if (users.isEmpty) {
                  return const Text('No users found.');
                }
                return SizedBox(
                  height: 300, // Adjust height as needed for your UI
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: const AssetImage('assets/images/user-default-icon.png'),
                        ),
                        title: Text(user['displayName'], style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text(user['email'], style: const TextStyle(fontSize: 13, color: Colors.grey)),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF1744), // Squad accent color
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          child: const Text('Add Friend'),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Send Friend Request'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(user['displayName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text(user['email']),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      child: const Text('Cancel'),
                                      onPressed: () => Navigator.of(context).pop(),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFFF1744),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      ),
                                      child: const Text('Confirm Request'),
                                      onPressed: () async {
                                        final currentUser = FirebaseAuth.instance.currentUser;
                                        if (currentUser == null) return;
                                        await FirebaseFirestore.instance.collection('users').doc(user['uid']).update({
                                          'friendRequests': FieldValue.arrayUnion([currentUser.uid]),
                                        });
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Friend request sent to ${user['displayName']}')),
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
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
