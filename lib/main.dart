import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final update = await fetchUpdateInfo();
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      if (update != null && update.latestVersion != currentVersion) {
        await showUpdateDialog(context, update);
      }
    });

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
        data: (user) => user == null ? const LoginPage() : const HomePage(),
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
  final packageInfo = await PackageInfo.fromPlatform();

  final currentVersionStr = packageInfo.buildNumber != '0'
      ? '${packageInfo.version}+${packageInfo.buildNumber}'
      : packageInfo.version;

  final current = Version.parse(currentVersionStr.split('+')[0]);
  final latest = Version.parse(latestVersion.split('+')[0]);

  if (latest == current && latestVersion.contains('+') && currentVersionStr.contains('+')) {
    final latestBuild = int.tryParse(latestVersion.split('+')[1]) ?? 0;
    final currentBuild = int.tryParse(currentVersionStr.split('+')[1]) ?? 0;
    return latestBuild > currentBuild;
  }

  return latest > current;
}