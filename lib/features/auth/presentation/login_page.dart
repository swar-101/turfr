import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../providers.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );
    final commonPadding = const EdgeInsets.symmetric(vertical: 16);
    final commonTextStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SvgPicture.asset('assets/images/turfr_logo.svg', height: 120),
                  const SizedBox(height: 32),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => print('Sign In tapped'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent[700],
                      padding: commonPadding,
                      shape: buttonShape,
                      minimumSize: const Size.fromHeight(48),
                      tapTargetSize: MaterialTapTargetSize.padded,
                    ),
                    child: Text(
                      'Sign In',
                      style: commonTextStyle.copyWith(color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => print('Register tapped'),
                    child: const Text(
                      'Register Instead',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () async {
                      final repo = ref.read(authRepositoryProvider);
                      //   if (result != null) {
                      //     print("✅ User: ${result.user?.displayName}");
                      //   } else {
                      //     print("⚠️ Google sign-in was cancelled.");
                      //   }
                      // }
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text('Signing in with Google...'),
                        ),
                      );
                      final result = await repo.signInWithGoogle();
                      scaffoldMessenger.hideCurrentSnackBar();
                      if (result != null) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Welcome, ${result.user?.displayName}!',
                            ),
                          ),
                        );
                      } else {
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text("Sign-in was cancelled 😕"),
                          ),
                        );
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/images/google_logo.svg',
                          height: 20,
                          width: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Continue with Google',
                          style: commonTextStyle.copyWith(
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
