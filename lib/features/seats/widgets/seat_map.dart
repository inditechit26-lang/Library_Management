import 'package:flutter/material.dart';
import '../../students/models/student.dart';
import '../models/seat.dart';
import 'seat_card.dart';

class SeatMap extends StatelessWidget {
  final List<Seat> seats;
  final List<Student> students;
  final ValueChanged<Seat> onTap;
  final ValueChanged<Seat>? onLongPress;
  const SeatMap({
    super.key,
    required this.seats,
    required this.students,
    required this.onTap,
    this.onLongPress,
  });
  @override
  Widget build(BuildContext context) {
    final rows = <String, List<Seat>>{};
    for (final seat in seats) {
      rows.putIfAbsent(seat.row, () => []).add(seat);
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFD),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EF)),
      ),
      child: Column(
        children: [
          Container(
            width: 150,
            padding: const EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEFFD),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'ENTRANCE',
              style: TextStyle(
                fontSize: 9,
                letterSpacing: 1.4,
                color: Color(0xFF5650C7),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 20),
          for (final entry in rows.entries) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 25,
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF8B90A0),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (_, box) {
                      final count = box.maxWidth > 700
                          ? 10
                          : box.maxWidth > 420
                          ? 5
                          : 2;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: entry.value.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: count,
                          crossAxisSpacing: 9,
                          mainAxisSpacing: 9,
                          childAspectRatio: .94,
                        ),
                        itemBuilder: (_, i) {
                          final seat = entry.value[i];
                          return SeatCard(
                            seat: seat,
                            student: _student(seat),
                            compact: true,
                            onTap: () => onTap(seat),
                            onLongPress: onLongPress == null
                                ? null
                                : () => onLongPress!(seat),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            if (entry.key != rows.keys.last)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 13),
                child: Divider(height: 1),
              ),
          ],
        ],
      ),
    );
  }

  Student? _student(Seat seat) {
    for (final student in students) {
      if (student.seat == seat.number) return student;
    }
    return null;
  }
}
