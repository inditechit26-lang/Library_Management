import 'package:flutter/material.dart';
import '../../students/models/student.dart';
import '../models/seat.dart';
import 'seat_card.dart';

/// A dense, responsive seat canvas inspired by an app launcher. Seats are not
/// grouped into physical rows; the grid simply reflows to use available space.
class SeatMap extends StatelessWidget {
  final List<Seat> seats;
  final List<Student> students;
  final ValueChanged<Seat> onTap;
  final ValueChanged<Seat>? onLongPress;
  final String? selectedSeat;
  final bool selectionMode;

  const SeatMap({
    super.key,
    required this.seats,
    required this.students,
    required this.onTap,
    this.onLongPress,
    this.selectedSeat,
    this.selectionMode = false,
  });

  Student? _studentFor(Seat seat) {
    for (final student in students) {
      if (student.id == seat.studentId) return student;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (seats.isEmpty) return const _EmptyMap();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final availableCount = seats.where((s) => s.status == SeatStatus.available).length;
    final occupiedCount = seats.where((s) => s.status == SeatStatus.occupied).length;
    final alertCount = seats.where((s) {
      final st = _studentFor(s);
      return st != null && (st.payment == PaymentStatus.pending || st.payment == PaymentStatus.expired);
    }).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final minCardWidth = constraints.maxWidth >= 1200
            ? 120.0
            : constraints.maxWidth >= 700
            ? 112.0
            : 98.0;
        final columns = (constraints.maxWidth / minCardWidth).floor().clamp(
          3,
          12,
        );
        final spacing = constraints.maxWidth < 430 ? 10.0 : 12.0;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [
                      Color(0xFF1E2235),
                      Color(0xFF151828),
                    ]
                  : const [
                      Color(0xFFF8FAFC),
                      Color(0xFFEEF2F6),
                    ],
            ),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF2E354C)
                  : const Color(0xFFE2E8F0),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.4)
                    : const Color(0xFF64748B).withOpacity(0.08),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Ultra-premium canvas status bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark
                          ? const Color(0xFF2E354C)
                          : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x8010B981),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Interactive Floor View',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                      ),
                    ),
                    const Spacer(),
                    _StatBadge(
                      label: '$availableCount Free',
                      color: const Color(0xFF10B981),
                      bg: isDark ? const Color(0x1F10B981) : const Color(0xFFECFDF5),
                    ),
                    const SizedBox(width: 6),
                    _StatBadge(
                      label: '$occupiedCount Taken',
                      color: const Color(0xFF6366F1),
                      bg: isDark ? const Color(0x1F6366F1) : const Color(0xFFEEF2FF),
                    ),
                    if (alertCount > 0) ...[
                      const SizedBox(width: 6),
                      _StatBadge(
                        label: '$alertCount Due',
                        color: const Color(0xFFEF4444),
                        bg: isDark ? const Color(0x1FEF4444) : const Color(0xFFFEF2F2),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(constraints.maxWidth < 430 ? 12 : 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: seats.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: spacing,
                    childAspectRatio: constraints.maxWidth < 430 ? 0.88 : 0.98,
                  ),
                  itemBuilder: (context, index) {
                    final seat = seats[index];
                    return Hero(
                      tag: 'seat-${seat.seatId}',
                      child: Material(
                        color: Colors.transparent,
                        child: SeatCard(
                          seat: seat,
                          student: _studentFor(seat),
                          compact: true,
                          selected: seat.seatId == selectedSeat,
                          disabled:
                              selectionMode &&
                              seat.status != SeatStatus.available &&
                              seat.seatId != selectedSeat,
                          onTap: () => onTap(seat),
                          onLongPress: onLongPress == null
                              ? null
                              : () => onLongPress!(seat),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;

  const _StatBadge({
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _EmptyMap extends StatelessWidget {
  const _EmptyMap();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(36),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      children: [
        Icon(
          Icons.search_off_rounded,
          size: 34,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 10),
        const Text(
          'No matching seats',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          'Try another search or filter',
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ),
  );
}
