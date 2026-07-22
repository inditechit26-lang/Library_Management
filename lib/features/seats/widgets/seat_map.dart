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

    return LayoutBuilder(
      builder: (context, constraints) {
        // Compact enough to scan 50–150 seats, while keeping every card clear.
        final minCardWidth = constraints.maxWidth >= 1200
            ? 118.0
            : constraints.maxWidth >= 700
            ? 112.0
            : 96.0;
        final columns = (constraints.maxWidth / minCardWidth).floor().clamp(
          3,
          12,
        );
        final spacing = constraints.maxWidth < 430 ? 8.0 : 10.0;

        return Container(
          padding: EdgeInsets.all(constraints.maxWidth < 430 ? 10 : 14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: seats.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: constraints.maxWidth < 430 ? .9 : 1.02,
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
        );
      },
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
