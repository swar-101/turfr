import 'package:flutter/material.dart';

class KickBitsCard extends StatelessWidget {
  final int balance;

  const KickBitsCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.grey[900],  // Dark background, almost black
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Row(
          children: [
            Icon(Icons.sports_soccer, color: Colors.purpleAccent.shade200, size: 40), // Neon purple vibe
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KickBits',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purpleAccent.shade200, // Same neon purple
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Balance: $balance',
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
