import 'package:flutter/material.dart';
import 'package:turfr_app/views/onboarding/welcome_screen.dart';

void main() {
  runApp(TurfrApp());
}

class TurfrApp extends StatelessWidget {
  const TurfrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Turfr',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: WelcomeScreen(),
    );
  }
}