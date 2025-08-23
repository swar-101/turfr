import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddFriendList extends StatefulWidget {
  const AddFriendList({super.key});

  @override
  State<AddFriendList> createState() => _AddFriendListState();
}

class _AddFriendListState extends State<AddFriendList> {
  Future<void> _refresh() async {
    setState(() {}); // Triggers rebuild, StreamBuilder will re-listen
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Not signed in'));
    }
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final users = snapshot.data!.docs
            .where((doc) => doc.id != currentUser.uid)
            .toList(); // No filtering for debugging
        if (users.isEmpty) {
          return const Center(child: Text('No users found'));
        }
        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index].data() as Map<String, dynamic>;
              final uid = users[index].id;
              final username = user['displayName'] ?? 'Unknown';
              final email = user['email'] ?? 'No email';
              final rawData = user.toString();
              return ListTile(
                title: Text(username),
                subtitle: Text('Email: $email\nRaw: $rawData'),
                trailing: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  ),
                  child: const Text('Add Friend', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    await FirebaseFirestore.instance.collection('users').doc(uid).update({
                      'friendRequests': FieldValue.arrayUnion([currentUser.uid]),
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Friend request sent to $username')),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
