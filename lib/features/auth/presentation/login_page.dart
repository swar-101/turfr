import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:turfr_app/features/auth/presentation/home_page.dart';

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
                    onPressed: () async {
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      final repo = ref.read(authRepositoryProvider);

                      try {
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(content: Text('Signing in with Google...')),
                        );

                        final result = await repo.signInWithGoogle();

                        scaffoldMessenger.hideCurrentSnackBar();

                        if (result != null) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(content: Text('Welcome, ${result.user?.displayName}!')),
                          );
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const HomePage()),
                          );
                        } else {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(content: Text("Sign-in was cancelled 😕")),
                          );
                        }
                      } catch (e, st) {
                        scaffoldMessenger.hideCurrentSnackBar();
                        scaffoldMessenger.showSnackBar(
                          SnackBar(content: Text('Error during sign-in: $e')),
                        );
                        print('Sign-in error: $e');
                        print(st);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: commonPadding,
                      shape: buttonShape,
                      minimumSize: const Size.fromHeight(48),
                    ),
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
                          style: commonTextStyle.copyWith(color: Colors.black),
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