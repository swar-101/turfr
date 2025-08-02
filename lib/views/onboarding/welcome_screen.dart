import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sports_soccer, size: 100, color: Colors.green[700]),
              SizedBox(height: 32),
              Text(
                'Welcome to Turfr',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Manage your local football matches with ease.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
              SizedBox(height: 48),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/createProfile'),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                  child: Text('Get Started', style: TextStyle(fontSize: 20)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
