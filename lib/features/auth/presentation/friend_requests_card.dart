import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendRequestsCard extends StatefulWidget {
  final Function(int) onRequestCountChanged;

  const FriendRequestsCard({
    super.key,
    required this.onRequestCountChanged,
  });

  @override
  State<FriendRequestsCard> createState() => _FriendRequestsCardState();
}

class _FriendRequestsCardState extends State<FriendRequestsCard> {
  bool _isRefreshing = false;
  List<Map<String, dynamic>> _requests = [];

  @override
  void initState() {
    super.initState();
    _loadFriendRequests();
  }

  Future<void> _loadFriendRequests() async {
    final requests = await _fetchFriendRequests();
    if (mounted) {
      setState(() {
        _requests = requests;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchFriendRequests() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return [];

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    if (!userDoc.exists) return [];

    final data = userDoc.data() ?? {};
    final requestIds = List<String>.from(data['friendRequests'] ?? []);

    if (requestIds.isEmpty) {
      widget.onRequestCountChanged(0);
      return [];
    }

    final requestDocs = await Future.wait(
      requestIds.map((uid) =>
        FirebaseFirestore.instance.collection('users').doc(uid).get()
      )
    );

    final requests = requestDocs
        .where((doc) => doc.exists)
        .map((doc) {
          final d = doc.data() ?? {};
          return {
            'uid': doc.id,
            'displayName': d['displayName'] ?? 'Unknown User',
            'email': d['email'] ?? '',
            'skills': d['skills'] ?? {'defending': 0, 'shooting': 0, 'passing': 0},
          };
        }).toList();

    widget.onRequestCountChanged(requests.length);
    return requests;
  }

  Future<void> _refreshRequests() async {
    setState(() {
      _isRefreshing = true;
    });

    // Reload the requests
    await _loadFriendRequests();

    // Add a small delay to show the refresh indicator
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  Future<void> _acceptFriendRequest(String requesterId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final batch = FirebaseFirestore.instance.batch();

    // Add to both users' friends lists
    final currentUserRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid);
    final requesterRef = FirebaseFirestore.instance
        .collection('users')
        .doc(requesterId);

    batch.update(currentUserRef, {
      'friends': FieldValue.arrayUnion([requesterId]),
      'friendRequests': FieldValue.arrayRemove([requesterId]),
    });

    batch.update(requesterRef, {
      'friends': FieldValue.arrayUnion([currentUser.uid]),
      'sentFriendRequests': FieldValue.arrayRemove([currentUser.uid]),
    });

    await batch.commit();
    _loadFriendRequests(); // Reload requests after accepting
  }

  Future<void> _declineFriendRequest(String requesterId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final batch = FirebaseFirestore.instance.batch();

    final currentUserRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid);
    final requesterRef = FirebaseFirestore.instance
        .collection('users')
        .doc(requesterId);

    batch.update(currentUserRef, {
      'friendRequests': FieldValue.arrayRemove([requesterId]),
    });

    batch.update(requesterRef, {
      'sentFriendRequests': FieldValue.arrayRemove([currentUser.uid]),
    });

    await batch.commit();
    _loadFriendRequests(); // Reload requests after declining
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
              const Color(0xFFFF1744).withValues(alpha: 0.1),
              Colors.black.withValues(alpha: 0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFFF1744).withValues(alpha: 0.3),
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
                        Icons.person_add,
                        color: const Color(0xFFFF1744),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Kickmate Requests',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: _isRefreshing ? null : _refreshRequests,
                    icon: _isRefreshing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFFF1744),
                            ),
                          )
                        : const Icon(
                            Icons.refresh,
                            color: Color(0xFFFF1744),
                            size: 20,
                          ),
                    tooltip: 'Refresh requests',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildRequestsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestsList() {
    // No loading spinner - just show content or empty state
    if (_requests.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.inbox,
              size: 48,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No pending kickmate requests',
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
      itemCount: _requests.length,
      separatorBuilder: (context, index) => const Divider(
        color: Colors.white24,
        height: 1,
      ),
      itemBuilder: (context, index) {
        final request = _requests[index];
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
                      request['displayName'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      request['email'],
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Skills: D ${request['skills']['defending']}, S ${request['skills']['shooting']}, P ${request['skills']['passing']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _acceptFriendRequest(request['uid']),
                    icon: const Icon(Icons.check_circle),
                    color: const Color(0xFF4CAF50),
                    tooltip: 'Accept',
                  ),
                  IconButton(
                    onPressed: () => _declineFriendRequest(request['uid']),
                    icon: const Icon(Icons.cancel),
                    color: const Color(0xFFFF5722),
                    tooltip: 'Decline',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
