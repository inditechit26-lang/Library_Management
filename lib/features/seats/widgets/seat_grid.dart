import 'package:flutter/material.dart';
import '../../students/models/student.dart';
import '../models/seat.dart';
import 'seat_card.dart';

class SeatGrid extends StatelessWidget {
  final List<Seat> seats;
  final List<Student> students;
  final ValueChanged<Seat> onSeatTap;
  const SeatGrid({
    super.key,
    required this.seats,
    required this.students,
    required this.onSeatTap,
  });
  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: seats.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 9,
      mainAxisSpacing: 9,
      childAspectRatio: 1.22,
    ),
    itemBuilder: (_, index) {
      final seat = seats[index];
      Student? student;
      for (final item in students) {
        if (item.seat == seat.number) {
          student = item;
          break;
        }
      }
      return SeatCard(
        seat: seat,
        student: student,
        onTap: () => onSeatTap(seat),
      );
    },
  );
}
