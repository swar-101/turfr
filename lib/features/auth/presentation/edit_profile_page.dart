import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';

final userProfileProvider = StreamProvider.autoDispose<Map<String, dynamic>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  final userRepository = ref.watch(userRepositoryProvider);

  if (user == null) {
    return Stream.value({});
  }

  return userRepository.watchUserProfile(user.uid);
});

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late TextEditingController _displayNameController;

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: userProfileAsync.when(
        data: (profile) {
          _displayNameController = TextEditingController(text: profile['displayName'] ?? '');

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _displayNameController,
                  decoration: InputDecoration(labelText: 'Display Name'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final newName = _displayNameController.text.trim();
                    if (newName.isEmpty) return;

                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      await ref.read(userRepositoryProvider).updateUserProfile(user.uid, {
                        'displayName': newName,
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Profile updated!')),
                      );
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading profile')),
      ),
    );
  }
}
