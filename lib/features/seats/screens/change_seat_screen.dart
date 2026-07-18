import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../students/controllers/students_controller.dart';
import '../controllers/seats_controller.dart';
import '../models/seat.dart';
import '../widgets/seat_card.dart';

class ChangeSeatScreen extends ConsumerWidget {
  final String currentSeat;
  const ChangeSeatScreen({super.key, required this.currentSeat});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seats = ref
        .watch(seatsProvider)
        .where((s) => s.status == SeatStatus.available)
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Change Seat')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            'Move from $currentSeat',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          const Text(
            'Select an available seat',
            style: TextStyle(color: Color(0xFF858B9D)),
          ),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: seats.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (_, i) => SeatCard(
              seat: seats[i],
              compact: true,
              onTap: () => _move(context, ref, seats[i].number),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _move(BuildContext context, WidgetRef ref, String next) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Confirm seat change'),
        content: Text('$currentSeat  →  $next'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: const Text('Change Seat'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final student = ref
        .read(studentsProvider)
        .firstWhere((s) => s.seat == currentSeat);
    ref.read(seatsProvider.notifier).assign(next, previousSeat: currentSeat);
    ref.read(studentsProvider.notifier).update(student.copyWith(seat: next));
    context.replace('/seats/$next');
  }
}
