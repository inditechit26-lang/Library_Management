import 'package:flutter/material.dart';
import '../../students/models/student.dart';
import '../models/seat.dart';

class SeatCard extends StatefulWidget {
  final Seat seat;
  final Student? student;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool compact, selected, disabled;
  const SeatCard({
    super.key,
    required this.seat,
    this.onTap,
    this.student,
    this.onLongPress,
    this.compact = false,
    this.selected = false,
    this.disabled = false,
  });

  @override
  State<SeatCard> createState() => _SeatCardState();
}

class _SeatCardState extends State<SeatCard> {
  bool hovered = false;

  Color get statusColor {
    if (widget.student?.payment == PaymentStatus.pending ||
        widget.student?.payment == PaymentStatus.expired) {
      return const Color(0xFFE35353);
    }
    return switch (widget.seat.status) {
      SeatStatus.available => const Color(0xFFD9DCE3),
      SeatStatus.occupied => const Color(0xFF28A176),
      SeatStatus.reserved => const Color(0xFFF19A38),
      SeatStatus.maintenance => const Color(0xFF697080),
      SeatStatus.blocked => const Color(0xFF353A46),
    };
  }

  String get displayNumber => widget.seat.seatLabel;

  @override
  Widget build(BuildContext context) {
    final occupied = widget.student != null;
    final interactive = !widget.disabled && widget.onTap != null;
    final colors = Theme.of(context).colorScheme;
    return MouseRegion(
      cursor: interactive ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        scale: hovered && interactive ? 1.025 : 1,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: widget.disabled ? .42 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.selected
                    ? colors.primary
                    : hovered
                    ? colors.primary.withAlpha(65)
                    : Colors.transparent,
                width: widget.selected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: hovered
                      ? const Color(0x182D2A6E)
                      : const Color(0x0B20243B),
                  blurRadius: hovered ? 22 : 15,
                  offset: Offset(0, hovered ? 9 : 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: interactive ? widget.onTap : null,
                onLongPress: interactive ? widget.onLongPress : null,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: EdgeInsets.all(widget.compact ? 11 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.airline_seat_recline_normal_rounded,
                            size: 15,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              displayNumber,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: statusColor.withAlpha(70),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (occupied)
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 13,
                              backgroundColor: colors.primaryContainer,
                              foregroundColor: colors.onPrimaryContainer,
                              child: Text(
                                widget.student!.initials,
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.student!.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Icon(
                                        widget.student!.membership ==
                                                MembershipType.fullTime
                                            ? Icons.workspace_premium_rounded
                                            : Icons.schedule_rounded,
                                        size: 10,
                                        color: const Color(0xFFB07B2C),
                                      ),
                                      const SizedBox(width: 3),
                                      Container(
                                        width: 5,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: statusColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      Flexible(
                                        child: Text(
                                          widget.student!.payment ==
                                                  PaymentStatus.paid
                                              ? 'Paid'
                                              : 'Unpaid',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 7.5,
                                            fontWeight: FontWeight.w800,
                                            color: statusColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Icon(
                              _stateIcon,
                              size: 17,
                              color: colors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                _label,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData get _stateIcon => switch (widget.seat.status) {
    SeatStatus.available => Icons.add_circle_outline_rounded,
    SeatStatus.maintenance => Icons.build_circle_outlined,
    SeatStatus.blocked => Icons.lock_outline_rounded,
    SeatStatus.reserved => Icons.bookmark_outline_rounded,
    SeatStatus.occupied => Icons.person_outline_rounded,
  };
  String get _label => switch (widget.seat.status) {
    SeatStatus.available => 'Available',
    SeatStatus.occupied => 'Occupied',
    SeatStatus.reserved => 'Reserved',
    SeatStatus.maintenance => 'Maintenance',
    SeatStatus.blocked => 'Blocked',
  };
}
