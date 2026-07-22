import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../students/controllers/students_controller.dart';
import '../controllers/seats_controller.dart';
import '../models/seat.dart';
import '../widgets/seat_map.dart';
import '../widgets/seat_status_legend.dart';

class ChangeSeatScreen extends ConsumerStatefulWidget {
  final String currentSeat;
  const ChangeSeatScreen({super.key, required this.currentSeat});
  @override
  ConsumerState<ChangeSeatScreen> createState() => _ChangeSeatScreenState();
}

class _ChangeSeatScreenState extends ConsumerState<ChangeSeatScreen> {
  String? selected;
  bool moving = false;
  @override
  Widget build(BuildContext context) {
    final seats = ref.watch(seatsProvider),
        students = ref.watch(studentsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Change Seat')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 34),
        children: [
          Text(
            'Choose a new seat',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          Text(
            'Your current seat is highlighted. Occupied seats are unavailable.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 18),
          SeatMap(
            seats: seats,
            students: students,
            selectionMode: true,
            selectedSeat: selected ?? widget.currentSeat,
            onTap: (seat) {
              if (seat.status != SeatStatus.available || moving) return;
              setState(() {
                selected = seat.seatId;
                moving = true;
              });
              Future.delayed(
                const Duration(milliseconds: 320),
                () => _move(seat.seatId),
              );
            },
          ),
          const SizedBox(height: 4),
          const SeatStatusLegend(),
        ],
      ),
    );
  }

  void _move(String nextId) {
    if (!mounted) return;
    final current = ref
        .read(seatsProvider)
        .firstWhere((seat) => seat.seatId == widget.currentSeat);
    final next = ref
        .read(seatsProvider)
        .firstWhere((seat) => seat.seatId == nextId);
    final student = ref
        .read(studentsProvider)
        .firstWhere((student) => student.id == current.studentId);
    ref
        .read(seatsProvider.notifier)
        .assign(nextId, student.id, previousSeatId: widget.currentSeat);
    ref
        .read(studentsProvider.notifier)
        .update(student.copyWith(seat: next.seatLabel, seatId: nextId));
    context.replace('/seats/$nextId');
  }
}
