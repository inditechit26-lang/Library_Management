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
      (
        'Total',
        seats.length,
        Icons.event_seat_outlined,
        const Color(0xFF5650C7),
      ),
      (
        'Available',
        seats.where((e) => e.status == SeatStatus.available).length,
        Icons.check_circle_outline,
        const Color(0xFF23876A),
      ),
      (
        'Occupied',
        seats.where((e) => e.status == SeatStatus.occupied).length,
        Icons.person_outline,
        const Color(0xFF5650C7),
      ),
      (
        'Full Time',
        students.where((e) => e.membership == MembershipType.fullTime).length,
        Icons.workspace_premium_outlined,
        const Color(0xFF8B6B34),
      ),
      (
        'Half Time',
        students.where((e) => e.membership == MembershipType.halfTime).length,
        Icons.schedule_outlined,
        const Color(0xFF667085),
      ),
      (
        'Pending',
        students.where((e) => e.payment != PaymentStatus.paid).length,
        Icons.payments_outlined,
        const Color(0xFFB8792A),
      ),
    ];
    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final item = items[i];
          return Container(
            width: 138,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EF)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x091D2340),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(item.$3, size: 19, color: item.$4),
                const Spacer(),
                Text(
                  '${item.$2}',
                  style: const TextStyle(
                    fontSize: 23,
                    height: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.$1,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF858B9D),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
