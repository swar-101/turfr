import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'current_friends_card.dart';
import 'discover_friends_list.dart';
import 'friend_requests_card.dart';

class SquadPage extends StatefulWidget {
  const SquadPage({super.key});

  @override
  State<SquadPage> createState() => _SquadPageState();
}

class _SquadPageState extends State<SquadPage> with TickerProviderStateMixin {
  late TabController _tabController;
  int _pendingRequestsCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPendingRequestsCount();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPendingRequestsCount() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    if (userDoc.exists) {
      final data = userDoc.data() ?? {};
      final requests = List<String>.from(data['friendRequests'] ?? []);
      setState(() {
        _pendingRequestsCount = requests.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Squad',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your kickmates and discover new players',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(25),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFFFF1744),
                borderRadius: BorderRadius.circular(25),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              tabs: [
                const Tab(text: 'Kickmates'),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: const Text('Requests'),
                      ),
                      if (_pendingRequestsCount > 0) ...[
                        const SizedBox(width: 4), // Reduced from 8 to 4
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2), // More compact padding
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF4500),
                            borderRadius:
                                BorderRadius.all(Radius.circular(8)), // Changed from circle to rounded rectangle
                          ),
                          child: Text(
                            '$_pendingRequestsCount',
                            style: const TextStyle(
                              fontSize: 10, // Reduced from 12 to 10
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Tab(text: 'Discover'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Friends Tab
                const SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: CurrentFriendsCard(),
                ),

                // Friend Requests Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: FriendRequestsCard(
                    onRequestCountChanged: (count) {
                      setState(() {
                        _pendingRequestsCount = count;
                      });
                    },
                  ),
                ),

                // Discover Tab
                const SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: DiscoverFriendsList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
