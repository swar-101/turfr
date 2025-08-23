import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';

class SkillRadarGraph extends StatelessWidget {
  final int defending;
  final int shooting;
  final int passing;
  const SkillRadarGraph({
    super.key,
    required this.defending,
    required this.shooting,
    required this.passing,
  });

  @override
  Widget build(BuildContext context) {
    const ticks = [1, 2, 3, 4, 5];
    final data = [
      [defending.toDouble(), shooting.toDouble(), passing.toDouble()],
    ];
    return SizedBox(
      width: 100,
      height: 100,
      child: RadarChart(
        ticks: ticks,
        features: const ['Def', 'Sht', 'Pas'],
        data: data,
        graphColors: const [Colors.blue],
        outlineColor: Colors.grey,
        axisColor: Colors.grey,
        featuresTextStyle: const TextStyle(fontSize: 10),
      ),
    );
  }
}

