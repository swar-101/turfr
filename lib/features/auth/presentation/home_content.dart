import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/user_repository.dart';

class HomeContent extends StatelessWidget {
  HomeContent({super.key});

  final UserRepository userRepository = UserRepository();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Center(child: Text('User not logged in'));
    }

    return StreamBuilder<Map<String, dynamic>>(
      stream: userRepository.watchUserProfile(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final userData = snapshot.data ?? {};
        final kickBits = userData['kickBits'] ?? 0;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 24),
            // const FriendListPreview(),
            // const KickOffMatchList(),
          ],
        );
      },
    );
  }
}
