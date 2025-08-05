import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class KickBitsCard extends StatelessWidget {
  final int balance;

  const KickBitsCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/images/kickbit.svg',

              height: 30,
              width: 30,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'kickbits',
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
