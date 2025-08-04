import 'package:flutter/material.dart';

class FriendListPreview extends StatelessWidget {
  const FriendListPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final friends = [
      {'name': 'Leo Messi', 'avatar': '👑'},
      {'name': 'Neymar Jr', 'avatar': '🎩'},
      {'name': 'Luis Suárez', 'avatar': '🦷'},
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Friends',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...friends.map((friend) {
              return ListTile(
                leading: CircleAvatar(
                  child: Text(friend['avatar']!),
                  backgroundColor: Colors.green[100],
                ),
                title: Text(friend['name']!),
                trailing: const Icon(Icons.chat_bubble_outline),
                onTap: () {
                  // Stub for future: open chat or profile
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}