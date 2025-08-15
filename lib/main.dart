import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

import 'features/auth/presentation/edit_profile_page.dart';
import 'features/auth/presentation/home_page.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/me_page.dart';
import 'features/auth/providers/providers.dart';
import 'features/update/update_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MyApp()));
}

class AppInitializer extends StatefulWidget {
  final Widget child;
  const AppInitializer({Key? key, required this.child}) : super(key: key);

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    final result = await fetchUpdateInfo(); // now returns UpdateFetchResult
    final update = result.info;

    if (update != null) {
      final available = await isUpdateAvailable(update.latestVersion);
      if (available) {
        if (!_dialogShown && mounted) {
          _dialogShown = true;
          await showUpdateDialog(context, update);
        }
      } else {
        if (kDebugMode) {
          debugPrint('No update available. Current app is up to date.');
        }
      }
      return; // handled success path (either showed dialog or no update)
    }

    // if we reach here, fetching update info failed
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to check for updates.')),
    );

    // Developer-only helpful info
    if (kDebugMode) {
      final debugMsg = result.errorMessage ?? 'No update info returned';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Debug: $debugMsg')),
      );
      debugPrint('Update check details: status=${result.statusCode} snippet=${result.responseBodySnippet}');
    }
  }


  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    // material3 theme with dark mode and purple accent
    // brighter shade of purpleAccent for appBar
    // and black background for the app
    // using MaterialApp with debugShowCheckedModeBanner set to false
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purpleAccent,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Color(0xFFE1BEE7), // Brighter shade of purpleAccent
        ),
      ),
      home: authState.when(
        data: (user) => AppInitializer(
          child: user == null ? const LoginPage() : const HomePage(),
        ),
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      ),
      routes: {
        '/editProfile': (context) => const EditProfilePage(),
        '/login': (context) => const LoginPage(),
        '/me': (context) => const MePage(),
      },
    );
  }
}

Future<bool> isUpdateAvailable(String latestVersion) async {
  try {
    final packageInfo = await PackageInfo.fromPlatform();

    final currentVersionStr = packageInfo.buildNumber != '0'
        ? '${packageInfo.version}+${packageInfo.buildNumber}'
        : packageInfo.version;

    // Guard against malformed versions by catching parse errors.
    Version? current;
    Version? latest;
    try {
      current = Version.parse(currentVersionStr.split('+')[0]);
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to parse current version "$currentVersionStr": $e');
      return false;
    }
    try {
      latest = Version.parse(latestVersion.split('+')[0]);
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to parse latest version "$latestVersion": $e');
      return false;
    }

    if (latest == current && latestVersion.contains('+') && currentVersionStr.contains('+')) {
      final latestBuild = int.tryParse(latestVersion.split('+')[1]) ?? 0;
      final currentBuild = int.tryParse(currentVersionStr.split('+')[1]) ?? 0;
      return latestBuild > currentBuild;
    }

    return latest > current;
  } catch (e, st) {
    if (kDebugMode) debugPrint('isUpdateAvailable failed: $e\n$st');
    return false;
  }
}