// lib/features/auth/presentation/home_page.dart

import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'home_content.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  static final List<Widget> _pages = <Widget>[
    HomeContent(),
    const _PlaceholderPage(title: 'Squad'),
    const _PlaceholderPage(title: 'Kickoff'),
    const _PlaceholderPage(title: 'Stats'),
    const _PlaceholderPage(title: 'Me'),
  ];

  // Grain settings — tweak to taste:
  // grainOpacity: 0.03 - 0.12 is subtle; raise for stronger effect.
  // grainDensity: 0.3 - 1.0 (0.0 none, 1.0 denser)
  static const double grainOpacity = 0.09;
  static const double grainDensity = 0.9;
  static const int grainSeed = 42; // change to re-seed pattern

  // Tab background colors for dark mode
  static final List<Color> tabColors = [
    const Color(0xFF07125C), // Deep blue for Home
    const Color(0xFF45080A), // Deep red for Squad
    const Color(0xFF6B3510), // Deep orange for Kickoff
    const Color(0xFF093015), // Deep green for Stats
    Colors.black,            // Me (default)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 3,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        title: SvgPicture.asset(
          'assets/images/turfr_logo.svg',
          height: 36,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 28),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.of(context).pushNamed('/editProfile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // TODO: Replace with your actual logout logic
              // Example: ref.read(authProvider.notifier).logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.black.withAlpha(160),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(32)),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/images/turfr_logo.svg',
                    height: 48,
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'v.1.0.32',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white, size: 28),
              title: const Text('Settings', style: TextStyle(fontSize: 18, color: Colors.white)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            ),
            ListTile(
              leading: const Icon(Icons.star, color: Colors.white, size: 28),
              title: const Text('Creator Options', style: TextStyle(fontSize: 18, color: Colors.white)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            ),
          ],
        ),
      ),

      // Stack: base green -> procedural grain -> subtle vignette -> content
      body: Stack(
        children: [
          // Dynamic background color based on selected tab
          Container(color: tabColors[_currentIndex]),

          // Procedural grain painter: no seams, adjustable density & opacity
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _GrainPainter(
                    seed: grainSeed,
                    opacity: grainOpacity,
                    density: grainDensity,
                  ),
                  isComplex: true,
                  willChange: false,
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),

          // Subtle vignette / granite overlay to deepen blacks and add depth
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.04),
                    Colors.black.withOpacity(0.10),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // Main safe-area content
          SafeArea(
            child: _pages[_currentIndex],
          ),
        ],
      ),

      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          // Remove BottomNavigationBarThemeData, not needed for NavigationBar
        ),
        child: NavigationBar(
          height: 60, // Reduced height for a less tall nav bar
          backgroundColor: Colors.black,
          indicatorColor: Theme.of(context).colorScheme.secondary,
          selectedIndex: _currentIndex,
          onDestinationSelected: (int idx) => setState(() => _currentIndex = idx),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.groups_3), label: 'Squad'),
            NavigationDestination(icon: Icon(Icons.local_fire_department), label: 'Kickoff'),
            NavigationDestination(icon: Icon(Icons.monitor), label: 'Stats'),
            NavigationDestination(icon: Icon(Icons.man), label: 'Me'),
          ],
        ),
      ),
    );
  }
}

/// Procedural grain painter - fast and seam-free.
/// Paints thousands of tiny points, black and white specks, to simulate film grain.
class _GrainPainter extends CustomPainter {
  final int seed;
  final double opacity; // overall alpha for the grain layer
  final double density; // 0.0..1.0 how dense the speckles are

  _GrainPainter({
    required this.seed,
    required this.opacity,
    required this.density,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Don't overdo it on tiny screens; scale number of points with area.
    final double area = size.width * size.height;
    // base factor: roughly one speck per X pixels. Tweak divisor for density range.
    final double baseDivisor = 1600.0; // higher = fewer specks
    final int specks = math.max(400, ((area / baseDivisor) * density).toInt());

    final rnd = math.Random(seed);
    final Paint darkPaint = Paint()
      ..color = Colors.black.withOpacity(opacity)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    final Paint lightPaint = Paint()
      ..color = Colors.white.withOpacity(opacity * 0.35)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    // Create two batches: dark specks (majority) and light specks (minor)
    final List<ui.Offset> darkPoints = List.generate(specks, (i) {
      return ui.Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height);
    });

    final int lightCount = (specks * 0.12).toInt();
    final List<ui.Offset> lightPoints = List.generate(lightCount, (i) {
      return ui.Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height);
    });

    // Draw with drawPoints which is fairly efficient
    canvas.drawPoints(ui.PointMode.points, darkPoints, darkPaint);
    canvas.drawPoints(ui.PointMode.points, lightPoints, lightPaint);

    // Add a few slightly larger irregular specks for variation
    final int blobs = math.max(6, (size.shortestSide / 60).toInt());
    for (int i = 0; i < blobs; i++) {
      final double x = rnd.nextDouble() * size.width;
      final double y = rnd.nextDouble() * size.height;
      final double radius = 0.6 + rnd.nextDouble() * 1.8;
      final Paint blobPaint = Paint()..color = Colors.black.withOpacity(opacity * 1.2);
      canvas.drawCircle(Offset(x, y), radius, blobPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GrainPainter old) {
    // Grain is static; repaint only if params change.
    return old.seed != seed || old.opacity != opacity || old.density != density;
  }
}

/// Generic placeholder page for other tabs
class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 20)));
  }
}
