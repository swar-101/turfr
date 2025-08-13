// lib/features/auth/presentation/home_page.dart

import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:turfr_app/features/auth/providers.dart';
import 'home_content.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
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
    Colors.blue.shade900,   // Home
    Colors.red.shade900,    // Squad
    Colors.orange.shade900, // Kickoff
    Colors.green.shade900,  // Stats
    Colors.black,           // Me (default)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withAlpha(160),
        elevation: 0,
        title: SvgPicture.asset(
          'assets/images/turfr_logo.svg',
          height: 36,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.of(context).pushNamed('/editProfile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
            },
          ),
        ],
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
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.black,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.black,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          enableFeedback: false,
          currentIndex: _currentIndex,
          onTap: (int idx) => setState(() => _currentIndex = idx),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.groups_3), label: 'Squad'),
            BottomNavigationBarItem(icon: Icon(Icons.local_fire_department), label: 'Kickoff'),
            BottomNavigationBarItem(icon: Icon(Icons.monitor), label: 'Stats'),
            BottomNavigationBarItem(icon: Icon(Icons.man), label: 'Me'),
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
