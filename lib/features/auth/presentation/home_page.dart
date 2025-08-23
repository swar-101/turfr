// lib/features/auth/presentation/home_page.dart

import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'home_content.dart';
import '../../me_page.dart';
import 'current_friends_card.dart';
import 'discover_friends_list.dart';
import 'notification_list.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  bool _showDiscover = false;

  Widget _buildPage(int index) {
    if (index == 0) return _GradientPage(child: HomeContent()); // removed const
    if (index == 1) {
      return _GradientPage(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const CurrentFriendsCard(),
              const SizedBox(height: 24),
              Column(
                children: [
                  ElevatedButton(
                    child: Text(_showDiscover ? 'Hide Discover Friends' : 'Discover Friends'),
                    onPressed: () {
                      setState(() {
                        _showDiscover = !_showDiscover;
                      });
                    },
                  ),
                  if (_showDiscover) DiscoverFriendsList(), // removed const
                ],
              ),
              const SizedBox(height: 24),
              const NotificationList(), // Add notification list below friends card
            ],
          ),
        ),
      );
    }
    if (index == 2) return _GradientPage(child: _PlaceholderPage(title: 'Kickoff', backgroundColor: Colors.transparent));
    if (index == 3) return _GradientPage(child: _PlaceholderPage(title: 'Stats', backgroundColor: Colors.transparent));
    if (index == 4) return _GradientPage(child: MePage());
    return const SizedBox.shrink();
  }

  // Grain settings — tweak to taste:
  // grainOpacity: 0.03 - 0.12 is subtle; raise for stronger effect.
  // grainDensity: 0.3 - 1.0 (0.0 none, 1.0 denser)
  static const double grainOpacity = 0.09;
  static const double grainDensity = 0.9;
  static const int grainSeed = 42; // change to re-seed pattern

  // Dynamic indicator colors for navbar selection
  static final List<Color> navIndicatorColors = [
    Color(0xFF2979FF), // Home - Bright Blue
    Color(0xFFFF1744), // Squad - Bright Red
    Color(0xFFFF4500), // Kickoff - Fiery Orange
    Color(0xFF4FF6A8), // Stats - Bright Green
    Color(0xFFB57CF6), // Me - Lavender
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: _currentIndex == 4 ? null : AppBar(
        backgroundColor: navIndicatorColors[_currentIndex], // Dynamic color matches nav bar highlight blob
        elevation: 3,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        title: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: 0.13, // Subtle visibility
              child: Image.asset(
                'assets/images/hamburger_menu_net.png',
                height: 36,
                fit: BoxFit.contain,
              ),
            ),
            SvgPicture.asset(
              'assets/images/turfr_logo.svg',
              height: 36,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      drawer: _currentIndex == 4 ? null : Drawer(
        backgroundColor: Colors.black.withAlpha(160),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(32)),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Replace DrawerHeader with a custom Container for full control
            Container(
              padding: const EdgeInsets.only(top: 0, left: 0, right: 0, bottom: 0),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              height: 160, // Same as DrawerHeader default
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white,
                          Colors.transparent,
                        ],
                        stops: [0.6, 1.0], // Fade out at the bottom 40%
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: Opacity(
                      opacity: 0.13, // Subtle net effect
                      child: Image.asset(
                        'assets/images/hamburger_menu_net.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/images/turfr_logo.svg',
                        height: 48,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                      const SizedBox(height: 8),
                      FutureBuilder<PackageInfo>(
                        future: PackageInfo.fromPlatform(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const SizedBox(height: 12);
                          }
                          if (snapshot.hasError || !snapshot.hasData) {
                            return const Text(
                              'Version unavailable',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          }
                          return Text(
                            'v.${snapshot.data!.version}',
                            style: const TextStyle(
                              fontFamily: 'IBM3270',
                              color: Colors.white70,
                              fontSize: 16, // Increased for visibility
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // No divider, SizedBox, or Container between header and ListTiles
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white, size: 24),
              title: const Text('Settings', style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w300)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.white, size: 24),
              title: const Text('About', style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w300)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            ),
          ],
        ),
      ),

      // Stack: base green -> procedural grain -> subtle vignette -> content
      body: Stack(
        children: [
          // Remove tabColors background

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
                    Colors.black.withValues(alpha: 0.04),
                    Colors.black.withValues(alpha: 0.10),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // Main safe-area content
          SafeArea(
            child: _buildPage(_currentIndex), // Use dynamic page builder
          ),
        ],
      ),

      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          navigationBarTheme: NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
              return const TextStyle(
                fontWeight: FontWeight.w300, // Thinner than w400
                fontSize: 12,
                color: Colors.white,
              );
            }),
            indicatorColor: navIndicatorColors[_currentIndex],
            backgroundColor: Color(0xFF212121), // Match brighter gray in gradient
          ),
        ),
        child: NavigationBar(
          height: 60,
          backgroundColor: Color(0xFF212121), // Match brighter gray in gradient
          indicatorColor: navIndicatorColors[_currentIndex],
          selectedIndex: _currentIndex,
          onDestinationSelected: (int idx) => setState(() => _currentIndex = idx),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home, color: Colors.white),
              selectedIcon: const Icon(Icons.home, color: Colors.black),
              label: 'Home',
            ),
            NavigationDestination(
              icon: const Icon(Icons.groups_3, color: Colors.white),
              selectedIcon: const Icon(Icons.groups_3, color: Colors.black),
              label: 'Squad',
            ),
            NavigationDestination(
              icon: const Icon(Icons.local_fire_department, color: Colors.white),
              selectedIcon: const Icon(Icons.local_fire_department, color: Colors.black),
              label: 'Kickoff',
            ),
            NavigationDestination(
              icon: const Icon(Icons.bar_chart, color: Colors.white),
              selectedIcon: const Icon(Icons.bar_chart, color: Colors.black),
              label: 'Stats',
            ),
            NavigationDestination(
              icon: const Icon(Icons.person, color: Colors.white),
              selectedIcon: const Icon(Icons.person, color: Colors.black),
              label: 'Me',
            ),
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
      ..color = Colors.black.withValues(alpha: opacity)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    final Paint lightPaint = Paint()
      ..color = Colors.white.withValues(alpha: opacity * 0.35)
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
      final Paint blobPaint = Paint()..color = Colors.black.withValues(alpha: opacity * 1.2);
      canvas.drawCircle(Offset(x, y), radius, blobPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GrainPainter old) {
    // Grain is static; repaint only if params change.
    return old.seed != seed || old.opacity != opacity || old.density != density;
  }
}

/// Gradient overlay page - wraps content with a top-to-bottom gradient fade.
class _GradientPage extends StatelessWidget {
  final Widget child;
  const _GradientPage({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent, // Transparent at the top for AppBar translucency
            Colors.black, // Black at 75%
            Color(0xFF212121), // Dark grey at the bottom
          ],
          stops: [0.0, 0.75, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }
}

/// Generic placeholder page for other tabs
class _PlaceholderPage extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  const _PlaceholderPage({required this.title, this.backgroundColor = Colors.black, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Center(
        child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 20)),
      ),
    );
  }
}
