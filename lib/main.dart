import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;

import 'features/auth/presentation/edit_profile_page.dart';
import 'features/auth/presentation/home_page.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/me_page.dart';
import 'features/auth/providers/providers.dart';
import 'features/turf/providers/turf_provider.dart';

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

    // Wrap the MaterialApp with MultiProvider to support both state management systems
    return provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider(create: (_) => TurfProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Color(0xFFB71C1C), // Unified grayish red for squad/discover friends
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
      ),
    );
  }
}
