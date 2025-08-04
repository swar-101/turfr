import 'package:flutter/material.dart';

class KickOffMatchList extends StatelessWidget {
  const KickOffMatchList({super.key});

  @override
  Widget build(BuildContext context) {
    final matches = [
      {
        'title': '5v5 at Turfr Arena',
        'location': 'Downtown Ground',
        'startsIn': 'Starts in 1h 30m'
      },
      {
        'title': '3v3 Quick KickOff',
        'location': 'Rooftop Turf',
        'startsIn': 'Starts in 45m'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upcoming KickOffs',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...matches.map((match) {
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: ListTile(
              title: Text(match['title']!),
              subtitle: Text('${match['location']!} • ${match['startsIn']!}'),
              trailing: const Icon(Icons.timer),
              onTap: () {
                // Stub: Navigate to match details
              },
            ),
          );
        }).toList(),
      ],
    );
  }
}