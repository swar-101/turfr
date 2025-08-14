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
                itemBuilder: (context, index) => TurfCard(
                  title: 'Turf ${index + 1}',
                  imagePath: index == 0
                      ? 'assets/images/recommended_turf0.png'
                      : index == 1
                          ? 'assets/images/recommended_turf1.png'
                          : index == 2
                              ? 'assets/images/recommended_turf2.png'
                              : 'assets/images/home.png',
                  onTap: () {},
                ),
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

// Modular card widgets below
class TurfCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;
  const TurfCard({required this.title, required this.imagePath, required this.onTap, super.key});

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
