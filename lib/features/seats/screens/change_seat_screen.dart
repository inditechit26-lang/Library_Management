import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/error_handler.dart';
import '../../auth/providers/auth_provider.dart';
import '../../students/controllers/students_controller.dart';
import '../controllers/seats_controller.dart' as sc;
import '../models/seat.dart';
import '../providers/seats_provider.dart';
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
    final seats = ref.watch(sc.seatsProvider),
        students = ref.watch(studentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Change Seat')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 34),
        children: [
          Text(
            'Choose a new seat',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
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
              _move(seat.seatId);
            },
          ),
          const SizedBox(height: 4),
          const SeatStatusLegend(),
        ],
      ),
    );
  }

  void _move(String nextId) async {
    final libraryId = ref.read(currentLibraryIdProvider);
    if (libraryId == null || libraryId.isEmpty) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, 'Library ID missing.');
        setState(() => moving = false);
      }
      return;
    }

    try {
      final currentSeatModel = ref.watch(seatsStreamProvider).value?.firstWhere(
            (s) => s.seatNumber == widget.currentSeat,
            orElse: () => throw Exception('Current seat missing'),
          );

      final studentId = currentSeatModel?.studentId ?? 'std_1';
      final studentName = currentSeatModel?.studentName ?? 'Student';

      await ref.read(seatsRepositoryProvider).transferSeat(
            libraryId: libraryId,
            fromSeatNumber: widget.currentSeat,
            toSeatNumber: nextId,
            studentId: studentId,
            studentName: studentName,
          );

      if (mounted) {
        ErrorHandler.showSuccessSnackBar(context, 'Seat transferred to #$nextId');
        context.replace('/seats/$nextId');
      }
    } catch (e) {
      if (mounted) {
        setState(() => moving = false);
        ErrorHandler.showErrorSnackBar(context, e);
      }
    }
  }
}
