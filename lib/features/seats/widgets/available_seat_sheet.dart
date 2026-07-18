import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/seats_controller.dart';
import '../models/seat.dart';
import 'assign_student_sheet.dart';

class AvailableSeatSheet extends ConsumerWidget {
  final Seat seat;
  const AvailableSeatSheet({super.key, required this.seat});
  @override
  Widget build(BuildContext context, WidgetRef ref) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD9DCE5),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF6F1),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.event_seat_outlined,
                  color: Color(0xFF23876A),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seat ${seat.number}',
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    'Available for assignment',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF23876A),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => AssignStudentSheet(seat: seat),
                );
              },
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: const Text('Assign Student'),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _set(context, ref, SeatStatus.blocked),
                  icon: const Icon(Icons.block, size: 18),
                  label: const Text('Block'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _set(context, ref, SeatStatus.maintenance),
                  icon: const Icon(Icons.build_outlined, size: 18),
                  label: const Text('Maintenance'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
  void _set(BuildContext context, WidgetRef ref, SeatStatus status) {
    ref.read(seatsProvider.notifier).setStatus(seat.number, status);
    Navigator.pop(context);
  }
}
