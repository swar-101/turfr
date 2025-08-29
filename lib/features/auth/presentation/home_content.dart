import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/user_repository.dart';
import '../../turf/providers/turf_provider.dart';
import '../../turf/presentation/widgets/turf_card.dart';
import '../../turf/presentation/turf_details_page.dart';
import '../../turf/presentation/add_turf_page.dart';
import '../../turf/presentation/widgets/location_selector_dialog.dart';
import 'squad_page.dart';

class HomeContent extends StatefulWidget {
  HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final UserRepository userRepository = UserRepository();

  Future<List<Map<String, dynamic>>> _fetchKickmates() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return [];

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
    final data = userDoc.data() ?? {};
    final friends = List<String>.from(data['friends'] ?? []);

    if (friends.isEmpty) return [];

    final friendDocs = await Future.wait(friends.map((uid) =>
        FirebaseFirestore.instance.collection('users').doc(uid).get()));

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

  @override
  void initState() {
    super.initState();
    // Initialize turf data when the home content loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final turfProvider = Provider.of<TurfProvider>(context, listen: false);
      turfProvider.loadRecommendedTurfs();
    });
  }

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
          padding: const EdgeInsets.all(0),
          children: [
            // Section: Recommended Turfs
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Make the title clickable for location selection
                Consumer<TurfProvider>(
                  builder: (context, turfProvider, child) {
                    return InkWell(
                      onTap: () {
                        if (turfProvider.availableLocations.isNotEmpty) {
                          _showLocationSelector(context, turfProvider);
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              turfProvider.locationDisplayTitle,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Consumer<TurfProvider>(
                    builder: (context, turfProvider, child) {
                      return Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              // Refresh turfs data
                              turfProvider.loadRecommendedTurfs();
                            },
                            icon: const Icon(Icons.refresh),
                            tooltip: 'Refresh Turfs',
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddTurfPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add_circle_outline),
                            tooltip: 'Add New Turf',
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
            Consumer<TurfProvider>(
              builder: (context, turfProvider, child) {
                if (turfProvider.isLoading) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (turfProvider.error != null) {
                  return SizedBox(
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: ${turfProvider.error}'),
                          ElevatedButton(
                            onPressed: () => turfProvider.loadRecommendedTurfs(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (turfProvider.recommendedTurfs.isEmpty) {
                  return SizedBox(
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.sports_soccer,
                            size: 48,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No turfs in Ulwe yet',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddTurfPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add First Turf'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SizedBox(
                  height: 220, // Increased from 200 to 220 to fix overflow
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: turfProvider.recommendedTurfs.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final turf = turfProvider.recommendedTurfs[index];
                      return TurfCard(
                        turf: turf,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TurfDetailsPage(turfId: turf.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            // Section: Upcoming Kickoffs (changed from Matches)
            SectionTitle(title: 'Upcoming Kickoffs'),
            SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sports_soccer,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No upcoming kickoffs',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to kickoff page when it's implemented
                        // For now, show a placeholder message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Kickoff feature coming soon!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Start New Kickoff'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Section: Your Kickmates
            SectionTitle(title: 'Your Kickmates'),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchKickmates(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return SizedBox(
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: ${snapshot.error}'),
                          ElevatedButton(
                            onPressed: () => setState(() {}),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final kickmates = snapshot.data ?? [];

                if (kickmates.isEmpty) {
                  return SizedBox(
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.group,
                            size: 48,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No Kickmates yet',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SquadPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.group_add),
                            label: const Text('Find Kickmates'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SizedBox(
                  height: 200,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: kickmates.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final mate = kickmates[index];
                      return KickMateCard(
                        name: mate['displayName'],
                        imagePath: 'assets/images/user-default-icon.png', // Use the existing default user icon
                        onTap: () {
                          // Navigate to KickMate details or chat
                        },
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }

  void _showLocationSelector(BuildContext context, TurfProvider turfProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LocationSelectorDialog(
          currentLocation: turfProvider.selectedLocation,
          availableLocations: turfProvider.availableLocations,
          onLocationSelected: (location) {
            turfProvider.setSelectedLocation(location);
          },
        );
      },
    );
  }
}

class MatchCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;
  const MatchCard({required this.title, required this.imagePath, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Material(
        color: colors.surfaceContainerHighest,
        elevation: 4,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.asset(
                  imagePath,
                  height: 110,
                  width: 150,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class KickMateCard extends StatelessWidget {
  final String name;
  final String imagePath;
  final VoidCallback onTap;
  const KickMateCard({required this.name, required this.imagePath, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Material(
        color: colors.surfaceContainerHighest,
        elevation: 4,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.asset(
                  imagePath,
                  height: 110,
                  width: 150,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
