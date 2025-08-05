import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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