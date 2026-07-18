import 'package:flutter/material.dart';
import '../../../core/settings/app_settings.dart';
import '../models/seat.dart';

class SeatBottomSheet extends StatelessWidget {
  final Seat seat;
  const SeatBottomSheet({super.key, required this.seat});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.event_seat_outlined,
          size: 42,
          color: Color(0xFF514BC0),
        ),
        Text(
          'Seat ${seat.number}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        Text(seat.status.name),
        const SizedBox(height: 18),
        if (seat.status == SeatStatus.available)
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.person_add_alt),
            label: Text(context.tr('Assign Student')),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.tr('Close')),
        ),
      ],
    ),
  );
}
