import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart'; // <-- Added for SVG support
import 'package:turfr_app/features/auth/providers.dart';
import 'home_content.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 178),
        elevation: 0,
        title: SvgPicture.asset(
          'assets/images/turfr_logo.svg',
          height: 36, // Adjust size to your liking
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).pushNamed('/editProfile');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        child: SafeArea(
          child: HomeContent(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: 0, // default selection
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer), // ⚽ Home-ish
            label: 'Play',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups), // 👥 Social/Friends
            label: 'Squad',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flash_on), // ⚡ Action/Highlights
            label: 'Kick',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard), // 🏆 Leaderboard
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings), // ⚙️ Settings
            label: 'Tweak',
          ),
        ],
      ),
    );
  }
}
