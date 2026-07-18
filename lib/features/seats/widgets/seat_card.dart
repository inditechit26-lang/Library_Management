import 'package:flutter/material.dart';
import '../../students/models/student.dart';
import '../models/seat.dart';

class SeatCard extends StatelessWidget {
  final Seat seat;
  final Student? student;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool compact;
  const SeatCard({
    super.key,
    required this.seat,
    required this.onTap,
    this.student,
    this.onLongPress,
    this.compact = false,
  });

  Color get statusColor => switch (seat.status) {
    SeatStatus.available => const Color(0xFF23876A),
    SeatStatus.occupied => const Color(0xFF5650C7),
    SeatStatus.reserved => const Color(0xFFB8792A),
    SeatStatus.maintenance => const Color(0xFF73798A),
    SeatStatus.blocked => const Color(0xFFBE5660),
  };

  @override
  Widget build(BuildContext context) {
    final occupied = student != null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: occupied ? const Color(0xFFF6F5FF) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: occupied ? const Color(0xFFDCD9FF) : const Color(0xFFE5E7EF),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A1D2340),
            blurRadius: 18,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(compact ? 11 : 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      seat.number,
                      style: TextStyle(
                        fontSize: compact ? 15 : 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    CircleAvatar(radius: 4, backgroundColor: statusColor),
                  ],
                ),
                const Spacer(),
                if (occupied) ...[
                  Row(
                    children: [
                      CircleAvatar(
                        radius: compact ? 15 : 18,
                        backgroundColor: const Color(0xFFE7E5FA),
                        child: Text(
                          student!.initials,
                          style: const TextStyle(
                            fontSize: 9,
                            color: Color(0xFF514B9E),
                            fontWeight: FontWeight.w800,
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
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              student!.membership == MembershipType.fullTime
                                  ? 'Full Time'
                                  : 'Half Time',
                              style: const TextStyle(
                                fontSize: 8,
                                color: Color(0xFF888E9F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (!compact) ...[
                    const SizedBox(height: 11),
                    Row(
                      children: [
                        _Badge(
                          student!.payment == PaymentStatus.paid
                              ? 'Paid'
                              : 'Pending',
                          student!.payment == PaymentStatus.paid
                              ? const Color(0xFF23876A)
                              : const Color(0xFFB8792A),
                        ),
                        const Spacer(),
                        Text(
                          student!.expiry,
                          style: const TextStyle(
                            fontSize: 8,
                            color: Color(0xFF8B90A0),
                          ),
                        ),
                      ],
                    ),
                  ],
                ] else ...[
                  Icon(
                    Icons.event_seat_outlined,
                    size: compact ? 20 : 26,
                    color: statusColor.withAlpha(175),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    _label,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get _label => switch (seat.status) {
    SeatStatus.available => 'Available',
    SeatStatus.occupied => 'Occupied',
    SeatStatus.reserved => 'Reserved',
    SeatStatus.maintenance => 'Maintenance',
    SeatStatus.blocked => 'Blocked',
  };
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withAlpha(18),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: color),
    ),
  );
}
