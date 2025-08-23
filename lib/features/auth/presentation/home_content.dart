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
          padding: const EdgeInsets.all(0),
          children: [
            // Section: Recommended Turfs
            SectionTitle(title: 'Recommended Turfs'),
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 6,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  Turf turf;
                  if (index == 0) {
                    turf = Turf(
                      name: 'Urban Sports, Ulwe',
                      address: 'CP GOENKA INTERNATIONAL SCHOOL, X2JG+H2C, Sector 5, Ulwe, Wahal, Sector 5, Ulwe, Navi Mumbai, Maharashtra 410206',
                      imagePath: 'assets/images/turf/cp-1.png',
                      contactName: 'Kuldeep Pandey (Turf in-charge)',
                      contactNumber: '+91 9969911234',
                      priceDetails: '1800 for 8v8, 1200 for 6v6, 2000 for 9v9 (per hour)',
                      timings: '7 AM to 11 PM',
                    );
                  } else if (index == 1) {
                    turf = Turf(
                      name: 'Sample Turf 2',
                      address: 'Sample Address 2',
                      imagePath: 'assets/images/turf/cp-2.png',
                      contactName: 'Sample Contact',
                      contactNumber: '+91 9876543210',
                      priceDetails: '1500 for 8v8, 1000 for 6v6 (per hour)',
                      timings: '8 AM to 10 PM',
                    );
                  } else {
                    turf = Turf(
                      name: 'Turf ${index + 1}',
                      address: 'Address ${index + 1}',
                      imagePath: 'assets/images/home.png',
                      contactName: 'Contact ${index + 1}',
                      contactNumber: '1234567890',
                      priceDetails: '\u0024${(index + 1) * 10}',
                      timings: '10:00 AM - 10:00 PM',
                    );
                  }
                  return TurfCard(
                    turf: turf,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TurfDetailsPage(turf: turf),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            // Section: Upcoming Matches
            SectionTitle(title: 'Upcoming Matches'),
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 6,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) => MatchCard(
                  title: 'Match ${index + 1}',
                  imagePath: index == 0
                      ? 'assets/images/recommended_turf0.png'
                      : index == 1
                          ? 'assets/images/recommended_turf1.png'
                          : index == 2
                              ? 'assets/images/recommended_turf2.png'
                              : 'assets/images/kick-off.png',
                  onTap: () {},
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Section: Your KickMates
            SectionTitle(title: 'Your KickMates'),
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 6,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) => KickMateCard(
                  name: 'Mate ${index + 1}',
                  imagePath: index == 0
                      ? 'assets/images/recommended_turf0.png'
                      : index == 1
                          ? 'assets/images/recommended_turf1.png'
                          : index == 2
                              ? 'assets/images/recommended_turf2.png'
                              : 'assets/images/kick-mates.png',
                  onTap: () {},
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }
}

// Turf model to hold all metadata
class Turf {
  final String name;
  final String address;
  final String imagePath;
  final String contactName;
  final String contactNumber;
  final String priceDetails;
  final String timings;

  Turf({
    required this.name,
    required this.address,
    required this.imagePath,
    required this.contactName,
    required this.contactNumber,
    required this.priceDetails,
    required this.timings,
  });
}

// Modular card widgets below
class TurfCard extends StatelessWidget {
  final Turf turf;
  final VoidCallback onTap;
  const TurfCard({required this.turf, required this.onTap, super.key});

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
                  turf.imagePath,
                  height: 110,
                  width: 150,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  turf.name,
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

class TurfDetailsPage extends StatelessWidget {
  final Turf turf;
  const TurfDetailsPage({required this.turf, super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(turf.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                turf.imagePath,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text('Address:', style: Theme.of(context).textTheme.titleMedium),
            Text(turf.address, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            Text('Contact:', style: Theme.of(context).textTheme.titleMedium),
            Text('${turf.contactName} (${turf.contactNumber})', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            Text('Price:', style: Theme.of(context).textTheme.titleMedium),
            Text(turf.priceDetails, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            Text('Timings:', style: Theme.of(context).textTheme.titleMedium),
            Text(turf.timings, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
