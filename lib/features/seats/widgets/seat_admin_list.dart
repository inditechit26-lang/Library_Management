import 'package:flutter/material.dart';
import '../../students/models/student.dart';
import '../models/seat.dart';

class SeatAdminList extends StatelessWidget {
  final List<Seat> seats;
  final List<Student> students;
  final ValueChanged<Seat> onEdit, onDelete;
  const SeatAdminList({
    super.key,
    required this.seats,
    required this.students,
    required this.onEdit,
    required this.onDelete,
  });

  Student? _student(Seat seat) {
    for (final student in students) {
      if (student.id == seat.studentId) return student;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (seats.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(30),
        child: Center(child: Text('No seats found')),
      );
    }
    return Column(
      children: [
        for (final seat in seats)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _SeatAdminTile(
              seat: seat,
              student: _student(seat),
              onEdit: () => onEdit(seat),
              onDelete: () => onDelete(seat),
            ),
          ),
      ],
    );
  }
}

class _SeatAdminTile extends StatelessWidget {
  final Seat seat;
  final Student? student;
  final VoidCallback onEdit, onDelete;
  const _SeatAdminTile({
    required this.seat,
    required this.student,
    required this.onEdit,
    required this.onDelete,
  });
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.event_seat_outlined, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seat.seatLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  student?.name ?? _statusLabel,
                  style: TextStyle(fontSize: 9, color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: _statusColor,
              shape: BoxShape.circle,
            ),
          ),
          IconButton(
            tooltip: 'Rename',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 18),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
          ),
        ],
      ),
    );
  }

  String get _statusLabel => switch (seat.status) {
    SeatStatus.available => 'Available',
    SeatStatus.occupied => 'Occupied',
    SeatStatus.reserved => 'Reserved',
    SeatStatus.maintenance => 'Maintenance',
    SeatStatus.blocked => 'Blocked',
  };
  Color get _statusColor => switch (seat.status) {
    SeatStatus.available => const Color(0xFF28A176),
    SeatStatus.occupied => const Color(0xFF5C56D7),
    SeatStatus.reserved => const Color(0xFFF19A38),
    SeatStatus.maintenance => const Color(0xFF777D89),
    SeatStatus.blocked => const Color(0xFF343944),
  };
}
