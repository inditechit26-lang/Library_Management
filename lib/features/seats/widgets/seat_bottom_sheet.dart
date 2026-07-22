import 'package:flutter/material.dart';
import '../models/seat.dart';

class SeatBottomSheet extends StatelessWidget {
  final Seat seat;
  const SeatBottomSheet({super.key, required this.seat});
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      22,
      10,
      22,
      MediaQuery.paddingOf(context).bottom + 22,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFD9DBE4),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: const Color(0xFFEFEEFF),
            borderRadius: BorderRadius.circular(21),
          ),
          child: const Icon(
            Icons.event_seat_outlined,
            size: 32,
            color: Color(0xFF5650C7),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Seat ${seat.seatLabel}',
          style: const TextStyle(
            fontSize: 21,
            letterSpacing: -.35,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F5F9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            seat.status.name,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF73798B),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 22),
        if (seat.status == SeatStatus.available)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.person_add_alt),
              label: const Text('Assign Student'),
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ),
      ],
    ),
  );
}
