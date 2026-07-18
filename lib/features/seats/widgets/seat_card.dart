import 'package:flutter/material.dart';
import '../../students/models/student.dart';
import '../models/seat.dart';

class SeatCard extends StatelessWidget {
  final Seat seat;
  final Student? student;
  final VoidCallback onTap;
  const SeatCard({
    super.key,
    required this.seat,
    required this.onTap,
    this.student,
  });
  Color get color => switch (seat.status) {
    SeatStatus.available => const Color(0xFF36A47E),
    SeatStatus.occupied => const Color(0xFF6862D2),
    SeatStatus.reserved => const Color(0xFFC28D46),
    SeatStatus.unavailable => const Color(0xFF999DA8),
  };
  @override
  Widget build(BuildContext context) => Material(
    color: seat.status == SeatStatus.occupied
        ? const Color(0xFFF6F5FF)
        : Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(17),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Container(
        height: 142,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(
            color: seat.status == SeatStatus.occupied
                ? const Color(0xFFDCD9FF)
                : const Color(0xFFE4E7ED),
          ),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  seat.number,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Row(
                  children: [
                    CircleAvatar(radius: 3.5, backgroundColor: color),
                    const SizedBox(width: 5),
                    Text(
                      seat.status.name[0].toUpperCase() +
                          seat.status.name.substring(1),
                      style: const TextStyle(
                        fontSize: 8,
                        color: Color(0xFF9297A6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            if (student != null)
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9E7FB),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Center(
                      child: Text(
                        student!.initials,
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF605AA6),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student!.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Expires ${student!.expiry}',
                          style: const TextStyle(
                            fontSize: 7,
                            color: Color(0xFF999EAC),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.grid_view_outlined,
                      color: color.withAlpha(130),
                      size: 22,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      seat.status == SeatStatus.available
                          ? 'Ready to assign'
                          : seat.status.name,
                      style: TextStyle(fontSize: 8, color: color),
                    ),
                  ],
                ),
              ),
            const Spacer(),
            if (student != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Status(student!),
                  const Text(
                    'Member',
                    style: TextStyle(fontSize: 7, color: Color(0xFF9A9FAD)),
                  ),
                ],
              ),
          ],
        ),
      ),
    ),
  );
}

class _Status extends StatelessWidget {
  final Student student;
  const _Status(this.student);
  @override
  Widget build(BuildContext context) {
    final paid = student.payment == PaymentStatus.paid;
    final color = paid ? const Color(0xFF23936B) : const Color(0xFFC47D25);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 2.5, backgroundColor: color),
          const SizedBox(width: 5),
          Text(
            paid ? 'Paid' : 'Pending',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
