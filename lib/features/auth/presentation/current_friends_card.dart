import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CurrentFriendsCard extends StatefulWidget {
  const CurrentFriendsCard({super.key});

  @override
  State<CurrentFriendsCard> createState() => _CurrentFriendsCardState();
}

class _CurrentFriendsCardState extends State<CurrentFriendsCard> {
  bool _isRefreshing = false;

  Future<List<Map<String, dynamic>>> _fetchFriends() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return [];
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
    final data = userDoc.data() ?? {};
    final friends = List<String>.from(data['friends'] ?? []);
    if (friends.isEmpty) return [];
    final friendDocs = await Future.wait(friends.map((uid) => FirebaseFirestore.instance.collection('users').doc(uid).get()));
    return friendDocs.where((doc) => doc.exists).map((doc) {
      final d = doc.data() ?? {};
      return {
        'uid': doc.id,
        'displayName': d['displayName'] ?? 'user',
        'email': d['email'] ?? '',
        'skills': d['skills'] ?? {'defending': 0, 'shooting': 0, 'passing': 0},
      };
    }).toList();
  }

  Future<void> _refreshFriends() async {
    setState(() {
      _isRefreshing = true;
    });

    // Add a small delay to show the refresh indicator
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isRefreshing = false;
    });
  }

  Future<void> _removeFriend(String friendId, String friendName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Remove Kickmate', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to remove $friendName from your kickmates?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF1744)),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final batch = FirebaseFirestore.instance.batch();
      
      // Remove from both users' friends lists
      final currentUserRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
      final friendRef = FirebaseFirestore.instance.collection('users').doc(friendId);

      batch.update(currentUserRef, {
        'friends': FieldValue.arrayRemove([friendId]),
      });

      batch.update(friendRef, {
        'friends': FieldValue.arrayRemove([currentUser.uid]),
      });

      await batch.commit();
      setState(() {}); // Refresh the UI

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed $friendName from kickmates'),
            backgroundColor: const Color(0xFFFF1744),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF2979FF).withOpacity(0.1),
              Colors.black.withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF2979FF).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.groups,
                        color: const Color(0xFF2979FF),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Your Kickmates',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: _isRefreshing ? null : _refreshFriends,
                    icon: _isRefreshing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF2979FF),
                            ),
                          )
                        : const Icon(
                            Icons.refresh,
                            color: Color(0xFF2979FF),
                            size: 20,
                          ),
                    tooltip: 'Refresh kickmates',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchFriends(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(
                          color: Color(0xFF2979FF),
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(
                            Icons.group_add,
                            size: 48,
                            color: Colors.white.withOpacity(0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No kickmates yet',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start discovering players in the Discover tab!',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  final friends = snapshot.data!;
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: friends.length,
                    separatorBuilder: (context, index) => const Divider(
                      color: Colors.white24,
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final friend = friends[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: const AssetImage(
                                'assets/images/user-default-icon.png',
                              ),
                              backgroundColor: Colors.white.withOpacity(0.1),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    friend['displayName'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    friend['email'],
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      _SkillChip(
                                        label: 'D',
                                        value: friend['skills']['defending'],
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 4),
                                      _SkillChip(
                                        label: 'S',
                                        value: friend['skills']['shooting'],
                                        color: Colors.red,
                                      ),
                                      const SizedBox(width: 4),
                                      _SkillChip(
                                        label: 'P',
                                        value: friend['skills']['passing'],
                                        color: Colors.green,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, color: Colors.white),
                              color: Colors.grey[800],
                              onSelected: (value) {
                                if (value == 'remove') {
                                  _removeFriend(friend['uid'], friend['displayName']);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'remove',
                                  child: Row(
                                    children: [
                                      Icon(Icons.person_remove, color: Colors.red, size: 20),
                                      SizedBox(width: 8),
                                      Text('Remove Kickmate', style: TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _SkillChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5), width: 0.5),
      ),
      child: Text(
        '$label$value',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color.withOpacity(0.9),
        ),
      ),
    );
  }
}
