import 'package:flutter/material.dart';
import '../../students/models/student.dart';
import '../models/seat.dart';

class SeatSummaryCards extends StatelessWidget {
  final List<Seat> seats;
  final List<Student> students;
  const SeatSummaryCards({
    super.key,
    required this.seats,
    required this.students,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _Metric(
        'Total seats',
        seats.length,
        Icons.event_seat_outlined,
        const Color(0xFF625CDB),
      ),
      _Metric(
        'Occupied',
        seats.where((s) => s.status == SeatStatus.occupied).length,
        Icons.person_rounded,
        const Color(0xFF3975D5),
      ),
      _Metric(
        'Available',
        seats.where((s) => s.status == SeatStatus.available).length,
        Icons.check_rounded,
        const Color(0xFF279776),
      ),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C20243B),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            Expanded(child: _MetricItem(metric: items[index])),
            if (index != items.length - 1)
              Container(
                width: 1,
                height: 48,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
          ],
        ],
      ),
    );
  }
}

class _Metric {
  final String title;
  final int value;
  final IconData icon;
  final Color color;
  const _Metric(this.title, this.value, this.icon, this.color);
}

class _MetricItem extends StatelessWidget {
  final _Metric metric;
  const _MetricItem({required this.metric});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: metric.color.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(metric.icon, size: 15, color: metric.color),
            ),
            const SizedBox(width: 7),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: metric.value.toDouble()),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) => Text(
                '${value.round()}',
                style: const TextStyle(
                  fontSize: 24,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.8,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          metric.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ),
  );
}
