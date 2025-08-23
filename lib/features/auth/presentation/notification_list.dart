import 'package:flutter/material.dart';

class NotificationList extends StatelessWidget {
  const NotificationList({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock notification data
    final notifications = [
      {
        'avatar': 'assets/images/user-default-icon.png',
        'type': 'friend',
        'sender': 'Alex',
        'message': 'You are now friends with Alex',
        'timestamp': 'Just now',
      },
      {
        'avatar': 'assets/images/user-default-icon.png',
        'type': 'system',
        'sender': 'System',
        'message': 'Welcome to the squad!',
        'timestamp': '10:01 AM',
      },
      {
        'avatar': 'assets/images/user-default-icon.png',
        'type': 'update',
        'sender': 'Coach',
        'message': 'Practice at 6 PM today.',
        'timestamp': '9:45 AM',
      },
      {
        'avatar': 'assets/images/user-default-icon.png',
        'type': 'friend',
        'sender': 'Jamie',
        'message': 'You are now friends with Jamie',
        'timestamp': 'Yesterday',
      },
      {
        'avatar': 'assets/images/user-default-icon.png',
        'type': 'teammate',
        'sender': 'Teammate',
        'message': 'Great game yesterday!',
        'timestamp': 'Yesterday',
      },
    ];

    return Container(
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Text('Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.white24),
            itemBuilder: (context, index) {
              final n = notifications[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundImage: AssetImage(n['avatar']!),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(fontSize: 15, color: Colors.white),
                              children: [
                                if (n['type'] == 'friend')
                                  const TextSpan(text: 'Update: ', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF1744))),
                                TextSpan(text: n['message'], style: const TextStyle(fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(n['timestamp']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
