import 'package:flutter/material.dart';

class SeatStatusLegend extends StatelessWidget {
  const SeatStatusLegend({super.key});
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 16,
    runSpacing: 10,
    children: const [
      _Item('Paid', Color(0xFF28A176)),
      _Item('Expiring', Color(0xFFF19A38)),
      _Item('Pending', Color(0xFFE35353)),
      _Item('Available', Color(0xFFD9DCE3)),
      _Item('Maintenance', Color(0xFF697080)),
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
