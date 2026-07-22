import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../admissions/screens/admission_screen.dart';
import '../controllers/seats_controller.dart';
import '../models/seat.dart';
import 'assign_student_sheet.dart';

class AvailableSeatSheet extends ConsumerWidget {
  final Seat seat;
  const AvailableSeatSheet({super.key, required this.seat});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBlocked = seat.status == SeatStatus.blocked;
    final isMaintenance = seat.status == SeatStatus.maintenance;
    final isAvailable = seat.status == SeatStatus.available;

    String statusText = 'Available for assignment';
    Color statusColor = const Color(0xFF23876A);
    Color headerBg = const Color(0xFFEAF6F1);

    if (isBlocked) {
      statusText = 'Currently Blocked';
      statusColor = const Color(0xFFE35353);
      headerBg = const Color(0xFFFDE8E8);
    } else if (isMaintenance) {
      statusText = 'Under Maintenance';
      statusColor = const Color(0xFF697080);
      headerBg = const Color(0xFFECEFF3);
    }

    return SafeArea(
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
                    color: headerBg,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Icon(
                    isBlocked
                        ? Icons.block_rounded
                        : isMaintenance
                        ? Icons.build_circle_outlined
                        : Icons.event_seat_outlined,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seat ${seat.seatLabel}',
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 11,
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
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
                    label: const Text('Assign Existing'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () {
                      Navigator.pop(context);
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        useSafeArea: true,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(28),
                          ),
                        ),
                        builder: (_) => AdmissionScreen(
                          initialSeat: seat.seatLabel,
                        ),
                      );
                    },
                    icon: const Icon(Icons.person_add_outlined),
                    label: const Text('Add Student'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: isBlocked
                      ? FilledButton.icon(
                          onPressed: () => _toggleStatus(context, ref, isBlocked, SeatStatus.blocked),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFE35353),
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.lock_open_rounded, size: 18),
                          label: const Text('Unblock Seat'),
                        )
                      : OutlinedButton.icon(
                          onPressed: () => _toggleStatus(context, ref, isBlocked, SeatStatus.blocked),
                          icon: const Icon(Icons.block, size: 18),
                          label: const Text('Block'),
                        ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: isMaintenance
                      ? FilledButton.icon(
                          onPressed: () => _toggleStatus(context, ref, isMaintenance, SeatStatus.maintenance),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF697080),
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.check_circle_outline, size: 18),
                          label: const Text('End Maintenance'),
                        )
                      : OutlinedButton.icon(
                          onPressed: () => _toggleStatus(context, ref, isMaintenance, SeatStatus.maintenance),
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
  }

  void _toggleStatus(
    BuildContext context,
    WidgetRef ref,
    bool isActive,
    SeatStatus status,
  ) {
    final targetStatus = isActive ? SeatStatus.available : status;
    ref.read(seatsProvider.notifier).setStatus(seat.seatId, targetStatus);
    Navigator.pop(context);
    
    final message = targetStatus == SeatStatus.available
        ? 'Seat ${seat.seatLabel} is now Available'
        : 'Seat ${seat.seatLabel} status updated to ${targetStatus.name.toUpperCase()}';
        
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}

