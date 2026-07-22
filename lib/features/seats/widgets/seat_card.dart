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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Theme accents per status
    final Color cardBg;
    final Color borderColor;
    final List<BoxShadow> cardShadows;

    if (widget.selected) {
      cardBg = isDark ? const Color(0xFF2C2454) : const Color(0xFFF0ECFE);
      borderColor = const Color(0xFF6366F1);
      cardShadows = [
        BoxShadow(
          color: const Color(0xFF6366F1).withOpacity(0.35),
          blurRadius: 16,
          spreadRadius: 1,
        ),
      ];
    } else if (widget.seat.status == SeatStatus.occupied) {
      if (widget.student?.payment == PaymentStatus.pending ||
          widget.student?.payment == PaymentStatus.expired) {
        cardBg = isDark ? const Color(0xFF2A1C20) : const Color(0xFFFFF5F5);
        borderColor = isDark ? const Color(0xFF4A252B) : const Color(0xFFFEE2E2);
        cardShadows = [
          BoxShadow(
            color: const Color(0xFFEF4444).withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ];
      } else {
        cardBg = isDark ? const Color(0xFF192523) : const Color(0xFFF0FDF4);
        borderColor = isDark ? const Color(0xFF1E3A34) : const Color(0xFFDCFCE7);
        cardShadows = [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ];
      }
    } else if (widget.seat.status == SeatStatus.blocked) {
      cardBg = isDark ? const Color(0xFF1F2128) : const Color(0xFFF1F5F9);
      borderColor = isDark ? const Color(0xFF2A2D38) : const Color(0xFFE2E8F0);
      cardShadows = [];
    } else if (widget.seat.status == SeatStatus.maintenance) {
      cardBg = isDark ? const Color(0xFF22242E) : const Color(0xFFF8FAFC);
      borderColor = isDark ? const Color(0xFF2E3242) : const Color(0xFFE2E8F0);
      cardShadows = [];
    } else {
      // Available seat
      cardBg = isDark ? const Color(0xFF1C2030) : Colors.white;
      borderColor = hovered
          ? const Color(0xFF6366F1).withOpacity(0.5)
          : isDark
          ? const Color(0xFF2A2F45)
          : const Color(0xFFE2E8F0);
      cardShadows = [
        BoxShadow(
          color: hovered
              ? const Color(0xFF6366F1).withOpacity(0.18)
              : isDark
              ? Colors.black.withOpacity(0.3)
              : const Color(0xFF1E2238).withOpacity(0.05),
          blurRadius: hovered ? 18 : 10,
          offset: Offset(0, hovered ? 6 : 4),
        ),
      ];
    }

    return MouseRegion(
      cursor: interactive ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        scale: hovered && interactive ? 1.04 : 1,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: widget.disabled ? .38 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: borderColor,
                width: widget.selected ? 2.2 : 1.2,
              ),
              boxShadow: cardShadows,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: interactive ? widget.onTap : null,
                onLongPress: interactive ? widget.onLongPress : null,
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: EdgeInsets.all(widget.compact ? 10 : 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.event_seat_rounded,
                              size: 13,
                              color: statusColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              displayNumber,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.4,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: statusColor.withOpacity(0.8),
                                  blurRadius: 6,
                                  spreadRadius: 1,
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
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  widget.student!.initials,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.student!.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.2,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    widget.student!.payment == PaymentStatus.paid
                                        ? 'Active'
                                        : 'Due Soon',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w700,
                                      color: statusColor,
                                    ),
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
                              size: 14,
                              color: isDark
                                  ? const Color(0xFF7E879B)
                                  : const Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                _label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? const Color(0xFF8C95A8)
                                      : const Color(0xFF64748B),
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
