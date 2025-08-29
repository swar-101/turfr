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
  final Set<String> _pendingRequests = <String>{};

  Future<List<Map<String, dynamic>>> _fetchDiscoverableUsers() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return [];
    
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
    final data = userDoc.data() ?? {};
    final friends = List<String>.from(data['friends'] ?? []);
    final sentRequests = List<String>.from(data['sentFriendRequests'] ?? []);
    
    final allUsers = await FirebaseFirestore.instance.collection('users').get();
    return allUsers.docs
        .where((doc) => 
            doc.id != currentUser.uid && 
            !friends.contains(doc.id) &&
            !sentRequests.contains(doc.id))
        .map((doc) {
      final d = doc.data();
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

  Future<void> _sendFriendRequest(String targetUserId, String targetUserName) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() {
      _pendingRequests.add(targetUserId);
    });

    try {
      final batch = FirebaseFirestore.instance.batch();
      
      // Add to target user's friend requests
      final targetUserRef = FirebaseFirestore.instance.collection('users').doc(targetUserId);
      batch.update(targetUserRef, {
        'friendRequests': FieldValue.arrayUnion([currentUser.uid]),
      });

      // Track sent requests to avoid duplicates
      final currentUserRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
      batch.update(currentUserRef, {
        'sentFriendRequests': FieldValue.arrayUnion([targetUserId]),
      });

      await batch.commit();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Friend request sent to $targetUserName'),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send friend request: $e'),
            backgroundColor: const Color(0xFFFF5722),
          ),
        );
      }
    } finally {
      setState(() {
        _pendingRequests.remove(targetUserId);
      });
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
              const Color(0xFF4FF6A8).withValues(alpha: 0.1),
              Colors.black.withValues(alpha: 0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF4FF6A8).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.search,
                    color: const Color(0xFF4FF6A8),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Discover Players',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search by email or username',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                  prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.7)),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.1),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF4FF6A8), width: 2),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim();
                  });
                },
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchDiscoverableUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(
                          color: Color(0xFF4FF6A8),
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: Text(
                        'Failed to load users',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
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
                    return Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(
                            _searchQuery.isNotEmpty ? Icons.search_off : Icons.people_outline,
                            size: 48,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _searchQuery.isNotEmpty ? 'No users found' : 'No new players to discover',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: users.length,
                    separatorBuilder: (context, index) => const Divider(
                      color: Colors.white24,
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final isPending = _pendingRequests.contains(user['uid']);

                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: const AssetImage(
                                'assets/images/user-default-icon.png',
                              ),
                              backgroundColor: Colors.white.withValues(alpha: 0.1),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user['displayName'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user['email'],
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withValues(alpha: 0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      _SkillChip(
                                        label: 'D',
                                        value: user['skills']['defending'],
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 4),
                                      _SkillChip(
                                        label: 'S',
                                        value: user['skills']['shooting'],
                                        color: Colors.red,
                                      ),
                                      const SizedBox(width: 4),
                                      _SkillChip(
                                        label: 'P',
                                        value: user['skills']['passing'],
                                        color: Colors.green,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isPending
                                    ? Colors.grey.withValues(alpha: 0.5)
                                    : const Color(0xFFFF1744),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              onPressed: isPending
                                  ? null
                                  : () => _sendFriendRequest(
                                      user['uid'],
                                      user['displayName']
                                    ),
                              child: isPending
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'Add Friend',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
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
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Text(
        '$label$value',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}
