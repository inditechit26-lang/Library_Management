import 'package:flutter/material.dart';
import '../models/seat.dart';

class SeatSummary extends StatelessWidget {
  final List<Seat> seats;
  const SeatSummary({super.key, required this.seats});
  @override
  Widget build(BuildContext context) => GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: 2,
    crossAxisSpacing: 10,
    mainAxisSpacing: 10,
    childAspectRatio: 2.1,
    children: [
      _Stat(
        'Available seats',
        seats.where((s) => s.status == SeatStatus.available).length,
        Icons.auto_awesome,
        const Color(0xFF27916D),
        const Color(0xFFE8F6F0),
      ),
      _Stat(
        'Occupied seats',
        seats.where((s) => s.status == SeatStatus.occupied).length,
        Icons.people_outline,
        const Color(0xFF5B55CB),
        const Color(0xFFF0EFFF),
      ),
      _Stat(
        'Reserved seats',
        seats.where((s) => s.status == SeatStatus.reserved).length,
        Icons.schedule,
        const Color(0xFFAD813F),
        const Color(0xFFF9F1E5),
      ),
      _Stat(
        'Total seats',
        seats.length,
        Icons.grid_view_outlined,
        const Color(0xFF656A7A),
        const Color(0xFFF0F1F5),
      ),
    ],
  );
}

class _Stat extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color color, bg;
  const _Stat(this.label, this.count, this.icon, this.color, this.bg);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE4E7EF)),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 21,
                  height: 1,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(fontSize: 9, color: Color(0xFF999EAD)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
