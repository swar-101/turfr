import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'features/auth/presentation/edit_profile_page.dart';
import 'features/auth/presentation/home_page.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/auth/providers.dart';

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
      if (update != null && update.latestVersion != '1.0.0') { // compare with current version
        await showUpdateDialog(context, update);
      }
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black87, // fallback for appbar
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        colorScheme: ColorScheme.dark(
          primary: Colors.purpleAccent.shade400,
          secondary: Colors.purpleAccent.shade200,
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
      },
    );
  }
}
class UpdateInfo {
  final String latestVersion;
  final String apkUrl;
  final String changelog;

  UpdateInfo({required this.latestVersion, required this.apkUrl, required this.changelog});

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      latestVersion: json['latestVersion'],
      apkUrl: json['apkUrl'],
      changelog: json['changelog'] ?? '',
    );
  }
}
Future<UpdateInfo?> fetchUpdateInfo() async {
  try {
    final url = Uri.parse('https://raw.githubusercontent.com/swar-101/turfr/main/update.json');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return UpdateInfo.fromJson(json.decode(response.body));
    }
  } catch (e) {
    debugPrint('Error fetching update info: $e');
  }
  return null;
}
Future<void> showUpdateDialog(BuildContext context, UpdateInfo update) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      title: const Text('Update Available'),
      content: Text('Version ${update.latestVersion} is available.\n\n${update.changelog}'),
      actions: [
        TextButton(
          onPressed: () async {
            final uri = Uri.parse(update.apkUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            }
          },
          child: const Text('Update Now'),
        ),
      ],
    ),
  );
}
