import 'package:flutter/material.dart';
import '../../settings/models/library_configuration.dart';
import '../../students/models/student.dart';
import '../models/seat.dart';
import 'seat_card.dart';

class _SectionGroup {
  final LibraryRoom? section;
  final List<Seat> seats;
  _SectionGroup({required this.section, required this.seats});
}

/// A dense, responsive seat canvas with room/section headers and color separation.
class SeatMap extends StatelessWidget {
  final List<Seat> seats;
  final List<Student> students;
  final List<LibraryRoom>? rooms;
  final ValueChanged<Seat> onTap;
  final ValueChanged<Seat>? onLongPress;
  final String? selectedSeat;
  final bool selectionMode;

  const SeatMap({
    super.key,
    required this.seats,
    required this.students,
    this.rooms,
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

  LibraryRoom? _sectionForSeat(Seat seat) {
    if (rooms == null || rooms!.isEmpty) return null;
    final student = _studentFor(seat);
    final secId = seat.sectionId ?? student?.sectionId;
    if (secId != null) {
      for (final room in rooms!) {
        if (room.id == secId) return room;
      }
    }
    return null;
  }

  List<_SectionGroup> _buildGroups() {
    if (rooms == null || rooms!.isEmpty) {
      return [_SectionGroup(section: null, seats: seats)];
    }

    final groups = <_SectionGroup>[];
    final processedSeatIds = <String>{};

    for (final room in rooms!) {
      final roomSeats = seats.where((s) {
        final sec = _sectionForSeat(s);
        return sec?.id == room.id;
      }).toList();

      if (roomSeats.isNotEmpty) {
        processedSeatIds.addAll(roomSeats.map((s) => s.seatId));
        groups.add(_SectionGroup(section: room, seats: roomSeats));
      }
    }

    final unassigned = seats.where((s) => !processedSeatIds.contains(s.seatId)).toList();
    if (unassigned.isNotEmpty) {
      groups.add(_SectionGroup(section: null, seats: unassigned));
    }

    return groups.isEmpty ? [_SectionGroup(section: null, seats: seats)] : groups;
  }

  @override
  Widget build(BuildContext context) {
    if (seats.isEmpty) return const _EmptyMap();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final availableCount = seats
        .where((s) => s.status == SeatStatus.available)
        .length;
    final occupiedCount = seats
        .where((s) => s.status == SeatStatus.occupied)
        .length;
    final alertCount = seats.where((s) {
      final st = _studentFor(s);
      return st != null &&
          (st.payment == PaymentStatus.pending ||
              st.payment == PaymentStatus.expired);
    }).length;

    final sectionGroups = _buildGroups();

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
                  ? const [Color(0xFF1E2235), Color(0xFF151828)]
                  : const [Color(0xFFF8FAFC), Color(0xFFEEF2F6)],
            ),
            border: Border.all(
              color: isDark ? const Color(0xFF2E354C) : const Color(0xFFE2E8F0),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.4)
                    : const Color(0xFF64748B).withValues(alpha: 0.08),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Canvas status bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
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
                        color: isDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF475569),
                      ),
                    ),
                    const Spacer(),
                    _StatBadge(
                      label: '$availableCount Free',
                      color: const Color(0xFF10B981),
                      bg: isDark
                          ? const Color(0x1F10B981)
                          : const Color(0xFFECFDF5),
                    ),
                    const SizedBox(width: 6),
                    _StatBadge(
                      label: '$occupiedCount Taken',
                      color: const Color(0xFF6366F1),
                      bg: isDark
                          ? const Color(0x1F6366F1)
                          : const Color(0xFFEEF2FF),
                    ),
                    if (alertCount > 0) ...[
                      const SizedBox(width: 6),
                      _StatBadge(
                        label: '$alertCount Due',
                        color: const Color(0xFFEF4444),
                        bg: isDark
                            ? const Color(0x1FEF4444)
                            : const Color(0xFFFEF2F2),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(constraints.maxWidth < 430 ? 12 : 16),
                child: Column(
                  children: sectionGroups.map((group) {
                    final section = group.section;
                    final sectionSeats = group.seats;
                    final freeInSec = sectionSeats.where((s) => s.status == SeatStatus.available).length;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (section != null || sectionGroups.length > 1) ...[
                          Container(
                            margin: const EdgeInsets.only(bottom: 12, top: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? (section?.color.withValues(alpha: 0.12) ?? const Color(0xFF2E354C).withValues(alpha: 0.5))
                                  : (section?.color.withValues(alpha: 0.08) ?? Colors.white),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: section?.color.withValues(alpha: 0.3) ?? (isDark ? const Color(0xFF2E354C) : const Color(0xFFE2E8F0)),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: section?.color ?? const Color(0xFF6366F1),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: (section?.color ?? const Color(0xFF6366F1)).withValues(alpha: 0.6),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  section?.name ?? 'General Room',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (section?.color ?? const Color(0xFF6366F1)).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${sectionSeats.length} seats • $freeInSec free',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: section?.color ?? (isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4F46E5)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: sectionSeats.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            crossAxisSpacing: spacing,
                            mainAxisSpacing: spacing,
                            childAspectRatio: constraints.maxWidth < 430 ? 0.88 : 0.98,
                          ),
                          itemBuilder: (context, index) {
                            final seat = sectionSeats[index];
                            final student = _studentFor(seat);
                            final sec = _sectionForSeat(seat);
                            return Hero(
                              tag: 'seat-${seat.seatId}',
                              child: Material(
                                color: Colors.transparent,
                                child: SeatCard(
                                  seat: seat,
                                  student: student,
                                  sectionName: sec?.name,
                                  sectionColor: sec?.color,
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
                        const SizedBox(height: 14),
                      ],
                    );
                  }).toList(),
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
