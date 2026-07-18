import 'package:flutter/material.dart';

class SeatStatusLegend extends StatelessWidget {
  const SeatStatusLegend({super.key});
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 16,
    runSpacing: 10,
    children: const [
      _Item('Available', Color(0xFF23876A)),
      _Item('Occupied', Color(0xFF5650C7)),
      _Item('Reserved', Color(0xFFB8792A)),
      _Item('Maintenance', Color(0xFF73798A)),
      _Item('Blocked', Color(0xFFBE5660)),
    ],
  );
}

class _Item extends StatelessWidget {
  final String label;
  final Color color;
  const _Item(this.label, this.color);
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      CircleAvatar(radius: 4, backgroundColor: color),
      const SizedBox(width: 6),
      Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          color: Color(0xFF7E8495),
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
